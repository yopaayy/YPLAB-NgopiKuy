<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Menu;
use App\Jobs\ProcessOrderNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $orders = $request->user()->role === 'admin' 
            ? Order::with('user', 'items.menu', 'payment')->get()
            : Order::where('user_id', $request->user()->id)->with('items.menu', 'payment')->get();

        return response()->json($orders);
    }

    public function show(Request $request, Order $order)
    {
        // For guest access, ideally verify by guest_id, but here we simplify for member/admin
        if ($request->user() && $request->user()->role !== 'admin' && $order->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json($order->load('user', 'items.menu', 'payment'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'type' => 'required|in:dine-in,delivery',
            'items' => 'required|array|min:1',
            'items.*.menu_id' => 'required|exists:menus,id',
            'items.*.quantity' => 'required|integer|min:1',
            'payment_method' => 'required|string',
            'idempotency_key' => 'required|string',
            'guest_id' => 'nullable|string',
            'customer_name' => 'nullable|string',
            'customer_phone' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        // 1. Idempotency Check (Prevent Double Submit)
        $existingOrder = Order::where('idempotency_key', $request->idempotency_key)->first();
        if ($existingOrder) {
            return response()->json([
                'message' => 'Order already processed',
                'order' => $existingOrder->load('items', 'payment')
            ], 200); // 200 OK because it's idempotent
        }

        try {
            // 2. Database Transaction & Locking
            $order = DB::transaction(function () use ($request) {
                
                // Get all menus with locks to prevent price/availability changes during calculation
                $menuIds = collect($request->items)->pluck('menu_id');
                $menus = Menu::whereIn('id', $menuIds)->lockForUpdate()->get()->keyBy('id');

                $total_amount = 0;
                $orderItemsData = [];

                foreach ($request->items as $item) {
                    $menu = $menus[$item['menu_id']];
                    if (!$menu->is_available) {
                        throw new \Exception("Menu {$menu->name} is currently unavailable.");
                    }
                    $subtotal = $item['quantity'] * $menu->price;
                    $total_amount += $subtotal;
                    
                    $orderItemsData[] = [
                        'menu_id' => $menu->id,
                        'quantity' => $item['quantity'],
                        'price' => $menu->price,
                    ];
                }

                // 3. Member Benefits & Voucher Validation
                $discount_amount = 0;
                $user_id = null;

                // Check auth via sanctum (if token provided)
                $user = auth('sanctum')->user();
                if ($user) {
                    $user_id = $user->id;
                    
                    // If voucher is provided
                    if ($request->voucher_id) {
                        $userVoucher = \App\Models\UserVoucher::where('user_id', $user_id)
                            ->where('voucher_id', $request->voucher_id)
                            ->where('status', 'claimed')
                            ->with('voucher')
                            ->lockForUpdate()
                            ->first();

                        if (!$userVoucher) {
                            throw new \Exception("Voucher tidak valid atau sudah digunakan.");
                        }

                        $voucher = $userVoucher->voucher;

                        // Check min purchase
                        if ($voucher->min_purchase > 0 && $total_amount < $voucher->min_purchase) {
                            throw new \Exception("Minimum pembelian untuk voucher ini adalah Rp {$voucher->min_purchase}");
                        }

                        // Calculate discount
                        if ($voucher->type === 'percent') {
                            $discount_amount = $total_amount * ($voucher->value / 100);
                        } else {
                            $discount_amount = $voucher->value;
                        }

                        // Cap discount amount to total amount
                        if ($discount_amount > $total_amount) {
                            $discount_amount = $total_amount;
                        }

                        // Mark voucher as used
                        $userVoucher->update(['status' => 'used']);
                    }
                }

                $final_amount = $total_amount - $discount_amount;

                // Create Order
                $order = Order::create([
                    'user_id' => $user_id,
                    'guest_id' => $user_id ? null : $request->guest_id,
                    'customer_name' => $user_id ? $user->name : $request->customer_name,
                    'customer_phone' => $user_id ? $user->phone_number : $request->customer_phone,
                    'idempotency_key' => $request->idempotency_key,
                    'order_number' => 'ORD-' . strtoupper(Str::random(8)),
                    'type' => $request->type,
                    'status' => 'pending',
                    'total_amount' => $final_amount,
                    'discount_amount' => $discount_amount,
                    'notes' => $request->notes,
                    'voucher_id' => $request->voucher_id,
                ]);

                // Create Order Items
                foreach ($orderItemsData as $itemData) {
                    $itemData['order_id'] = $order->id;
                    OrderItem::create($itemData);
                }

                // Create Payment Request
                $order->payment()->create([
                    'method' => $request->payment_method,
                    'status' => 'pending',
                    'amount' => $final_amount,
                ]);

                return $order;
            });

            // 4. Queue WhatsApp Notification
            ProcessOrderNotification::dispatch($order);

            return response()->json($order->load('items', 'payment'), 201);
            
        } catch (\Exception $e) {
            return response()->json(['message' => 'Failed to create order', 'error' => $e->getMessage()], 400);
        }
    }

    public function updateStatus(Request $request, Order $order)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $request->validate([
            'status' => 'required|in:pending,processing,completed,cancelled'
        ]);

        $order->update(['status' => $request->status]);
        
        // Queue status update notification
        ProcessOrderNotification::dispatch($order);

        return response()->json($order);
    }
}

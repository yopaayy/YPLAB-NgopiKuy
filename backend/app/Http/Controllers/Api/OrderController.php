<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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
        if ($request->user()->role !== 'admin' && $order->user_id !== $request->user()->id) {
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
            'items.*.price' => 'required|numeric|min:0',
            'payment_method' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        try {
            DB::beginTransaction();

            $total_amount = collect($request->items)->sum(function($item) {
                return $item['quantity'] * $item['price'];
            });

            // Create Order
            $order = Order::create([
                'user_id' => $request->user()->id,
                'order_number' => 'ORD-' . strtoupper(uniqid()),
                'type' => $request->type,
                'status' => 'pending',
                'total_amount' => $total_amount,
                'notes' => $request->notes,
            ]);

            // Create Order Items
            foreach ($request->items as $item) {
                OrderItem::create([
                    'order_id' => $order->id,
                    'menu_id' => $item['menu_id'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                ]);
            }

            // Create Payment Request
            $order->payment()->create([
                'method' => $request->payment_method,
                'status' => 'pending',
                'amount' => $total_amount,
            ]);

            DB::commit();

            return response()->json($order->load('items', 'payment'), 201);
            
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to create order', 'error' => $e->getMessage()], 500);
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

        return response()->json($order);
    }
}

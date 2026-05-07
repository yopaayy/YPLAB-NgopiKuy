<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Models\Order;
use App\Models\Payment;
use App\Jobs\ProcessOrderNotification;

class MidtransController extends Controller
{
    public function callback(Request $request)
    {
        $serverKey = env('MIDTRANS_SERVER_KEY');
        $hashedKey = hash('sha512', $request->order_id . $request->status_code . $request->gross_amount . $serverKey);

        if ($hashedKey !== $request->signature_key) {
            return response()->json(['message' => 'Invalid signature'], 403);
        }

        $order = Order::where('order_number', $request->order_id)->first();
        if (!$order) {
            return response()->json(['message' => 'Order not found'], 404);
        }

        $payment = $order->payment;
        if (!$payment) {
            return response()->json(['message' => 'Payment not found'], 404);
        }

        $transactionStatus = $request->transaction_status;
        $fraudStatus = $request->fraud_status;

        $newPaymentStatus = $payment->status;
        $newOrderStatus = $order->status;

        if ($transactionStatus == 'capture') {
            if ($fraudStatus == 'challenge') {
                $newPaymentStatus = 'pending';
            } else if ($fraudStatus == 'accept') {
                $newPaymentStatus = 'success';
                $newOrderStatus = 'processing';
            }
        } else if ($transactionStatus == 'settlement') {
            $newPaymentStatus = 'success';
            $newOrderStatus = 'processing';
        } else if ($transactionStatus == 'cancel' || $transactionStatus == 'deny' || $transactionStatus == 'expire') {
            $newPaymentStatus = 'failed';
            $newOrderStatus = 'cancelled';
        } else if ($transactionStatus == 'pending') {
            $newPaymentStatus = 'pending';
        }

        // Only update and notify if status actually changes
        if ($newPaymentStatus !== $payment->status || $newOrderStatus !== $order->status) {
            $payment->update([
                'status' => $newPaymentStatus,
                'transaction_id' => $request->transaction_id,
            ]);

            $order->update([
                'status' => $newOrderStatus
            ]);

            // Notify user & admin via WhatsApp (job)
            ProcessOrderNotification::dispatch($order);

            Log::info("Midtrans Callback: Order {$order->order_number} status updated to {$newOrderStatus}.");
        }

        return response()->json(['message' => 'Callback handled']);
    }
}

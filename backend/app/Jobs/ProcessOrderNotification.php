<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ProcessOrderNotification implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $order;

    /**
     * Create a new job instance.
     */
    public function __construct(Order $order)
    {
        $this->order = $order;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        // Logika untuk mengirim WhatsApp API atau Email
        $phone = $this->order->customer_phone;
        $status = $this->order->status;
        $orderNumber = $this->order->order_number;
        
        if ($phone) {
            Log::info("Mengirim WA ke $phone: Pesanan $orderNumber status saat ini adalah $status");
            // Disini bisa tambahkan integrasi dengan Fonnte/Wablas HTTP request
        }
    }
}

<?php

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use App\Services\WhatsAppService;

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
        $phone = $this->order->customer_phone;
        $status = $this->order->status;
        $orderNumber = $this->order->order_number;
        $customerName = $this->order->customer_name ?? 'Pelanggan';
        $totalAmount = number_format($this->order->total_amount, 0, ',', '.');
        
        if ($phone) {
            $message = "";
            switch ($status) {
                case 'pending':
                    $message = "Halo *$customerName*! 👋\n\nTerima kasih telah memesan di *NgopiKuy*.\nPesanan Anda dengan nomor *$orderNumber* telah kami terima dan sedang menunggu pembayaran sebesar *Rp $totalAmount*.\n\nSegera selesaikan pembayaran agar pesanan dapat segera diproses ya! ☕";
                    break;
                case 'processing':
                    $message = "Hore! 🎉\n\nPesanan *$orderNumber* kamu sedang kami proses.\nMohon tunggu sebentar, barista kami sedang meracik minuman terbaik untukmu! ☕✨";
                    break;
                case 'completed':
                    $message = "Pesanan Selesai! ✅\n\nMinumanmu (Order: *$orderNumber*) sudah siap dinikmati.\nTerima kasih telah memilih *NgopiKuy*! Jangan lupa ngopi hari ini. 😉";
                    break;
                case 'cancelled':
                    $message = "Mohon maaf, pesanan *$orderNumber* kamu telah dibatalkan.\nJika ada kendala, silakan hubungi admin kami. 😔";
                    break;
                default:
                    $message = "Halo! Status pesanan kamu ($orderNumber) saat ini adalah *$status*.";
            }

            Log::info("Mengirim WA ke $phone: Pesanan $orderNumber status saat ini adalah $status");
            
            $waService = new WhatsAppService();
            $waService->sendMessage($phone, $message);

            // Jika status pending (pesanan baru), beri tahu Admin juga
            if ($status === 'pending') {
                $adminPhone = env('ADMIN_PHONE');
                if (!empty($adminPhone)) {
                    $orderType = strtoupper($this->order->type);
                    $adminMsg = "🔔 *ORDER BARU MASUK!* 🔔\n\nNomor: *$orderNumber*\nTipe: *$orderType*\nPelanggan: *$customerName*\nTotal: *Rp $totalAmount*\n\nSegera cek dashboard admin untuk memproses pesanan ini! ☕";
                    $waService->sendMessage($adminPhone, $adminMsg);
                    Log::info("Notifikasi admin dikirim ke $adminPhone untuk order $orderNumber");
                }
            }
        }
    }
}

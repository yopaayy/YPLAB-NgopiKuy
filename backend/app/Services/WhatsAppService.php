<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class WhatsAppService
{
    /**
     * Send a WhatsApp message using Fonnte API
     *
     * @param string $target Target phone number (e.g., 0812xxx or 62812xxx)
     * @param string $message The message text
     * @return bool
     */
    public function sendMessage(string $target, string $message): bool
    {
        $token = env('FONNTE_TOKEN');

        if (empty($token)) {
            Log::warning('Fonnte token is not set. WhatsApp message will not be sent.');
            return false;
        }

        try {
            $response = Http::withHeaders([
                'Authorization' => $token,
            ])->post('https://api.fonnte.com/send', [
                'target' => $target,
                'message' => $message,
                'countryCode' => '62', // Default to Indonesia
            ]);

            if ($response->successful()) {
                Log::info("WhatsApp message sent successfully to {$target}");
                return true;
            }

            Log::error("Failed to send WhatsApp message. Response: " . $response->body());
            return false;
        } catch (\Exception $e) {
            Log::error("Exception when sending WhatsApp message: " . $e->getMessage());
            return false;
        }
    }
}

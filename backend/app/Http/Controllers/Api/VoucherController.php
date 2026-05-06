<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Voucher;
use App\Models\UserVoucher;
use Illuminate\Http\Request;

class VoucherController extends Controller
{
    // Public: Show active vouchers
    public function index()
    {
        $vouchers = Voucher::where(function($query) {
            $query->whereNull('expired_date')
                  ->orWhere('expired_date', '>', now());
        })->get();

        return response()->json($vouchers);
    }

    // Admin: Create voucher
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'code' => 'nullable|string|unique:vouchers',
            'type' => 'required|in:percent,nominal',
            'value' => 'required|numeric|min:0',
            'start_date' => 'nullable|date',
            'expired_date' => 'nullable|date|after_or_equal:start_date',
            'min_purchase' => 'nullable|numeric|min:0',
            'quota' => 'nullable|integer|min:1',
        ]);

        $voucher = Voucher::create($request->all());

        return response()->json($voucher, 201);
    }

    // Admin: Update voucher
    public function update(Request $request, Voucher $voucher)
    {
        $voucher->update($request->all());
        return response()->json($voucher);
    }

    // Admin: Delete voucher
    public function destroy(Voucher $voucher)
    {
        $voucher->delete();
        return response()->json(null, 204);
    }

    // Member: Claim voucher
    public function claim(Request $request, Voucher $voucher)
    {
        $user = $request->user();

        // Check if expired
        if ($voucher->expired_date && $voucher->expired_date < now()) {
            return response()->json(['message' => 'Voucher sudah kadaluarsa'], 400);
        }

        // Check quota
        if ($voucher->quota !== null) {
            $claimedCount = UserVoucher::where('voucher_id', $voucher->id)->count();
            if ($claimedCount >= $voucher->quota) {
                return response()->json(['message' => 'Kuota voucher sudah habis'], 400);
            }
        }

        // Check if already claimed
        $exists = UserVoucher::where('user_id', $user->id)
                             ->where('voucher_id', $voucher->id)
                             ->exists();

        if ($exists) {
            return response()->json(['message' => 'Anda sudah mengklaim voucher ini'], 400);
        }

        $userVoucher = UserVoucher::create([
            'user_id' => $user->id,
            'voucher_id' => $voucher->id,
            'status' => 'claimed'
        ]);

        return response()->json(['message' => 'Voucher berhasil diklaim', 'data' => $userVoucher], 201);
    }

    // Member: Get my vouchers
    public function myVouchers(Request $request)
    {
        $user = $request->user();
        $vouchers = UserVoucher::where('user_id', $user->id)
                               ->with('voucher')
                               ->get();

        return response()->json($vouchers);
    }
}

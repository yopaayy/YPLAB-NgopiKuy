<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Voucher;

class VoucherController extends Controller
{
    public function index()
    {
        $vouchers = Voucher::orderBy('created_at', 'desc')->paginate(10);
        return view('admin.vouchers.index', compact('vouchers'));
    }

    public function create()
    {
        return view('admin.vouchers.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|unique:vouchers,code',
            'name' => 'required|string',
            'type' => 'required|in:percent,nominal',
            'value' => 'required|numeric|min:0',
            'min_purchase' => 'required|numeric|min:0',
            'quota' => 'required|integer|min:1',
            'start_date' => 'nullable|date',
            'expired_date' => 'required|date'
        ]);

        Voucher::create($validated);
        return redirect()->route('admin.vouchers.index')->with('success', 'Voucher created successfully.');
    }

    public function edit(Voucher $voucher)
    {
        return view('admin.vouchers.edit', compact('voucher'));
    }

    public function update(Request $request, Voucher $voucher)
    {
        $validated = $request->validate([
            'code' => 'required|string|unique:vouchers,code,' . $voucher->id,
            'name' => 'required|string',
            'type' => 'required|in:percent,nominal',
            'value' => 'required|numeric|min:0',
            'min_purchase' => 'required|numeric|min:0',
            'quota' => 'required|integer|min:1',
            'start_date' => 'nullable|date',
            'expired_date' => 'required|date'
        ]);

        $voucher->update($validated);
        return redirect()->route('admin.vouchers.index')->with('success', 'Voucher updated successfully.');
    }

    public function destroy(Voucher $voucher)
    {
        $voucher->delete();
        return redirect()->route('admin.vouchers.index')->with('success', 'Voucher deleted successfully.');
    }
}

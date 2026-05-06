@extends('admin.layout')

@section('header', 'Vouchers Management')

@section('content')
<div class="mb-6 flex justify-between items-center">
    <div>
        <p class="text-gray-500">Manage promotional vouchers for your members.</p>
    </div>
    <a href="#" class="bg-amber-700 hover:bg-amber-800 text-white font-bold py-2 px-4 rounded shadow">
        <i class="fas fa-plus mr-2"></i> Create Voucher
    </a>
</div>

<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
            <thead>
                <tr class="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider">
                    <th class="px-6 py-3 font-medium">Code & Name</th>
                    <th class="px-6 py-3 font-medium">Discount</th>
                    <th class="px-6 py-3 font-medium">Min. Purchase</th>
                    <th class="px-6 py-3 font-medium">Quota (Used/Total)</th>
                    <th class="px-6 py-3 font-medium">Valid Until</th>
                    <th class="px-6 py-3 font-medium text-right">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @foreach($vouchers as $voucher)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4">
                        <p class="text-sm font-bold text-amber-700">{{ $voucher->code }}</p>
                        <p class="text-sm text-gray-900">{{ $voucher->name }}</p>
                    </td>
                    <td class="px-6 py-4 text-sm font-medium text-green-600">
                        @if($voucher->type == 'percent')
                            {{ $voucher->value }}%
                        @else
                            Rp {{ number_format($voucher->value, 0, ',', '.') }}
                        @endif
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600">
                        Rp {{ number_format($voucher->min_purchase, 0, ',', '.') }}
                    </td>
                    <td class="px-6 py-4">
                        <div class="w-full bg-gray-200 rounded-full h-2.5 mb-1">
                            @php
                                $percent = $voucher->quota > 0 ? ($voucher->used_count / $voucher->quota) * 100 : 0;
                            @endphp
                            <div class="bg-amber-600 h-2.5 rounded-full" style="width: {{ $percent }}%"></div>
                        </div>
                        <p class="text-xs text-gray-500 text-center">{{ $voucher->used_count }} / {{ $voucher->quota }}</p>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600">
                        {{ $voucher->expired_date ? \Carbon\Carbon::parse($voucher->expired_date)->format('d M Y') : 'N/A' }}
                        @if($voucher->expired_date && \Carbon\Carbon::parse($voucher->expired_date)->isPast())
                            <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">Expired</span>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-right space-x-2">
                        <a href="#" class="text-blue-600 hover:text-blue-900 text-sm font-medium"><i class="fas fa-edit"></i></a>
                        <form action="{{ route('admin.vouchers.destroy', $voucher->id) }}" method="POST" class="inline">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="text-red-600 hover:text-red-900 text-sm font-medium" onclick="return confirm('Are you sure?')"><i class="fas fa-trash"></i></button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    <div class="px-6 py-4 border-t border-gray-100">
        {{ $vouchers->links() }}
    </div>
</div>
@endsection

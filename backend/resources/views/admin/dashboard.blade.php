@extends('admin.layout')

@section('header', 'Dashboard Overview')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <!-- Stat Cards -->
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex items-center">
        <div class="w-14 h-14 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 mr-4">
            <i class="fas fa-shopping-cart text-xl"></i>
        </div>
        <div>
            <p class="text-sm text-gray-500 font-medium">Total Orders</p>
            <p class="text-2xl font-bold text-gray-800">{{ number_format($stats['total_orders']) }}</p>
        </div>
    </div>
    
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex items-center">
        <div class="w-14 h-14 rounded-full bg-orange-100 flex items-center justify-center text-orange-600 mr-4">
            <i class="fas fa-clock text-xl"></i>
        </div>
        <div>
            <p class="text-sm text-gray-500 font-medium">Pending Orders</p>
            <p class="text-2xl font-bold text-gray-800">{{ number_format($stats['pending_orders']) }}</p>
        </div>
    </div>
    
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex items-center">
        <div class="w-14 h-14 rounded-full bg-green-100 flex items-center justify-center text-green-600 mr-4">
            <i class="fas fa-wallet text-xl"></i>
        </div>
        <div>
            <p class="text-sm text-gray-500 font-medium">Total Revenue</p>
            <p class="text-2xl font-bold text-gray-800">Rp {{ number_format($stats['total_revenue'], 0, ',', '.') }}</p>
        </div>
    </div>
    
    <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex items-center">
        <div class="w-14 h-14 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 mr-4">
            <i class="fas fa-users text-xl"></i>
        </div>
        <div>
            <p class="text-sm text-gray-500 font-medium">Total Members</p>
            <p class="text-2xl font-bold text-gray-800">{{ number_format($stats['total_users']) }}</p>
        </div>
    </div>
</div>

<!-- Recent Orders Table -->
<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
        <h3 class="font-semibold text-gray-800">Recent Orders</h3>
        <a href="{{ route('admin.orders.index') }}" class="text-sm text-amber-600 hover:text-amber-800 font-medium">View All</a>
    </div>
    <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
            <thead>
                <tr class="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider">
                    <th class="px-6 py-3 font-medium">Order ID</th>
                    <th class="px-6 py-3 font-medium">Customer</th>
                    <th class="px-6 py-3 font-medium">Type</th>
                    <th class="px-6 py-3 font-medium">Amount</th>
                    <th class="px-6 py-3 font-medium">Status</th>
                    <th class="px-6 py-3 font-medium">Date</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @forelse($recent_orders as $order)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-sm font-medium text-gray-900">{{ $order->order_number }}</td>
                    <td class="px-6 py-4 text-sm text-gray-600">
                        {{ $order->customer_name }}
                        @if($order->user_id)
                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800 ml-2">Member</span>
                        @else
                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800 ml-2">Guest</span>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600 capitalize">{{ $order->type }}</td>
                    <td class="px-6 py-4 text-sm text-gray-900 font-medium">Rp {{ number_format($order->total_amount, 0, ',', '.') }}</td>
                    <td class="px-6 py-4">
                        @php
                            $badgeColors = [
                                'pending' => 'bg-orange-100 text-orange-800',
                                'processing' => 'bg-blue-100 text-blue-800',
                                'completed' => 'bg-green-100 text-green-800',
                                'cancelled' => 'bg-red-100 text-red-800',
                            ];
                            $badgeClass = $badgeColors[$order->status] ?? 'bg-gray-100 text-gray-800';
                        @endphp
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium {{ $badgeClass }} capitalize">
                            {{ $order->status }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500">{{ $order->created_at->diffForHumans() }}</td>
                </tr>
                @empty
                <tr>
                    <td colspan="6" class="px-6 py-8 text-center text-gray-500">No orders found.</td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>
</div>
@endsection

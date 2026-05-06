@extends('admin.layout')

@section('header', 'Menus Management')

@section('content')
<div class="mb-6 flex justify-between items-center">
    <div>
        <p class="text-gray-500">Manage your coffee shop products and categories.</p>
    </div>
    <a href="#" class="bg-amber-700 hover:bg-amber-800 text-white font-bold py-2 px-4 rounded shadow">
        <i class="fas fa-plus mr-2"></i> Add Menu
    </a>
</div>

<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
            <thead>
                <tr class="bg-gray-50 text-gray-500 text-xs uppercase tracking-wider">
                    <th class="px-6 py-3 font-medium">Image</th>
                    <th class="px-6 py-3 font-medium">Name</th>
                    <th class="px-6 py-3 font-medium">Category</th>
                    <th class="px-6 py-3 font-medium">Price</th>
                    <th class="px-6 py-3 font-medium">Status</th>
                    <th class="px-6 py-3 font-medium text-right">Actions</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                @foreach($menus as $menu)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4">
                        <img src="{{ $menu->image_url ?? 'https://via.placeholder.com/50' }}" alt="{{ $menu->name }}" class="w-12 h-12 rounded object-cover">
                    </td>
                    <td class="px-6 py-4">
                        <p class="text-sm font-medium text-gray-900">{{ $menu->name }}</p>
                        <p class="text-xs text-gray-500 line-clamp-1">{{ $menu->description }}</p>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-600 capitalize">{{ $menu->category }}</td>
                    <td class="px-6 py-4 text-sm font-medium text-gray-900">Rp {{ number_format($menu->price, 0, ',', '.') }}</td>
                    <td class="px-6 py-4">
                        @if($menu->is_available)
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">Available</span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">Out of Stock</span>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-right space-x-2">
                        <a href="#" class="text-blue-600 hover:text-blue-900 text-sm font-medium"><i class="fas fa-edit"></i></a>
                        <form action="{{ route('admin.menus.destroy', $menu->id) }}" method="POST" class="inline">
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
        {{ $menus->links() }}
    </div>
</div>
@endsection

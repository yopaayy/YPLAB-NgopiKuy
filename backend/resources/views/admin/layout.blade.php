<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NgopiKuy Admin</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-gray-50 flex h-screen overflow-hidden">

    <!-- Sidebar -->
    <aside class="w-64 bg-amber-900 text-white flex flex-col h-full shadow-xl">
        <div class="h-20 flex items-center justify-center border-b border-amber-800">
            <h1 class="text-2xl font-bold tracking-wider">Ngopi<span class="text-amber-400">Kuy</span></h1>
        </div>
        <nav class="flex-1 py-6 px-4 space-y-2 overflow-y-auto">
            <a href="{{ route('admin.dashboard') }}" class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-amber-800 transition {{ request()->routeIs('admin.dashboard') ? 'bg-amber-800' : '' }}">
                <i class="fas fa-chart-pie w-5 text-center"></i>
                <span>Dashboard</span>
            </a>
            <a href="{{ route('admin.orders.index') }}" class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-amber-800 transition {{ request()->routeIs('admin.orders.*') ? 'bg-amber-800' : '' }}">
                <i class="fas fa-shopping-bag w-5 text-center"></i>
                <span>Orders</span>
            </a>
            <a href="{{ route('admin.menus.index') }}" class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-amber-800 transition {{ request()->routeIs('admin.menus.*') ? 'bg-amber-800' : '' }}">
                <i class="fas fa-coffee w-5 text-center"></i>
                <span>Menus</span>
            </a>
            <a href="{{ route('admin.vouchers.index') }}" class="flex items-center space-x-3 px-4 py-3 rounded-lg hover:bg-amber-800 transition {{ request()->routeIs('admin.vouchers.*') ? 'bg-amber-800' : '' }}">
                <i class="fas fa-ticket-alt w-5 text-center"></i>
                <span>Vouchers</span>
            </a>
        </nav>
        <div class="p-4 border-t border-amber-800">
            <div class="flex items-center mb-4 px-2">
                <div class="w-10 h-10 rounded-full bg-amber-700 flex items-center justify-center text-white font-bold">
                    {{ substr(auth()->user()->name, 0, 1) }}
                </div>
                <div class="ml-3">
                    <p class="text-sm font-medium">{{ auth()->user()->name }}</p>
                    <p class="text-xs text-amber-300">Admin</p>
                </div>
            </div>
            <form action="{{ route('admin.logout') }}" method="POST">
                @csrf
                <button type="submit" class="w-full flex items-center justify-center space-x-2 bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded transition">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </button>
            </form>
        </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 flex flex-col h-full overflow-hidden">
        <!-- Top Header -->
        <header class="h-20 bg-white border-b border-gray-200 flex items-center justify-between px-8 z-10">
            <h2 class="text-xl font-semibold text-gray-800">@yield('header')</h2>
            <div class="text-sm text-gray-500">
                {{ now()->format('l, d F Y') }}
            </div>
        </header>

        <!-- Page Content -->
        <div class="flex-1 overflow-y-auto p-8 bg-gray-50">
            @if(session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-6">
                    {{ session('success') }}
                </div>
            @endif
            @if(session('error'))
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-6">
                    {{ session('error') }}
                </div>
            @endif
            
            @yield('content')
        </div>
    </main>

</body>
</html>

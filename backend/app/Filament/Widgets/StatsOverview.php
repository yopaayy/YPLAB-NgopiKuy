<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\Menu;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $todayRevenue = Order::whereDate('created_at', today())
            ->where('status', '!=', 'cancelled')
            ->sum('total_amount');

        $pendingOrders = Order::where('status', 'pending')->count();
        $processingOrders = Order::where('status', 'processing')->count();
        $completedToday = Order::whereDate('created_at', today())
            ->where('status', 'completed')
            ->count();
        $totalCustomers = User::where('role', 'user')->count();
        $totalMenus = Menu::where('is_available', true)->count();

        return [
            Stat::make('Today\'s Revenue', 'Rp ' . number_format($todayRevenue, 0, ',', '.'))
                ->description('Total revenue today')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success')
                ->chart([7, 3, 4, 5, 6, 3, 5, 3]),

            Stat::make('Pending Orders', $pendingOrders)
                ->description('Awaiting action')
                ->descriptionIcon('heroicon-m-clock')
                ->color($pendingOrders > 0 ? 'danger' : 'success'),

            Stat::make('Processing', $processingOrders)
                ->description('Being prepared')
                ->descriptionIcon('heroicon-m-arrow-path')
                ->color('info'),

            Stat::make('Completed Today', $completedToday)
                ->description('Orders done today')
                ->descriptionIcon('heroicon-m-check-circle')
                ->color('success'),

            Stat::make('Registered Users', $totalCustomers)
                ->description('Total customers')
                ->descriptionIcon('heroicon-m-users')
                ->color('warning'),

            Stat::make('Active Menus', $totalMenus)
                ->description('Available items')
                ->descriptionIcon('heroicon-m-cake')
                ->color('info'),
        ];
    }
}

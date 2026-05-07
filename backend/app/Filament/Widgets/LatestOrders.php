<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;

class LatestOrders extends TableWidget
{
    protected static ?int $sort = 2;

    protected int | string | array $columnSpan = 'full';

    protected static ?string $heading = '📋 Latest Orders';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Order::query()->latest()->limit(10)
            )
            ->columns([
                TextColumn::make('order_number')
                    ->label('Order #')
                    ->weight('bold')
                    ->color('primary')
                    ->searchable(),
                TextColumn::make('customer_name')
                    ->label('Customer')
                    ->description(fn ($record) => $record->customer_phone),
                TextColumn::make('type')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'dine-in' => '🍽️ Dine In',
                        'delivery' => '🚚 Delivery',
                        'takeaway' => '🥡 Takeaway',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'dine-in' => 'info',
                        'delivery' => 'warning',
                        'takeaway' => 'gray',
                        default => 'gray',
                    }),
                TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'pending' => '⏳ Pending',
                        'processing' => '🔄 Processing',
                        'completed' => '✅ Completed',
                        'cancelled' => '❌ Cancelled',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'processing' => 'info',
                        'completed' => 'success',
                        'cancelled' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('total_amount')
                    ->label('Total')
                    ->money('IDR')
                    ->weight('bold'),
                TextColumn::make('created_at')
                    ->label('Time')
                    ->since()
                    ->sortable(),
            ]);
    }
}

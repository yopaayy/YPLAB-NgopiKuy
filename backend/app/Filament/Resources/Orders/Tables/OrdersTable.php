<?php

namespace App\Filament\Resources\Orders\Tables;

use App\Jobs\ProcessOrderNotification;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class OrdersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('order_number')
                    ->label('Order #')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->copyable()
                    ->copyMessage('Order number copied!')
                    ->color('primary'),
                TextColumn::make('customer_name')
                    ->label('Customer')
                    ->searchable()
                    ->sortable()
                    ->description(fn ($record) => $record->customer_phone),
                TextColumn::make('type')
                    ->label('Type')
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
                    ->label('Status')
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
                    ->sortable()
                    ->weight('bold'),
                TextColumn::make('payment.status')
                    ->label('Payment')
                    ->badge()
                    ->color(fn (?string $state): string => match ($state) {
                        'success' => 'success',
                        'pending' => 'warning',
                        'failed' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('created_at')
                    ->label('Ordered At')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->since(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('status')
                    ->options([
                        'pending' => 'Pending',
                        'processing' => 'Processing',
                        'completed' => 'Completed',
                        'cancelled' => 'Cancelled',
                    ])
                    ->label('Order Status'),
                SelectFilter::make('type')
                    ->options([
                        'dine-in' => 'Dine In',
                        'delivery' => 'Delivery',
                        'takeaway' => 'Takeaway',
                    ])
                    ->label('Order Type'),
            ])
            ->recordActions([
                Action::make('process')
                    ->label('Process')
                    ->icon('heroicon-o-arrow-path')
                    ->color('info')
                    ->requiresConfirmation()
                    ->modalHeading('Process Order?')
                    ->modalDescription('This will mark the order as processing and notify the customer via WhatsApp.')
                    ->visible(fn ($record) => $record->status === 'pending')
                    ->action(function ($record) {
                        $record->update(['status' => 'processing']);
                        ProcessOrderNotification::dispatch($record);
                    }),
                Action::make('complete')
                    ->label('Complete')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Complete Order?')
                    ->modalDescription('This will mark the order as completed and notify the customer via WhatsApp.')
                    ->visible(fn ($record) => $record->status === 'processing')
                    ->action(function ($record) {
                        $record->update(['status' => 'completed']);
                        ProcessOrderNotification::dispatch($record);
                    }),
                Action::make('cancel')
                    ->label('Cancel')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('Cancel Order?')
                    ->modalDescription('This will cancel the order and notify the customer via WhatsApp. This action cannot be undone.')
                    ->visible(fn ($record) => in_array($record->status, ['pending', 'processing']))
                    ->action(function ($record) {
                        $record->update(['status' => 'cancelled']);
                        ProcessOrderNotification::dispatch($record);
                    }),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}

<?php

namespace App\Filament\Resources\Vouchers\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class VouchersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('Voucher')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->description(fn ($record) => $record->code ? "Code: {$record->code}" : 'Auto-claim'),
                TextColumn::make('type')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'percent' => '📊 Percent',
                        'nominal' => '💰 Nominal',
                        default => $state,
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'percent' => 'info',
                        'nominal' => 'success',
                        default => 'gray',
                    }),
                TextColumn::make('value')
                    ->label('Discount')
                    ->formatStateUsing(fn ($record) => $record->type === 'percent'
                        ? "{$record->value}%"
                        : 'Rp ' . number_format($record->value, 0, ',', '.'))
                    ->weight('bold')
                    ->color('danger'),
                TextColumn::make('min_purchase')
                    ->label('Min. Purchase')
                    ->money('IDR')
                    ->sortable()
                    ->placeholder('No minimum'),
                TextColumn::make('quota')
                    ->label('Quota')
                    ->sortable()
                    ->alignCenter()
                    ->placeholder('Unlimited')
                    ->badge()
                    ->color('warning'),
                TextColumn::make('start_date')
                    ->label('Valid From')
                    ->dateTime('d M Y')
                    ->sortable()
                    ->placeholder('—'),
                TextColumn::make('expired_date')
                    ->label('Expires')
                    ->dateTime('d M Y')
                    ->sortable()
                    ->color(fn ($record) => $record->expired_date && now()->gt($record->expired_date) ? 'danger' : 'success')
                    ->placeholder('No expiry'),
                TextColumn::make('created_at')
                    ->dateTime('d M Y')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('type')
                    ->options([
                        'percent' => 'Percentage',
                        'nominal' => 'Fixed Amount',
                    ]),
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}

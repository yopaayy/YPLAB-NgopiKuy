<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class OrderForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('user_id')
                    ->numeric(),
                TextInput::make('guest_id'),
                TextInput::make('customer_name'),
                TextInput::make('customer_phone')
                    ->tel(),
                TextInput::make('idempotency_key'),
                TextInput::make('order_number')
                    ->required(),
                Select::make('type')
                    ->options(['dine-in' => 'Dine in', 'delivery' => 'Delivery'])
                    ->required(),
                Select::make('status')
                    ->options([
            'pending' => 'Pending',
            'processing' => 'Processing',
            'completed' => 'Completed',
            'cancelled' => 'Cancelled',
        ])
                    ->default('pending')
                    ->required(),
                TextInput::make('total_amount')
                    ->required()
                    ->numeric(),
                TextInput::make('discount_amount')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                Textarea::make('notes')
                    ->columnSpanFull(),
                TextInput::make('voucher_id')
                    ->numeric(),
            ]);
    }
}

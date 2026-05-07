<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Group;
use Filament\Forms\Components\Placeholder;
use Filament\Forms\Components\Section;
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
                Grid::make(3)->schema([
                    Group::make([
                        Section::make('Order Details')
                            ->icon('heroicon-o-document-text')
                            ->schema([
                                TextInput::make('order_number')
                                    ->label('Order Number')
                                    ->disabled()
                                    ->dehydrated(),
                                Select::make('type')
                                    ->label('Order Type')
                                    ->options([
                                        'dine-in' => '🍽️ Dine In',
                                        'delivery' => '🚚 Delivery',
                                        'takeaway' => '🥡 Takeaway',
                                    ])
                                    ->required()
                                    ->native(false),
                                Select::make('status')
                                    ->options([
                                        'pending' => '⏳ Pending',
                                        'processing' => '🔄 Processing',
                                        'completed' => '✅ Completed',
                                        'cancelled' => '❌ Cancelled',
                                    ])
                                    ->default('pending')
                                    ->required()
                                    ->native(false),
                                Textarea::make('notes')
                                    ->label('Customer Notes')
                                    ->placeholder('Special requests, allergies, etc.')
                                    ->rows(3)
                                    ->columnSpanFull(),
                            ])->columns(2),

                        Section::make('Payment Summary')
                            ->icon('heroicon-o-banknotes')
                            ->schema([
                                TextInput::make('total_amount')
                                    ->label('Total Amount')
                                    ->prefix('Rp')
                                    ->numeric()
                                    ->disabled()
                                    ->dehydrated(),
                                TextInput::make('discount_amount')
                                    ->label('Discount')
                                    ->prefix('Rp')
                                    ->numeric()
                                    ->default(0)
                                    ->disabled()
                                    ->dehydrated(),
                            ])->columns(2),
                    ])->columnSpan(2),

                    Group::make([
                        Section::make('Customer Info')
                            ->icon('heroicon-o-user')
                            ->schema([
                                TextInput::make('customer_name')
                                    ->label('Name')
                                    ->disabled()
                                    ->dehydrated(),
                                TextInput::make('customer_phone')
                                    ->label('Phone')
                                    ->tel()
                                    ->disabled()
                                    ->dehydrated(),
                                Select::make('user_id')
                                    ->label('Linked Account')
                                    ->relationship('user', 'name')
                                    ->searchable()
                                    ->preload()
                                    ->disabled()
                                    ->dehydrated(),
                            ]),
                    ])->columnSpan(1),
                ]),
            ]);
    }
}

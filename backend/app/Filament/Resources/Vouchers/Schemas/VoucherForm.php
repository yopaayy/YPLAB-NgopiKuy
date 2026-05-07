<?php

namespace App\Filament\Resources\Vouchers\Schemas;

use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\DateTimePicker;
use Filament\Schemas\Schema;

class VoucherForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(2)->schema([
                    Section::make('Voucher Details')
                        ->description('Basic voucher information.')
                        ->icon('heroicon-o-gift')
                        ->schema([
                            TextInput::make('name')
                                ->label('Voucher Name')
                                ->required()
                                ->maxLength(255)
                                ->placeholder('e.g. Weekend Special 20%'),
                            TextInput::make('code')
                                ->label('Voucher Code')
                                ->placeholder('e.g. NGOPI20')
                                ->helperText('Unique code for claiming. Leave blank for auto-claim vouchers.'),
                            Select::make('type')
                                ->label('Discount Type')
                                ->options([
                                    'percent' => '📊 Percentage (%)',
                                    'nominal' => '💰 Fixed Amount (Rp)',
                                ])
                                ->required()
                                ->reactive()
                                ->native(false),
                            TextInput::make('value')
                                ->label('Value')
                                ->required()
                                ->numeric()
                                ->prefix(fn (callable $get) => $get('type') === 'percent' ? '%' : 'Rp')
                                ->placeholder(fn (callable $get) => $get('type') === 'percent' ? 'e.g. 20' : 'e.g. 15000'),
                        ])->columns(2),

                    Section::make('Conditions & Validity')
                        ->description('Set limits and expiry dates.')
                        ->icon('heroicon-o-clock')
                        ->schema([
                            TextInput::make('min_purchase')
                                ->label('Minimum Purchase')
                                ->numeric()
                                ->prefix('Rp')
                                ->default(0)
                                ->placeholder('0 = no minimum'),
                            TextInput::make('quota')
                                ->label('Total Quota')
                                ->numeric()
                                ->placeholder('Leave blank for unlimited')
                                ->helperText('Maximum number of users that can claim'),
                            DateTimePicker::make('start_date')
                                ->label('Start Date')
                                ->native(false)
                                ->displayFormat('d M Y H:i'),
                            DateTimePicker::make('expired_date')
                                ->label('Expiry Date')
                                ->native(false)
                                ->displayFormat('d M Y H:i')
                                ->after('start_date'),
                        ])->columns(2),
                ]),
            ]);
    }
}

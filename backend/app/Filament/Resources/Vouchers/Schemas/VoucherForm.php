<?php

namespace App\Filament\Resources\Vouchers\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class VoucherForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->required(),
                TextInput::make('code'),
                Select::make('type')
                    ->options(['percent' => 'Percent', 'nominal' => 'Nominal'])
                    ->required(),
                TextInput::make('value')
                    ->required()
                    ->numeric(),
                DateTimePicker::make('start_date'),
                DateTimePicker::make('expired_date'),
                TextInput::make('min_purchase')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('quota')
                    ->numeric(),
            ]);
    }
}

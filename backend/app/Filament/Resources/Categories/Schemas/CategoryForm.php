<?php

namespace App\Filament\Resources\Categories\Schemas;

use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class CategoryForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Category Details')
                    ->description('Manage your menu categories here.')
                    ->icon('heroicon-o-tag')
                    ->schema([
                        TextInput::make('name')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('e.g. Hot Coffee, Iced Tea, Pastry'),
                        TextInput::make('icon')
                            ->label('Icon Emoji')
                            ->placeholder('e.g. ☕, 🧋, 🍰')
                            ->helperText('Emoji icon displayed in the mobile app'),
                        Textarea::make('description')
                            ->placeholder('Brief description of this category...')
                            ->rows(3)
                            ->columnSpanFull(),
                    ])->columns(2),
            ]);
    }
}

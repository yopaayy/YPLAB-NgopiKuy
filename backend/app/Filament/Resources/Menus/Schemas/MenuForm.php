<?php

namespace App\Filament\Resources\Menus\Schemas;

use App\Models\Category;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class MenuForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(3)->schema([
                    Section::make('Menu Information')
                        ->description('Fill in the details of the menu item.')
                        ->icon('heroicon-o-clipboard-document-list')
                        ->schema([
                            Select::make('category_id')
                                ->label('Category')
                                ->relationship('category', 'name')
                                ->searchable()
                                ->preload()
                                ->required()
                                ->createOptionForm([
                                    TextInput::make('name')->required(),
                                    TextInput::make('icon')->label('Emoji Icon'),
                                ]),
                            TextInput::make('name')
                                ->label('Menu Name')
                                ->required()
                                ->maxLength(255)
                                ->placeholder('e.g. Espresso, Latte, Croissant'),
                            Textarea::make('description')
                                ->placeholder('A short description for customers...')
                                ->rows(3)
                                ->columnSpanFull(),
                            TextInput::make('price')
                                ->required()
                                ->numeric()
                                ->prefix('Rp')
                                ->placeholder('25000')
                                ->minValue(0),
                            Toggle::make('is_available')
                                ->label('Available for Order')
                                ->default(true)
                                ->onColor('success')
                                ->offColor('danger')
                                ->helperText('Toggle off to hide from the app menu'),
                        ])->columns(2)
                        ->columnSpan(2),

                    Section::make('Image')
                        ->icon('heroicon-o-photo')
                        ->schema([
                            FileUpload::make('image')
                                ->image()
                                ->imageEditor()
                                ->directory('menus')
                                ->disk('public')
                                ->maxSize(2048)
                                ->helperText('Max 2MB. Recommended 500x500px'),
                        ])->columnSpan(1),
                ]),
            ]);
    }
}

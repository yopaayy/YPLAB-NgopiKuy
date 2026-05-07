<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\Grid;
use Filament\Forms\Components\Group;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;
use Illuminate\Support\Facades\Hash;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Grid::make(3)->schema([
                    Section::make('Account Information')
                        ->description('Basic user details and login credentials.')
                        ->icon('heroicon-o-user-circle')
                        ->schema([
                            TextInput::make('name')
                                ->label('Full Name')
                                ->required()
                                ->maxLength(255)
                                ->placeholder('John Doe'),
                            TextInput::make('email')
                                ->label('Email Address')
                                ->email()
                                ->required()
                                ->unique(ignoreRecord: true)
                                ->placeholder('user@example.com'),
                            TextInput::make('password')
                                ->password()
                                ->dehydrateStateUsing(fn ($state) => filled($state) ? Hash::make($state) : null)
                                ->dehydrated(fn ($state) => filled($state))
                                ->required(fn (string $operation): bool => $operation === 'create')
                                ->helperText(fn (string $operation): string => $operation === 'edit' ? 'Leave blank to keep current password' : '')
                                ->placeholder('••••••••'),
                            Select::make('role')
                                ->options([
                                    'admin' => '🛡️ Admin',
                                    'user' => '👤 User',
                                ])
                                ->default('user')
                                ->required()
                                ->native(false),
                        ])->columns(2)
                        ->columnSpan(2),

                    Section::make('Contact & Profile')
                        ->icon('heroicon-o-phone')
                        ->schema([
                            TextInput::make('phone_number')
                                ->label('Phone Number')
                                ->tel()
                                ->placeholder('08xx-xxxx-xxxx'),
                            TextInput::make('avatar')
                                ->label('Avatar URL')
                                ->placeholder('https://...'),
                            Textarea::make('address')
                                ->label('Address')
                                ->placeholder('Full address for delivery...')
                                ->rows(3),
                        ])->columnSpan(1),
                ]),
            ]);
    }
}

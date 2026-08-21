<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Schemas\Components\Section::make('معلومات المستخدم')
                    ->components([
                        TextInput::make('name')
                            ->label('الاسم')
                            ->required(),
                        TextInput::make('email')
                            ->label('البريد الإلكتروني')
                            ->email()
                            ->required(),
                        TextInput::make('phone')
                            ->label('رقم الهاتف')
                            ->tel()
                            ->default(null),
                        \Filament\Forms\Components\Select::make('roles')
                            ->label('الصلاحية (Role)')
                            ->relationship('roles', 'name')
                            ->multiple()
                            ->preload()
                            ->required(),
                        TextInput::make('password')
                            ->label('كلمة المرور')
                            ->password()
                            ->dehydrated(fn ($state) => filled($state))
                            ->required(fn (string $operation): bool => $operation === 'create'),
                        Toggle::make('is_active')
                            ->label('الحساب نشط')
                            ->default(true)
                            ->required(),
                    ])->columns(2),
            ]);
    }
}

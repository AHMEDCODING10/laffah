<?php

namespace App\Filament\Resources\CaptainProfiles\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class CaptainProfileForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                \Filament\Schemas\Components\Section::make('معلومات الكابتن والمركبة')
                    ->components([
                        \Filament\Forms\Components\Select::make('user_id')
                            ->label('المستخدم')
                            ->relationship('user', 'name')
                            ->searchable()
                            ->preload()
                            ->required(),
                        TextInput::make('vehicle_type')
                            ->label('نوع المركبة')
                            ->default(null),
                        TextInput::make('vehicle_model')
                            ->label('موديل المركبة')
                            ->default(null),
                        TextInput::make('plate_number')
                            ->label('رقم اللوحة')
                            ->default(null),
                        TextInput::make('vehicle_color')
                            ->label('لون المركبة')
                            ->default(null),
                        TextInput::make('rating')
                            ->label('التقييم')
                            ->required()
                            ->numeric()
                            ->default(5.0),
                        Toggle::make('is_online')
                            ->label('متصل الآن')
                            ->required(),
                        Toggle::make('is_verified')
                            ->label('حساب موثق')
                            ->required(),
                    ])->columns(2),
            ]);
    }
}

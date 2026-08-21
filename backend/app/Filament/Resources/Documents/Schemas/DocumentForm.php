<?php

namespace App\Filament\Resources\Documents\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class DocumentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('captain_profile_id')
                    ->required()
                    ->numeric(),
                Select::make('type')
                    ->options([
            'id_card' => 'Id card',
            'driving_license' => 'Driving license',
            'vehicle_registration' => 'Vehicle registration',
        ])
                    ->required(),
                TextInput::make('file_path')
                    ->required(),
                Select::make('status')
                    ->options(['pending' => 'Pending', 'approved' => 'Approved', 'rejected' => 'Rejected'])
                    ->default('pending')
                    ->required(),
                TextInput::make('rejection_reason')
                    ->default(null),
            ]);
    }
}

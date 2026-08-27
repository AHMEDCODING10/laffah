<?php

namespace App\Filament\Resources\Trips\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class TripForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('user_id')
                    ->required()
                    ->numeric(),
                TextInput::make('captain_profile_id')
                    ->numeric()
                    ->default(null),
                Select::make('status')
                    ->options([
            'pending' => 'Pending',
            'accepted' => 'Accepted',
            'arrived' => 'Arrived',
            'in_transit' => 'In transit',
            'completed' => 'Completed',
            'cancelled' => 'Cancelled',
        ])
                    ->default('pending')
                    ->required(),
                Select::make('type')
                    ->options(['ride' => 'Ride', 'delivery' => 'Delivery'])
                    ->default('ride')
                    ->required(),
                Toggle::make('is_multi_stop')
                    ->required(),
                TextInput::make('pickup_address')
                    ->required(),
                TextInput::make('pickup_latitude')
                    ->required()
                    ->numeric(),
                TextInput::make('pickup_longitude')
                    ->required()
                    ->numeric(),
                TextInput::make('dropoff_address')
                    ->required(),
                TextInput::make('dropoff_latitude')
                    ->required()
                    ->numeric(),
                TextInput::make('dropoff_longitude')
                    ->required()
                    ->numeric(),
                TextInput::make('distance_km')
                    ->numeric()
                    ->default(null),
                TextInput::make('estimated_price')
                    ->numeric()
                    ->default(null)
                    ->prefix('$'),
                TextInput::make('final_price')
                    ->numeric()
                    ->default(null)
                    ->prefix('$'),
                DateTimePicker::make('accepted_at'),
                DateTimePicker::make('started_at'),
                DateTimePicker::make('completed_at'),
            ]);
    }
}

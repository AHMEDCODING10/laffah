<?php

namespace App\Filament\Resources\Trips\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class TripInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user_id')
                    ->numeric(),
                TextEntry::make('captain_profile_id')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('status')
                    ->badge(),
                TextEntry::make('type')
                    ->badge(),
                IconEntry::make('is_multi_stop')
                    ->boolean(),
                TextEntry::make('pickup_address'),
                TextEntry::make('pickup_latitude')
                    ->numeric(),
                TextEntry::make('pickup_longitude')
                    ->numeric(),
                TextEntry::make('dropoff_address'),
                TextEntry::make('dropoff_latitude')
                    ->numeric(),
                TextEntry::make('dropoff_longitude')
                    ->numeric(),
                TextEntry::make('distance_km')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('estimated_price')
                    ->money()
                    ->placeholder('-'),
                TextEntry::make('final_price')
                    ->money()
                    ->placeholder('-'),
                TextEntry::make('accepted_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('started_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('completed_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}

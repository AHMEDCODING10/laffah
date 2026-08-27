<?php

namespace App\Filament\Resources\CaptainProfiles\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class CaptainProfileInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('user_id')
                    ->numeric(),
                TextEntry::make('vehicle_type')
                    ->placeholder('-'),
                TextEntry::make('vehicle_model')
                    ->placeholder('-'),
                TextEntry::make('plate_number')
                    ->placeholder('-'),
                TextEntry::make('vehicle_color')
                    ->placeholder('-'),
                TextEntry::make('rating')
                    ->numeric(),
                IconEntry::make('is_online')
                    ->boolean(),
                IconEntry::make('is_verified')
                    ->boolean(),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}

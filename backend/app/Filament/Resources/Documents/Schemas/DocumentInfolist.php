<?php

namespace App\Filament\Resources\Documents\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class DocumentInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('captain_profile_id')
                    ->numeric(),
                TextEntry::make('type')
                    ->badge(),
                TextEntry::make('file_path'),
                TextEntry::make('status')
                    ->badge(),
                TextEntry::make('rejection_reason')
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

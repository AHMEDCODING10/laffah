<?php

namespace App\Filament\Resources\Transactions\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class TransactionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('wallet_id')
                    ->numeric(),
                TextEntry::make('trip_id')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('type')
                    ->badge(),
                TextEntry::make('amount')
                    ->numeric(),
                TextEntry::make('description')
                    ->placeholder('-'),
                TextEntry::make('reference_id')
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

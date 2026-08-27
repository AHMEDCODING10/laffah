<?php

namespace App\Filament\Resources\Transactions\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class TransactionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('wallet_id')
                    ->required()
                    ->numeric(),
                TextInput::make('trip_id')
                    ->numeric()
                    ->default(null),
                Select::make('type')
                    ->options(['credit' => 'Credit', 'debit' => 'Debit'])
                    ->required(),
                TextInput::make('amount')
                    ->required()
                    ->numeric(),
                TextInput::make('description')
                    ->default(null),
                TextInput::make('reference_id')
                    ->default(null),
            ]);
    }
}

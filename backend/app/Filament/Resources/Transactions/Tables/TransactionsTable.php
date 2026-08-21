<?php

namespace App\Filament\Resources\Transactions\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class TransactionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('wallet.user.name')
                    ->label('صاحب المحفظة')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('trip_id')
                    ->label('رقم الرحلة')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'deposit' => 'success',
                        'withdrawal' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('amount')
                    ->label('المبلغ')
                    ->formatStateUsing(fn ($state) => number_format($state, 2) . ' ر.ي')
                    ->sortable(),
                TextColumn::make('description')
                    ->label('الوصف')
                    ->searchable()
                    ->limit(30),
                TextColumn::make('reference_id')
                    ->label('المرجع')
                    ->searchable(),
                TextColumn::make('created_at')
                    ->label('تاريخ العملية')
                    ->dateTime('d M Y, h:i A')
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}

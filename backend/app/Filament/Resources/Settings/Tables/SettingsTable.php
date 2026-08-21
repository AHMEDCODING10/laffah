<?php

namespace App\Filament\Resources\Settings\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SettingsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('key')
                    ->label('المفتاح (Key)')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                TextColumn::make('value')
                    ->label('القيمة (Value)')
                    ->limit(30),
                TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color('info')
                    ->searchable(),
                TextColumn::make('group')
                    ->label('المجموعة')
                    ->badge()
                    ->color('secondary')
                    ->searchable(),
                TextColumn::make('updated_at')
                    ->label('آخر تحديث')
                    ->dateTime('d M Y')
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

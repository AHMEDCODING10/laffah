<?php

namespace App\Filament\Resources\CaptainProfiles\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CaptainProfilesTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('الاسم')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                TextColumn::make('vehicle_type')
                    ->label('نوع المركبة')
                    ->badge()
                    ->color('info')
                    ->searchable(),
                TextColumn::make('vehicle_model')
                    ->label('موديل المركبة')
                    ->searchable(),
                TextColumn::make('plate_number')
                    ->label('رقم اللوحة')
                    ->searchable(),
                TextColumn::make('rating')
                    ->label('التقييم')
                    ->formatStateUsing(fn ($state) => number_format($state, 1) . ' ⭐')
                    ->sortable(),
                IconColumn::make('is_online')
                    ->label('متصل')
                    ->boolean(),
                IconColumn::make('is_verified')
                    ->label('موثق')
                    ->boolean()
                    ->color(fn (string $state): string => $state ? 'success' : 'danger'),
                TextColumn::make('created_at')
                    ->label('تاريخ الانضمام')
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

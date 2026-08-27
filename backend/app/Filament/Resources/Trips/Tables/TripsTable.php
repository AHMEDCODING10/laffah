<?php

namespace App\Filament\Resources\Trips\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class TripsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.name')
                    ->label('العميل')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('captainProfile.user.name')
                    ->label('الكابتن')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'accepted' => 'info',
                        'started' => 'primary',
                        'completed' => 'success',
                        'cancelled' => 'danger',
                        default => 'gray',
                    }),
                TextColumn::make('type')
                    ->label('النوع')
                    ->badge()
                    ->color('secondary'),
                TextColumn::make('pickup_address')
                    ->label('نقطة الانطلاق')
                    ->searchable()
                    ->limit(20),
                TextColumn::make('dropoff_address')
                    ->label('نقطة الوصول')
                    ->searchable()
                    ->limit(20),
                TextColumn::make('distance_km')
                    ->label('المسافة')
                    ->formatStateUsing(fn ($state) => $state ? $state . ' كم' : '-'),
                TextColumn::make('final_price')
                    ->label('السعر النهائي')
                    ->formatStateUsing(fn ($state) => $state ? number_format($state, 2) . ' ر.ي' : '-')
                    ->sortable(),
                TextColumn::make('created_at')
                    ->toggleable(isToggledHiddenByDefault: true),
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

<?php

namespace App\Filament\Widgets;

use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use App\Models\Trip;

class LatestTrips extends BaseWidget
{
    protected static ?int $sort = 3;
    protected int | string | array $columnSpan = 'full';
    protected static ?string $heading = 'أحدث المشاوير';

    public function table(Table $table): Table
    {
        return $table
            ->query(Trip::query()->latest()->limit(5))
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('العميل')
                    ->searchable(),
                Tables\Columns\TextColumn::make('captain.user.name')
                    ->label('الكابتن')
                    ->searchable(),
                Tables\Columns\TextColumn::make('status')
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
                Tables\Columns\TextColumn::make('final_price')
                    ->label('السعر')
                    ->formatStateUsing(fn ($state) => $state ? number_format($state, 2) . ' ر.ي' : '-')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('تاريخ الطلب')
                    ->dateTime('d M Y, h:i A')
                    ->sortable(),
            ]);
    }
}

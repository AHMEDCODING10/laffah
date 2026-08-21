<?php

namespace App\Filament\Resources\Users\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class UsersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('الاسم')
                    ->searchable()
                    ->weight('bold'),
                TextColumn::make('email')
                    ->label('البريد الإلكتروني')
                    ->icon('heroicon-m-envelope')
                    ->searchable(),
                TextColumn::make('phone')
                    ->label('رقم الهاتف')
                    ->searchable(),
                TextColumn::make('roles.name')
                    ->label('الأدوار')
                    ->badge()
                    ->color('primary'),
                IconColumn::make('is_active')
                    ->label('نشط؟')
                    ->boolean(),
                TextColumn::make('created_at')
                    ->label('تاريخ التسجيل')
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

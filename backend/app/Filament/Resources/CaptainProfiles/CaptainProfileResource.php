<?php

namespace App\Filament\Resources\CaptainProfiles;

use App\Filament\Resources\CaptainProfiles\Pages\CreateCaptainProfile;
use App\Filament\Resources\CaptainProfiles\Pages\EditCaptainProfile;
use App\Filament\Resources\CaptainProfiles\Pages\ListCaptainProfiles;
use App\Filament\Resources\CaptainProfiles\Pages\ViewCaptainProfile;
use App\Filament\Resources\CaptainProfiles\Schemas\CaptainProfileForm;
use App\Filament\Resources\CaptainProfiles\Schemas\CaptainProfileInfolist;
use App\Filament\Resources\CaptainProfiles\Tables\CaptainProfilesTable;
use App\Models\CaptainProfile;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class CaptainProfileResource extends Resource
{
    protected static ?string $model = CaptainProfile::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return CaptainProfileForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return CaptainProfileInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CaptainProfilesTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCaptainProfiles::route('/'),
            'create' => CreateCaptainProfile::route('/create'),
            'view' => ViewCaptainProfile::route('/{record}'),
            'edit' => EditCaptainProfile::route('/{record}/edit'),
        ];
    }
}

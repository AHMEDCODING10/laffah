<?php

namespace App\Filament\Resources\CaptainProfiles\Pages;

use App\Filament\Resources\CaptainProfiles\CaptainProfileResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListCaptainProfiles extends ListRecords
{
    protected static string $resource = CaptainProfileResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}

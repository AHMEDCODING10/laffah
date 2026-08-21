<?php

namespace App\Filament\Resources\CaptainProfiles\Pages;

use App\Filament\Resources\CaptainProfiles\CaptainProfileResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewCaptainProfile extends ViewRecord
{
    protected static string $resource = CaptainProfileResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}

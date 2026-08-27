<?php

namespace App\Filament\Resources\CaptainProfiles\Pages;

use App\Filament\Resources\CaptainProfiles\CaptainProfileResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditCaptainProfile extends EditRecord
{
    protected static string $resource = CaptainProfileResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}

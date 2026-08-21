<?php

namespace App\Filament\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use App\Models\User;
use App\Models\CaptainProfile;
use App\Models\Trip;

class StatsOverview extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make('العملاء', User::whereDoesntHave('roles', function($q) {
                $q->where('name', 'captain')->orWhere('name', 'admin');
            })->count())
                ->description('إجمالي العملاء المسجلين')
                ->descriptionIcon('heroicon-m-users')
                ->color('success'),
            
            Stat::make('الكباتن', CaptainProfile::count())
                ->description('إجمالي الكباتن المسجلين')
                ->descriptionIcon('heroicon-m-truck')
                ->color('info'),
                
            Stat::make('المشاوير المكتملة', Trip::where('status', 'completed')->count())
                ->description('إجمالي المشاوير الناجحة')
                ->descriptionIcon('heroicon-m-check-badge')
                ->color('primary'),
        ];
    }
}

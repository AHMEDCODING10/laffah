<?php

namespace App\Filament\Widgets;

use Filament\Widgets\ChartWidget;
use App\Models\Trip;
use Carbon\Carbon;

class TripsChart extends ChartWidget
{
    protected ?string $heading = 'معدل المشاوير (آخر 7 أيام)';
    protected static ?int $sort = 2;

    protected function getData(): array
    {
        $data = [];
        $labels = [];
        
        for ($i = 6; $i >= 0; $i--) {
            $date = Carbon::now()->subDays($i);
            $labels[] = $date->translatedFormat('l'); // Day name in Arabic if locale is ar
            
            $data[] = Trip::whereDate('created_at', $date->toDateString())->count();
        }

        return [
            'datasets' => [
                [
                    'label' => 'المشاوير',
                    'data' => $data,
                    'borderColor' => '#f59e0b', // Amber 500
                    'fill' => true,
                ],
            ],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}

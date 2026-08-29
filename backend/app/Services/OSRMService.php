<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OSRMService
{
    /**
     * Get the base URL for OSRM, either from config or default to public server.
     */
    protected function getBaseUrl(): string
    {
        return config('services.osrm.url', 'http://router.project-osrm.org');
    }

    /**
     * Get driving route distance (in km) and duration (in minutes) between two coordinates.
     *
     * @param float $lat1
     * @param float $lng1
     * @param float $lat2
     * @param float $lng2
     * @return array|null Returns ['distance' => km, 'duration' => minutes] or null on failure.
     */
    public function getRouteDetails(float $lat1, float $lng1, float $lat2, float $lng2): ?array
    {
        try {
            $baseUrl = $this->getBaseUrl();
            // OSRM format is {longitude},{latitude}
            $url = "{$baseUrl}/route/v1/driving/{$lng1},{$lat1};{$lng2},{$lat2}";
            
            $response = Http::timeout(5)->get($url, [
                'overview' => 'false',
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                if (isset($data['routes'][0])) {
                    $route = $data['routes'][0];
                    return [
                        'distance' => round($route['distance'] / 1000, 2), // convert meters to km
                        'duration' => round($route['duration'] / 60, 2),   // convert seconds to minutes
                    ];
                }
            }
            
            Log::warning("OSRM API failed or returned unexpected format.", ['response' => $response->body()]);
            return null;
        } catch (\Exception $e) {
            Log::error("OSRM API Exception: " . $e->getMessage());
            return null;
        }
    }
}

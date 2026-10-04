<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;

class OSRMService
{
    const CACHE_TTL_SECONDS = 86400; // 24 hours
    const TIMEOUT_SECONDS = 2; // Strict non-blocking limit

    protected function getBaseUrl(): string
    {
        return config('services.osrm.url', 'https://router.project-osrm.org');
    }

    /**
     * Get driving route distance (in km) and duration (in minutes) for single or multi-stop routes.
     *
     * @param array<array{lat: float, lng: float}> $coordinates Array of sequentially ordered points
     * @return array{distance: float, duration: float, is_fallback: bool}
     */
    public function getMultiPointRouteDetails(array $coordinates): array
    {
        if (count($coordinates) < 2) {
            return ['distance' => 1.0, 'duration' => 3.0, 'is_fallback' => true];
        }

        // 1. Build normalized cache key rounded to ~100m precision (3 decimal places)
        $cacheSegments = [];
        $urlSegments = [];
        foreach ($coordinates as $pt) {
            $rLat = round((float)$pt['lat'], 3);
            $rLng = round((float)$pt['lng'], 3);
            $cacheSegments[] = "{$rLat},{$rLng}";
            $urlSegments[] = "{$pt['lng']},{$pt['lat']}";
        }
        $cacheKey = 'osrm_route_' . md5(implode(';', $cacheSegments));

        return Cache::remember($cacheKey, self::CACHE_TTL_SECONDS, function () use ($urlSegments, $coordinates) {
            try {
                $coordString = implode(';', $urlSegments);
                $url = "{$this->getBaseUrl()}/route/v1/driving/{$coordString}";

                $response = Http::timeout(self::TIMEOUT_SECONDS)
                    ->retry(1, 100)
                    ->get($url, [
                        'overview' => 'false',
                        'steps' => 'false',
                    ]);

                if ($response->successful()) {
                    $data = $response->json();
                    if (!empty($data['routes'][0])) {
                        $route = $data['routes'][0];
                        return [
                            'distance' => round((float)($route['distance'] / 1000.0), 2),
                            'duration' => round((float)($route['duration'] / 60.0), 2),
                            'is_fallback' => false,
                        ];
                    }
                }

                Log::warning("OSRM API degraded or slow, triggering immediate mathematical fallback.");
            } catch (\Throwable $e) {
                Log::warning("OSRM Service exception: " . $e->getMessage() . " -> using Haversine curve fallback.");
            }

            return $this->calculateMathematicalFallback($coordinates);
        });
    }

    /**
     * Backward-compatible two-point signature
     */
    public function getRouteDetails(float $lat1, float $lng1, float $lat2, float $lng2): ?array
    {
        return $this->getMultiPointRouteDetails([
            ['lat' => $lat1, 'lng' => $lng1],
            ['lat' => $lat2, 'lng' => $lng2],
        ]);
    }

    /**
     * Robust mathematical fallback using cumulative Haversine multiplied by Sana'a road tortuosity factor (1.35x)
     */
    protected function calculateMathematicalFallback(array $coordinates): array
    {
        $totalDistance = 0.0;
        for ($i = 0; $i < count($coordinates) - 1; $i++) {
            $totalDistance += \App\Helpers\GeoHelper::haversineDistance(
                (float)$coordinates[$i]['lat'],
                (float)$coordinates[$i]['lng'],
                (float)$coordinates[$i + 1]['lat'],
                (float)$coordinates[$i + 1]['lng']
            );
        }

        // Apply real-world road network curvature factor for Yemeni mountain/urban topography
        $roadDistanceKm = round(max(1.0, $totalDistance * 1.35), 2);
        // Average urban motorcycle speed in Sana'a ~22 km/h
        $durationMinutes = round(max(2.0, ($roadDistanceKm / 22.0) * 60.0), 1);

        return [
            'distance' => $roadDistanceKm,
            'duration' => $durationMinutes,
            'is_fallback' => true,
        ];
    }
}

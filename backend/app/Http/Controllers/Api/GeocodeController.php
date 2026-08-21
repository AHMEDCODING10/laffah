<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class GeocodeController extends Controller
{
    // ─── Yemen Geographic Constants ────────────────────────────────────────────

    /** مركز صنعاء — يُستخدم كنقطة ترجيح لـ Photon API */
    const SANAA_LAT = 15.3694;
    const SANAA_LON = 44.1910;

    /** الإطار الحدودي لليمن (Bounding Box) — يُستخدم لفلترة النتائج */
    const YEMEN_BBOX = [
        'min_lat' => 12.1,
        'max_lat' => 19.0,
        'min_lon' => 41.5,
        'max_lon' => 54.5,
    ];

    /** أشهر المواقع والمعالم في صنعاء واليمن كاحتياط سريع */
    const POPULAR_YEMEN_PLACES = [
        ['name' => 'ميدان التحرير', 'display_name' => 'ميدان التحرير - وسط العاصمة صنعاء', 'lat' => 15.3556, 'lon' => 44.2081],
        ['name' => 'ميدان السبعين', 'display_name' => 'ميدان السبعين - جامع الصالح، صنعاء', 'lat' => 15.3275, 'lon' => 44.2078],
        ['name' => 'باب اليمن', 'display_name' => 'باب اليمن - صنعاء القديمة', 'lat' => 15.3524, 'lon' => 44.2147],
        ['name' => 'شارع حدة', 'display_name' => 'شارع حدة - الحي التجاري، صنعاء', 'lat' => 15.3347, 'lon' => 44.1872],
        ['name' => 'شارع الزبيري', 'display_name' => 'شارع الزبيري - وسط العاصمة صنعاء', 'lat' => 15.3482, 'lon' => 44.2013],
        ['name' => 'جامعة صنعاء', 'display_name' => 'جامعة صنعاء - مذبح / الدائري الغربي', 'lat' => 15.3694, 'lon' => 44.1806],
        ['name' => 'شارع الستين الجنوبي', 'display_name' => 'شارع الستين الجنوبي - عطان / فج عطان', 'lat' => 15.3210, 'lon' => 44.1750],
        ['name' => 'شارع الستين الشمالي', 'display_name' => 'شارع الستين الشمالي - مذبح / الستين', 'lat' => 15.3850, 'lon' => 44.1720],
        ['name' => 'شارع تعز', 'display_name' => 'شارع تعز - شميلة / دار سلم، صنعاء', 'lat' => 15.3120, 'lon' => 44.2250],
        ['name' => 'حي الأصبحي', 'display_name' => 'الأصبحي - صنعاء', 'lat' => 15.3050, 'lon' => 44.2150],
        ['name' => 'مطار صنعاء الدولي', 'display_name' => 'مطار صنعاء الدولي - بني الحارث', 'lat' => 15.4762, 'lon' => 44.2197],
        ['name' => 'مستشفى الثورة العام', 'display_name' => 'مستشفى الثورة العام - نقم، صنعاء', 'lat' => 15.3450, 'lon' => 44.2220],
    ];

    // ─── Forward Geocoding ─────────────────────────────────────────────────────

    /**
     * Search for a location by query string (Forward Geocoding).
     * Biased to Sana'a, Yemen — results outside Yemen bounding box are filtered out.
     */
    public function search(Request $request)
    {
        $request->validate([
            'q' => 'required|string|min:2|max:200',
        ]);

        $query = trim($request->input('q'));

        try {
            $response = Http::timeout(8)
                ->withHeaders(['User-Agent' => 'LaffahApp/1.0'])
                ->get('https://photon.komoot.io/api/', [
                    'q'     => $query,
                    'lat'   => self::SANAA_LAT,   // ترجيح صنعاء
                    'lon'   => self::SANAA_LON,   // ترجيح صنعاء
                    'limit' => 15,                // نطلب عدداً كافياً للفلترة
                ]);

            if ($response->successful()) {
                $features = $response->json('features') ?? [];

                // 1. فلترة النتائج داخل الإطار الجغرافي لليمن
                $yemeni = array_values(array_filter($features, fn($f) => $this->isInsideYemen(
                    $f['geometry']['coordinates'][1] ?? 0,
                    $f['geometry']['coordinates'][0] ?? 0,
                )));

                if (count($yemeni) > 0) {
                    return response()->json(array_map(fn($f) => $this->mapFeature($f), array_slice($yemeni, 0, 8)));
                }

                if (count($features) > 0) {
                    return response()->json(array_map(fn($f) => $this->mapFeature($f), array_slice($features, 0, 6)));
                }
            }
        } catch (\Exception $e) {
            // Log and fallback to local matches
        }

        // 2. Fallback: مطابقة محلية سريعة للأماكن اليمنية الشائعة
        $localMatches = array_values(array_filter(self::POPULAR_YEMEN_PLACES, function ($place) use ($query) {
            return mb_stripos($place['name'], $query) !== false || mb_stripos($place['display_name'], $query) !== false;
        }));

        if (count($localMatches) > 0) {
            return response()->json($localMatches);
        }

        return response()->json(array_slice(self::POPULAR_YEMEN_PLACES, 0, 5));
    }

    // ─── Reverse Geocoding ──────────────────────────────────────────────────────

    /**
     * Get address from lat/lon (Reverse Geocoding) via Photon.
     */
    public function reverse(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric|between:-90,90',
            'lon' => 'required|numeric|between:-180,180',
        ]);

        $lat = (float) $request->input('lat');
        $lon = (float) $request->input('lon');

        try {
            $response = Http::timeout(8)
                ->withHeaders(['User-Agent' => 'LaffahApp/1.0'])
                ->get('https://photon.komoot.io/reverse', [
                    'lat' => $lat,
                    'lon' => $lon,
                ]);

            if ($response->successful()) {
                $features = $response->json('features') ?? [];

                if (count($features) > 0) {
                    $f       = $features[0];
                    $props   = $f['properties'] ?? [];
                    $name    = $props['name']   ?? '';
                    $street  = $props['street'] ?? '';
                    $city    = $props['city']   ?? $props['county'] ?? '';
                    $display = $this->buildDisplay($name, $street, $city);

                    return response()->json([
                        'name'         => $name ?: $display,
                        'display_name' => $display ?: 'موقع محدد',
                        'lat'          => $f['geometry']['coordinates'][1] ?? $lat,
                        'lon'          => $f['geometry']['coordinates'][0] ?? $lon,
                    ]);
                }
            }
        } catch (\Exception $e) {
            // fallback
        }

        // لا توجد نتيجة من Photon — نُعيد الإحداثيات كما هي
        return response()->json([
            'name'         => 'موقع محدد على الخريطة',
            'display_name' => 'صنعاء، الجمهورية اليمنية',
            'lat'          => $lat,
            'lon'          => $lon,
        ]);
    }

    // ─── Private Helpers ────────────────────────────────────────────────────────

    /**
     * هل الإحداثيات داخل الإطار الجغرافي لليمن؟
     */
    private function isInsideYemen(float $lat, float $lon): bool
    {
        return $lat >= self::YEMEN_BBOX['min_lat']
            && $lat <= self::YEMEN_BBOX['max_lat']
            && $lon >= self::YEMEN_BBOX['min_lon']
            && $lon <= self::YEMEN_BBOX['max_lon'];
    }

    /**
     * تحويل Feature من Photon إلى تنسيق التطبيق.
     */
    private function mapFeature(array $f): array
    {
        $props   = $f['properties'] ?? [];
        $name    = $props['name']    ?? '';
        $street  = $props['street']  ?? '';
        $city    = $props['city']    ?? $props['county'] ?? $props['state'] ?? 'صنعاء';
        $display = $this->buildDisplay($name, $street, $city);

        return [
            'name'         => $name ?: $display,
            'display_name' => $display,
            'lat'          => $f['geometry']['coordinates'][1] ?? 0,
            'lon'          => $f['geometry']['coordinates'][0] ?? 0,
        ];
    }

    /**
     * بناء نص العنوان القابل للعرض.
     */
    private function buildDisplay(string $name, string $street, string $city): string
    {
        $parts = array_filter(array_unique([$name, $street, $city]), fn($p) => $p !== '');
        return implode(' - ', $parts) ?: 'موقع في اليمن';
    }
}
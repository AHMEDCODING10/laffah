<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\CaptainProfile;
use App\Models\Trip;
use App\Models\Parcel;
use App\Models\Wallet;
use App\Models\Transaction;
use App\Services\WalletService;
use App\Services\TripService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Artisan;
use Carbon\Carbon;

echo "====================================================\n";
echo "🧪 PHASE 2 VERIFICATION: TiDB, Escrow & Spatial Bounding Box\n";
echo "====================================================\n\n";

// [TEST 2.1]: Verify TiDB Composite Indexes exist in live database
echo "[TEST 2.1] Verifying Composite Indexes in TiDB Cloud...\n";
$tripIndexes = collect(DB::select("SHOW INDEX FROM trips"))->pluck('Key_name')->unique()->toArray();
$parcelIndexes = collect(DB::select("SHOW INDEX FROM parcels"))->pluck('Key_name')->unique()->toArray();
$txIndexes = collect(DB::select("SHOW INDEX FROM transactions"))->pluck('Key_name')->unique()->toArray();
$walletIndexes = collect(DB::select("SHOW INDEX FROM wallets"))->pluck('Key_name')->unique()->toArray();

assert(in_array('idx_trips_dispatch_spatial', $tripIndexes), 'trips.idx_trips_dispatch_spatial missing!');
assert(in_array('idx_trips_captain_status_created', $tripIndexes), 'trips.idx_trips_captain_status_created missing!');
assert(in_array('idx_parcels_dispatch_spatial', $parcelIndexes), 'parcels.idx_parcels_dispatch_spatial missing!');
assert(in_array('idx_tx_wallet_created', $txIndexes), 'transactions.idx_tx_wallet_created missing!');
assert(in_array('uniq_wallets_user_id', $walletIndexes), 'wallets.uniq_wallets_user_id missing!');
echo "  ✅ All 5 critical TiDB composite & unique indexes verified active in TiDB.\n\n";

// [TEST 2.2]: Verify Wallet Escrow & Available Balance Logic
echo "[TEST 2.2] Testing Wallet Escrow & Available Balance...\n";
$testUser = User::firstOrCreate(
    ['phone' => '779998811'],
    ['name' => 'اختبار المحفظة والضمان', 'email' => 'escrow_test@laffah.com', 'password' => bcrypt('password123')]
);
$wallet = Wallet::updateOrCreate(
    ['user_id' => $testUser->id],
    ['balance' => 10000.0, 'held_balance' => 3000.0, 'currency' => 'YER']
);

$walletService = app(WalletService::class);
$balanceData = $walletService->getBalance($testUser->id);

assert($balanceData['balance'] === 10000.0, 'Balance mismatch');
assert($balanceData['held_balance'] === 3000.0, 'Held balance mismatch');
assert($balanceData['availableBalance'] === 7000.0, 'Available balance should be 7000 (10000 - 3000)');
echo "  ✅ Wallet getBalance accurately computes: Total: 10,000 YER, Held: 3,000 YER, Available: 7,000 YER\n\n";

// [TEST 2.3]: Test Escrow Release on Auto-Cancel Timeout
echo "[TEST 2.3] Testing Escrow Release on Auto-Cancel Timeout (requests:expire-pending)...\n";
Trip::where('user_id', $testUser->id)->where('status', 'pending')->delete();
Parcel::where('user_id', $testUser->id)->where('status', 'pending')->delete();

$escrowTrip = Trip::create([
    'user_id' => $testUser->id,
    'status' => 'pending',
    'type' => 'ride',
    'payment_method' => 'wallet',
    'pickup_address' => 'ميدان التحرير، صنعاء',
    'pickup_latitude' => 15.3556,
    'pickup_longitude' => 44.2078,
    'dropoff_address' => 'شارع حدة، صنعاء',
    'dropoff_latitude' => 15.3211,
    'dropoff_longitude' => 44.1955,
    'estimated_price' => 1200.0,
    'final_price' => 1200.0,
]);
DB::table('trips')->where('id', $escrowTrip->id)->update(['created_at' => Carbon::now()->subMinutes(5)]);

// Place Escrow lock on wallet
$wallet->held_balance = 3000.0 + 1200.0;
$wallet->save();

echo "  Initial held balance before expiration: {$wallet->fresh()->held_balance} YER\n";

// Run expiration command
Artisan::call('requests:expire-pending');

$escrowTrip->refresh();
$wallet->refresh();

assert($escrowTrip->status === 'cancelled', 'Trip should be cancelled');
assert($escrowTrip->cancellation_reason === 'timeout_no_captain', 'Cancellation reason mismatch');
assert((float)$wallet->held_balance === 3000.0, "Held balance should be refunded to 3000, got {$wallet->held_balance}");
echo "  ✅ Auto-cancel timeout cleanly released 1,200 YER from held_balance back to usable funds.\n\n";

// [TEST 2.4]: Test Spatial Bounding Box in TripController nearbyRequests
echo "[TEST 2.4] Testing Spatial Bounding Box in TripController nearbyRequests...\n";
// Create a nearby trip in Sana'a (< 5km away)
$sanaaTrip = Trip::create([
    'user_id' => $testUser->id,
    'status' => 'pending',
    'type' => 'ride',
    'payment_method' => 'cash',
    'pickup_address' => 'جامعة صنعاء',
    'pickup_latitude' => 15.3694,
    'pickup_longitude' => 44.1910,
    'dropoff_address' => 'باب اليمن',
    'dropoff_latitude' => 15.3521,
    'dropoff_longitude' => 44.2014,
    'estimated_price' => 600.0,
    'final_price' => 600.0,
    'created_at' => Carbon::now(),
]);

// Create a far-away trip in Aden (~300km away)
$adenTrip = Trip::create([
    'user_id' => $testUser->id,
    'status' => 'pending',
    'type' => 'ride',
    'payment_method' => 'cash',
    'pickup_address' => 'خور مكسر، عدن',
    'pickup_latitude' => 12.8258,
    'pickup_longitude' => 45.0345,
    'dropoff_address' => 'كريتر، عدن',
    'dropoff_latitude' => 12.7797,
    'dropoff_longitude' => 45.0367,
    'estimated_price' => 800.0,
    'final_price' => 800.0,
    'created_at' => Carbon::now(),
]);

// Create test captain in Sana'a
$captainUser = User::firstOrCreate(
    ['phone' => '779998822'],
    ['name' => 'كابتن صنعاء التجريبي', 'email' => 'captain_sanaa@laffah.com', 'password' => bcrypt('password123')]
);
$captainProfile = CaptainProfile::firstOrCreate(
    ['user_id' => $captainUser->id],
    ['latitude' => 15.3690, 'longitude' => 44.1915, 'is_online' => true]
);

$request = \Illuminate\Http\Request::create('/api/trips/nearby', 'GET', [
    'lat' => 15.3690,
    'lng' => 44.1915,
]);
$request->setUserResolver(fn() => $captainUser);

$controller = app(\App\Http\Controllers\Api\TripController::class);
$response = $controller->nearbyRequests($request);
$data = json_decode($response->getContent(), true)['data'];

$returnedIds = collect($data)->pluck('id')->map(fn($id) => (int)$id)->toArray();

assert(in_array($sanaaTrip->id, $returnedIds), "Sana'a trip #{$sanaaTrip->id} should be returned");
assert(!in_array($adenTrip->id, $returnedIds), "Aden trip #{$adenTrip->id} must NOT be returned (excluded by Bounding Box)");
echo "  ✅ Spatial Bounding Box correctly captured Sana'a trip #{$sanaaTrip->id} and discarded Aden trip #{$adenTrip->id}.\n\n";

// Cleanup test records
$sanaaTrip->delete();
$adenTrip->delete();
$escrowTrip->delete();

echo "====================================================\n";
echo "🎉 ALL PHASE 2 TESTS PASSED 100% WITH ZERO ERRORS!\n";
echo "====================================================\n";

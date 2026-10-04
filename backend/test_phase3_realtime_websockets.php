<?php

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Trip;
use App\Models\Parcel;
use App\Models\CaptainProfile;
use App\Events\TripStatusUpdated;
use App\Events\ParcelStatusUpdated;
use App\Events\TripRejectedByCaptain;
use App\Events\CaptainLocationUpdated;
use Illuminate\Support\Facades\Broadcast;

echo "=======================================================\n";
echo "🧪 LAFFAH PLATFORM - PHASE 3 REAL-TIME WEBSOCKET AUDIT\n";
echo "=======================================================\n\n";

$errors = 0;

function assertCondition($name, $condition) {
    global $errors;
    if ($condition) {
        echo "✅ PASS: $name\n";
    } else {
        echo "❌ FAIL: $name\n";
        $errors++;
    }
}

// 1. Verify TripStatusUpdated broadcast payload
echo "--- 1. Testing TripStatusUpdated Payload ---\n";
$user = User::first();
$captain = CaptainProfile::first();

if (!$user || !$captain) {
    echo "⚠️ Need existing user and captain to run test.\n";
    exit(1);
}

$dummyTrip = new Trip([
    'user_id' => $user->id,
    'captain_profile_id' => $captain->id,
    'status' => 'accepted',
    'pickup_latitude' => 15.3500,
    'pickup_longitude' => 44.2000,
    'dropoff_latitude' => 15.3600,
    'dropoff_longitude' => 44.2100,
    'pickup_address' => 'Sanaa Test Pickup',
    'dropoff_address' => 'Sanaa Test Dropoff',
    'fare' => 1500,
    'payment_method' => 'wallet',
]);
$dummyTrip->id = 999991;
$dummyTrip->setRelation('captain', $captain);

$tripEvent = new TripStatusUpdated($dummyTrip);
$tripPayload = $tripEvent->broadcastWith();

assertCondition("TripStatusUpdated contains captain_id", isset($tripPayload['captain_id']) && $tripPayload['captain_id'] == (string)$captain->id);
assertCondition("TripStatusUpdated contains captainId", isset($tripPayload['captainId']) && $tripPayload['captainId'] == (string)$captain->id);
assertCondition("TripStatusUpdated contains vehicle_plate", isset($tripPayload['vehicle_plate']));
assertCondition("TripStatusUpdated contains plate_number", isset($tripPayload['plate_number']));
assertCondition("TripStatusUpdated broadcasts on private-trip.999991", $tripEvent->broadcastOn()[0]->name === 'private-trip.999991');

// 2. Verify ParcelStatusUpdated broadcast payload and multi-channel broadcast
echo "\n--- 2. Testing ParcelStatusUpdated Payload & Channels ---\n";
$dummyParcel = new Parcel([
    'user_id' => $user->id,
    'captain_profile_id' => $captain->id,
    'tracking_code' => 'LF-TEST-999',
    'status' => 'picked_up',
    'pickup_address' => 'Sanaa Pickup',
    'dropoff_address' => 'Sanaa Dropoff',
    'price' => 1200,
]);
$dummyParcel->id = 888881;
$dummyParcel->setRelation('captain', $captain);

$parcelEvent = new ParcelStatusUpdated($dummyParcel);
$parcelPayload = $parcelEvent->broadcastWith();
$parcelChannels = array_map(fn($c) => $c->name, $parcelEvent->broadcastOn());

assertCondition("ParcelStatusUpdated contains captain_id", isset($parcelPayload['captain_id']) && $parcelPayload['captain_id'] == (string)$captain->id);
assertCondition("ParcelStatusUpdated contains captainId", isset($parcelPayload['captainId']) && $parcelPayload['captainId'] == (string)$captain->id);
assertCondition("ParcelStatusUpdated broadcasts on private-trip.888881", in_array('private-trip.888881', $parcelChannels));
assertCondition("ParcelStatusUpdated broadcasts on private-trip.LF-TEST-999", in_array('private-trip.LF-TEST-999', $parcelChannels));

// 3. Verify TripRejectedByCaptain event
echo "\n--- 3. Testing TripRejectedByCaptain Event ---\n";
$rejectEvent = new TripRejectedByCaptain("999991", (string)$captain->id);
$rejectChannels = array_map(fn($c) => $c->name, $rejectEvent->broadcastOn());
$rejectPayload = $rejectEvent->broadcastWith();

assertCondition("TripRejectedByCaptain broadcasts on private-captain.{$captain->id}", in_array('private-captain.' . $captain->id, $rejectChannels));
assertCondition("TripRejectedByCaptain broadcastAs is TripNoLongerAvailable", $rejectEvent->broadcastAs() === 'TripNoLongerAvailable');
assertCondition("TripRejectedByCaptain payload event_type is trip_no_longer_available", ($rejectPayload['event_type'] ?? '') === 'trip_no_longer_available');

// 4. Verify CaptainLocationUpdated event
echo "\n--- 4. Testing CaptainLocationUpdated Event ---\n";
$locEvent = new CaptainLocationUpdated($captain->id, 15.3520, 44.2050, 95.5, 45.0);
$locChannels = array_map(fn($c) => $c->name, $locEvent->broadcastOn());
$locPayload = $locEvent->broadcastWith();

assertCondition("CaptainLocationUpdated broadcasts on private-captain-location.{$captain->id}", in_array('private-captain-location.' . $captain->id, $locChannels));
assertCondition("CaptainLocationUpdated broadcasts on private-captains-locations", in_array('private-captains-locations', $locChannels));
assertCondition("CaptainLocationUpdated payload has lat & latitude", isset($locPayload['lat']) && isset($locPayload['latitude']));
assertCondition("CaptainLocationUpdated payload has lng & longitude", isset($locPayload['lng']) && isset($locPayload['longitude']));
assertCondition("CaptainLocationUpdated payload has heading & speed", $locPayload['heading'] == 95.5 && $locPayload['speed'] == 45.0);

echo "\n=======================================================\n";
if ($errors === 0) {
    echo "🎉 ALL PHASE 3 REAL-TIME WEBSOCKET AUDIT CHECKS PASSED 100%!\n";
} else {
    echo "❌ TOTAL FAILED CHECKS: $errors\n";
    exit(1);
}
echo "=======================================================\n";

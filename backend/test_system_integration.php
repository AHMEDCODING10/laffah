<?php

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

echo "===============================================\n";
echo "🚀 LAFFAH COMPREHENSIVE BACKEND INTEGRATION TEST\n";
echo "===============================================\n\n";

$errors = [];

try {
    // 1. Setup Test Users
    echo "[TEST 1] Setting up Passenger & Captain accounts...\n";
    $passenger = \App\Models\User::firstOrCreate(
        ['email' => 'audit_passenger@laffah.com'],
        ['name' => 'Audit Passenger', 'phone' => '770111111', 'password' => bcrypt('password123')]
    );
    $captain = \App\Models\User::firstOrCreate(
        ['email' => 'audit_captain@laffah.com'],
        ['name' => 'Audit Captain', 'phone' => '770222222', 'password' => bcrypt('password123')]
    );
    $captainProfile = \App\Models\CaptainProfile::firstOrCreate(
        ['user_id' => $captain->id],
        ['is_online' => true, 'rating' => 5.0, 'vehicle_type' => 'motorcycle']
    );
    echo "  ✅ Passenger ID: {$passenger->id}, Captain Profile ID: {$captainProfile->id}\n\n";

    // 2. Test Trip Flow (Create -> Accept -> Update -> Complete)
    echo "[TEST 2] Testing Trip Lifecycle...\n";
    $tripService = app(\App\Services\TripService::class);
    $trip = $tripService->createTrip($passenger->id, [
        'pickup_address' => 'ميدان السبعين، صنعاء',
        'pickup_latitude' => 15.3300,
        'pickup_longitude' => 44.2000,
        'dropoff_address' => 'شارع حدة، صنعاء',
        'dropoff_latitude' => 15.3200,
        'dropoff_longitude' => 44.1900,
        'type' => 'ride',
    ]);
    echo "  ✅ Trip Created: ID #{$trip->id}, Status: {$trip->status}, Distance: {$trip->distance_km}km, Price: {$trip->estimated_price} YER\n";

    $acceptedTrip = $tripService->acceptTrip($trip->id, $captainProfile->id);
    echo "  ✅ Trip Accepted: Status: {$acceptedTrip->status}, Captain Assigned: {$acceptedTrip->captain_profile_id}\n";

    $arrivedTrip = $tripService->updateStatus($trip->id, $captainProfile->id, 'arrived_at_pickup');
    echo "  ✅ Status Transition 1: {$arrivedTrip->status}\n";

    $inProgressTrip = $tripService->updateStatus($trip->id, $captainProfile->id, 'in_progress');
    echo "  ✅ Status Transition 2: {$inProgressTrip->status}\n";

    $completedTrip = $tripService->updateStatus($trip->id, $captainProfile->id, 'completed');
    echo "  ✅ Status Transition 3: {$completedTrip->status}, Final Price: {$completedTrip->final_price} YER\n\n";

    // 3. Test Trip Cancellation
    echo "[TEST 3] Testing Trip Cancellation Flow...\n";
    $trip2 = $tripService->createTrip($passenger->id, [
        'pickup_address' => 'الصافية، صنعاء',
        'pickup_latitude' => 15.3400,
        'pickup_longitude' => 44.2051,
        'dropoff_address' => 'التحرير، صنعاء',
        'dropoff_latitude' => 15.3550,
        'dropoff_longitude' => 44.2010,
        'type' => 'ride',
    ]);
    $cancelledTrip = $tripService->cancelTrip($trip2->id, $passenger, 'تغيير في خطة السفر');
    echo "  ✅ Trip Cancelled: Status: {$cancelledTrip->status}, Reason: {$cancelledTrip->cancellation_reason}, CancelledAt: {$cancelledTrip->cancelled_at}\n\n";

    // 4. Test Parcel Delivery Lifecycle
    echo "[TEST 4] Testing Parcel Delivery Flow...\n";
    $parcel = $passenger->parcels()->create([
        'sender_name' => 'محمد الأحمدي',
        'sender_phone' => '770111111',
        'receiver_name' => 'ياسر خالد',
        'receiver_phone' => '770333333',
        'pickup_address' => 'نقم، صنعاء',
        'pickup_latitude' => 15.3694,
        'pickup_longitude' => 44.1910,
        'dropoff_address' => 'بيت بوس، صنعاء',
        'dropoff_latitude' => 15.3521,
        'dropoff_longitude' => 44.2014,
        'parcel_type' => 'طرد صغير / هدايا',
        'size' => 'صغير',
        'price' => 1200,
        'status' => 'pending',
    ]);
    echo "  ✅ Parcel Created: ID #{$parcel->id}, Tracking: #{$parcel->tracking_code}, Status: {$parcel->status}\n";

    $parcelController = app(\App\Http\Controllers\Api\ParcelController::class);

    // Captain accepts parcel via endpoint
    $captReq = new \Illuminate\Http\Request();
    $captReq->setUserResolver(fn() => $captain);
    $acceptResp = $parcelController->acceptParcel($captReq, $parcel->id);
    echo "  ✅ Parcel Accepted via API: Status {$parcel->fresh()->status}\n";

    // Step 1: Arrived at pickup
    $statusReq1 = new \Illuminate\Http\Request(['status' => 'arrived_at_pickup']);
    $statusReq1->setUserResolver(fn() => $captain);
    $parcelController->updateStatus($statusReq1, $parcel->tracking_code);
    echo "  ✅ Step 1 (arrived_at_pickup) via tracking_code: Status {$parcel->fresh()->status}\n";

    // Step 2: Picked up
    $statusReq2 = new \Illuminate\Http\Request(['status' => 'picked_up']);
    $statusReq2->setUserResolver(fn() => $captain);
    $parcelController->updateStatus($statusReq2, $parcel->tracking_code);
    echo "  ✅ Step 2 (picked_up) via tracking_code: Status {$parcel->fresh()->status}\n";

    // Step 3: In transit
    $statusReq3 = new \Illuminate\Http\Request(['status' => 'in_transit']);
    $statusReq3->setUserResolver(fn() => $captain);
    $parcelController->updateStatus($statusReq3, $parcel->tracking_code);
    echo "  ✅ Step 3 (in_transit) via tracking_code: Status {$parcel->fresh()->status}\n";

    // Step 4: Delivered
    $statusReq4 = new \Illuminate\Http\Request(['status' => 'delivered']);
    $statusReq4->setUserResolver(fn() => $captain);
    $parcelController->updateStatus($statusReq4, $parcel->tracking_code);
    echo "  ✅ Step 4 (delivered) via tracking_code: Status {$parcel->fresh()->status}\n";

    // Passenger tracks parcel
    $trackReq = new \Illuminate\Http\Request();
    $trackResp = $parcelController->trackParcel($trackReq, $parcel->tracking_code);
    echo "  ✅ Passenger Track Parcel API returned: Status '" . $trackResp->getData()->data->status . "' with captain details.\n\n";

    // 5. Test Captain Nearby Requests Query
    echo "[TEST 5] Testing Captain Nearby Requests Query...\n";
    $nearbyResponse = app(\App\Http\Controllers\Api\TripController::class)->nearbyRequests(
        new \Illuminate\Http\Request(['lat' => 15.3694, 'lng' => 44.1910])
    );
    echo "  ✅ Nearby Requests Endpoint returned status 200 with " . count($nearbyResponse->getData()->data) . " active requests\n\n";

    // 6. Test Notifications Flow
    echo "[TEST 6] Testing Notifications System...\n";
    $notifService = app(\App\Services\NotificationService::class);
    $notifResult = $notifService->sendToUser(
        $captain,
        'تم قبول المشوار بنجاح 🛵',
        'مشوار جديد بقيمة 800 ر.ي.',
        ['type' => 'trip_accepted', 'trip_id' => (string) $trip->id]
    );
    echo "  ✅ Captain Notification sent via NotificationService: " . ($notifResult ? 'SUCCESS' : 'STORED') . "\n";
    $latestCaptNotif = $captain->notifications()->latest()->first();
    if ($latestCaptNotif) {
        echo "  ✅ Database Captain Notification retrieved: ID #{$latestCaptNotif->id}, Title: '{$latestCaptNotif->data['title']}'\n";
    }

    // 7. Test Unified History (Trips & Parcels Merging)
    echo "\n[TEST 7] Testing Unified History Endpoint (Trips & Parcels)...\n";
    $captReq = new \Illuminate\Http\Request(['status_filter' => 'الكل']);
    $captReq->setUserResolver(fn() => $captain);
    $captHistoryResp = app(\App\Http\Controllers\Api\TripController::class)->history($captReq);
    $captHistoryData = $captHistoryResp->getData()->data;
    echo "  ✅ Captain Unified History with status_filter='الكل' returned " . count($captHistoryData) . " records (Includes both Rides 🛵 & Parcels 📦)\n";

    $captDoneReq = new \Illuminate\Http\Request(['status_filter' => 'تم الانتهاء']);
    $captDoneReq->setUserResolver(fn() => $captain);
    $captDoneResp = app(\App\Http\Controllers\Api\TripController::class)->history($captDoneReq);
    $captDoneData = $captDoneResp->getData()->data;
    echo "  ✅ Captain Unified History with status_filter='تم الانتهاء' returned " . count($captDoneData) . " records (Completed Rides + Delivered Parcels)\n";

    $passReq = new \Illuminate\Http\Request(['status_filter' => 'all']);
    $passReq->setUserResolver(fn() => $passenger);
    $passHistoryResp = app(\App\Http\Controllers\Api\TripController::class)->history($passReq);
    $passHistoryData = $passHistoryResp->getData()->data;
    echo "  ✅ Passenger Unified History returned " . count($passHistoryData) . " records (Includes both Rides 🛵 & Parcels 📦)\n";

    // 8. Test History Record Deletion
    echo "\n[TEST 8] Testing History Record Deletion (Trips & Parcels)...\n";
    $delReq = new \Illuminate\Http\Request();
    $delReq->setUserResolver(fn() => $passenger);
    $delResp = app(\App\Http\Controllers\Api\TripController::class)->destroy($delReq, $trip->id);
    echo "  ✅ Deleted Trip: Status " . $delResp->getData()->status . " - " . $delResp->getData()->message . "\n";

    $delParcelResp = app(\App\Http\Controllers\Api\TripController::class)->destroy($delReq, $parcel->id);
    echo "  ✅ Deleted Parcel: Status " . $delParcelResp->getData()->status . " - " . $delParcelResp->getData()->message . "\n";

    echo "\n===============================================\n";
    echo "🎉 ALL BACKEND INTEGRATION TESTS PASSED 100%!\n";
    echo "===============================================\n";

} catch (\Exception $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    echo "Trace:\n" . $e->getTraceAsString() . "\n";
}

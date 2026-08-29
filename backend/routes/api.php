<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TripController;
use App\Http\Controllers\Api\CaptainController;
use App\Http\Controllers\Api\SavedPlaceController;
use App\Http\Controllers\Api\ParcelController;
use App\Http\Controllers\Api\GeocodeController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\SettingsController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\HealthController;

// Public Settings
Route::get('settings', [SettingsController::class, 'index']);

// Render Health Check
Route::get('health', [HealthController::class, 'check']);

// Public Geocoding — Yemen-biased, no auth required
Route::prefix('geocode')->group(function () {
    Route::get('search',  [GeocodeController::class, 'search']);
    Route::get('reverse', [GeocodeController::class, 'reverse']);
});

// Authentication Routes with Rate Limiting (Supports both standard and OTP endpoints)
Route::prefix('auth')->middleware('throttle:60,1')->group(function () {
    Route::post('login',               [AuthController::class, 'login']);
    Route::post('register-passenger',  [AuthController::class, 'registerPassenger']);
    Route::post('register-captain',    [AuthController::class, 'registerCaptain']);
    Route::post('forgot-password',     [AuthController::class, 'forgotPassword'])->middleware('throttle:10,1');
    Route::post('send-otp',            [AuthController::class, 'forgotPassword'])->middleware('throttle:10,1');
    Route::post('verify-reset-code',   [AuthController::class, 'verifyResetCode'])->middleware('throttle:10,1');
    Route::post('verify-otp',          [AuthController::class, 'verifyResetCode'])->middleware('throttle:10,1');
    Route::post('reset-password',      [AuthController::class, 'resetPassword'])->middleware('throttle:10,1');
    Route::middleware('auth:api')->post('logout', [AuthController::class, 'logout']);
});

// Protected API Routes
Route::middleware('auth:api')->group(function () {
    // User / Profile
    Route::prefix('user')->group(function () {
        Route::get('profile',              [AuthController::class, 'profile']);
        Route::post('profile/update',      [AuthController::class, 'updateProfile']);
        Route::delete('profile',           [AuthController::class, 'deleteAccount']);
        Route::get('saved-places',         [SavedPlaceController::class, 'index']);
        Route::post('saved-places',        [SavedPlaceController::class, 'store']);
        Route::delete('saved-places/{id}', [SavedPlaceController::class, 'destroy']);
    });

    // Captain Specific Endpoints
    Route::prefix('captain')->group(function () {
        Route::post('update-location',  [CaptainController::class, 'updateLocation'])->middleware('throttle:120,1');
        Route::post('toggle-online',    [CaptainController::class, 'toggleOnlineStatus']);
        Route::post('documents',        [CaptainController::class, 'uploadDocuments']);
        Route::get('bonus',             [CaptainController::class, 'getBonus']);
        Route::get('notifications',     [NotificationController::class, 'index']);
        Route::get('requests/nearby',   [TripController::class, 'nearbyRequests'])->middleware('throttle:60,1');
    });

    // Parcels Delivery
    Route::prefix('parcel')->group(function () {
        Route::post('request',          [ParcelController::class, 'requestParcel'])->middleware('throttle:10,1');
        Route::get('history',           [ParcelController::class, 'myParcels']);
        Route::get('requests/nearby',   [ParcelController::class, 'nearbyRequests'])->middleware('throttle:60,1');
        Route::get('{id}/track',        [ParcelController::class, 'trackParcel']);
        Route::post('{id}/accept',      [ParcelController::class, 'acceptParcel'])->middleware('throttle:30,1');
        Route::post('{id}/status',      [ParcelController::class, 'updateStatus']);
    });

    // Trips & Rides
    Route::prefix('trips')->group(function () {
        Route::post('estimate',    [TripController::class, 'estimate'])->middleware('throttle:30,1');
        Route::post('create',      [TripController::class, 'create'])->middleware('throttle:10,1');
        Route::get('history',      [TripController::class, 'history']);
        Route::get('{id}',         [TripController::class, 'show']);
        Route::post('{id}/accept', [TripController::class, 'accept'])->middleware('throttle:30,1');
        Route::post('{id}/reject', [TripController::class, 'reject']);
        Route::post('{id}/status', [TripController::class, 'updateStatus']);
        Route::post('{id}/cancel', [TripController::class, 'cancel']);
        Route::post('{id}/rate',   [TripController::class, 'rate']);
        Route::delete('{id}',      [TripController::class, 'destroy']);
    });

    // Wallet & Payments
    Route::prefix('wallet')->group(function () {
        Route::get('balance',          [WalletController::class, 'balance']);
        Route::get('company-accounts', [WalletController::class, 'companyAccounts']);
        Route::post('recharge',        [WalletController::class, 'recharge']);
        Route::post('payout-request',  [WalletController::class, 'payoutRequest']);
    });

    // Notifications (Shared for all authenticated users)
    Route::prefix('notifications')->group(function () {
        Route::get('/',            [NotificationController::class, 'index']);
        Route::get('unread-count', [NotificationController::class, 'unreadCount']);
        Route::post('read-all',    [NotificationController::class, 'markAllAsRead']);
        Route::post('{id}/read',   [NotificationController::class, 'markAsRead']);
        Route::delete('clear-all', [NotificationController::class, 'destroyAll']);
        Route::delete('{id}',      [NotificationController::class, 'destroy']);
    });
});
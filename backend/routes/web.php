<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;

// ===================================================
// Admin Panel Routes - لوحة تحكم لَفَّة
// ===================================================

// Root Health Check
Route::get('health', [\App\Http\Controllers\Api\HealthController::class, 'check']);

// --- Login / Logout ---
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('login', [AuthController::class, 'login'])->name('login.post');
    Route::post('logout', [AuthController::class, 'logout'])->name('logout');

    // --- Protected Panel ---
    Route::middleware(['auth', 'admin'])->group(function () {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

        // Livewire pages
        Route::get('users',         fn() => view('admin.users'))->name('users');
        Route::get('captains',      fn() => view('admin.captains'))->name('captains');
        Route::get('captains/{id}', \App\Livewire\Admin\CaptainProfileViewer::class)->name('captains.show');
        Route::get('live-map',      fn() => view('admin.live-map'))->name('live-map');
        Route::get('trips',         fn() => view('admin.trips'))->name('trips');
        Route::get('transactions',  fn() => view('admin.transactions'))->name('transactions');
        Route::get('documents',          fn() => view('admin.documents'))->name('documents');
        Route::get('documents/{id}/file', [\App\Http\Controllers\Admin\DocumentController::class, 'showFile'])->name('documents.file');
        Route::get('withdrawals',        fn() => view('admin.withdrawals'))->name('withdrawals');
        Route::get('notifications',      fn() => view('admin.notifications'))->name('notifications');
        Route::get('promocodes',         fn() => view('admin.promocodes'))->name('promocodes');
        Route::get('settings',           fn() => view('admin.settings'))->name('settings');
    });
});

Route::get('/', function () {
    return redirect()->route('admin.login');
});

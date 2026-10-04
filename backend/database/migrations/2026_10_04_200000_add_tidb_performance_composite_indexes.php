<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Sprint 2: TiDB Cloud High-Performance Composite & Spatial Dispatch Indexes.
     */
    public function up(): void
    {
        // 1. Wallets: Unique user_id constraint to prevent race condition duplicate wallets
        Schema::table('wallets', function (Blueprint $table) {
            // Check if user_id unique index already exists
            $table->unique('user_id', 'uniq_wallets_user_id');
        });

        // 2. Transactions: Composite indexes for fast history sorting and status lookups
        Schema::table('transactions', function (Blueprint $table) {
            $table->index(['wallet_id', 'created_at'], 'idx_tx_wallet_created');
            $table->index(['wallet_id', 'status', 'created_at'], 'idx_tx_wallet_status_created');
        });

        // 3. Trips: Spatial Dispatch Bounding Box Index & Captain Stats Composite Index
        Schema::table('trips', function (Blueprint $table) {
            $table->index(['status', 'pickup_latitude', 'pickup_longitude', 'created_at'], 'idx_trips_dispatch_spatial');
            $table->index(['captain_profile_id', 'status', 'created_at'], 'idx_trips_captain_status_created');
        });

        // 4. Parcels: Spatial Dispatch Bounding Box Index & Captain Stats Composite Index
        Schema::table('parcels', function (Blueprint $table) {
            $table->index(['status', 'pickup_latitude', 'pickup_longitude', 'created_at'], 'idx_parcels_dispatch_spatial');
            $table->index(['captain_profile_id', 'status', 'created_at'], 'idx_parcels_captain_status_created');
        });

        // 5. Withdrawal Requests: Status and User Composite Indexes
        Schema::table('withdrawal_requests', function (Blueprint $table) {
            $table->index(['status', 'created_at'], 'idx_wd_status_created');
            $table->index(['user_id', 'status'], 'idx_wd_user_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('wallets', function (Blueprint $table) {
            $table->dropUnique('uniq_wallets_user_id');
        });

        Schema::table('transactions', function (Blueprint $table) {
            $table->dropIndex('idx_tx_wallet_created');
            $table->dropIndex('idx_tx_wallet_status_created');
        });

        Schema::table('trips', function (Blueprint $table) {
            $table->dropIndex('idx_trips_dispatch_spatial');
            $table->dropIndex('idx_trips_captain_status_created');
        });

        Schema::table('parcels', function (Blueprint $table) {
            $table->dropIndex('idx_parcels_dispatch_spatial');
            $table->dropIndex('idx_parcels_captain_status_created');
        });

        Schema::table('withdrawal_requests', function (Blueprint $table) {
            $table->dropIndex('idx_wd_status_created');
            $table->dropIndex('idx_wd_user_status');
        });
    }
};

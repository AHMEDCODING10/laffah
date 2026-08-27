<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->index(['status', 'captain_profile_id'], 'idx_trips_status_captain');
            $table->index(['status', 'created_at'], 'idx_trips_status_created');
        });

        Schema::table('parcels', function (Blueprint $table) {
            $table->index(['status', 'captain_profile_id'], 'idx_parcels_status_captain');
            $table->index(['status', 'created_at'], 'idx_parcels_status_created');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->dropIndex('idx_trips_status_captain');
            $table->dropIndex('idx_trips_status_created');
        });

        Schema::table('parcels', function (Blueprint $table) {
            $table->dropIndex('idx_parcels_status_captain');
            $table->dropIndex('idx_parcels_status_created');
        });
    }
};

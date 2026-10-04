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
        Schema::table('captain_locations', function (Blueprint $table) {
            $table->index(['latitude', 'longitude'], 'idx_captains_lat_lng');
            $table->index('last_updated_at', 'idx_captains_last_updated');
        });

        Schema::table('captain_profiles', function (Blueprint $table) {
            $table->index('is_online', 'idx_captains_is_online');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('captain_locations', function (Blueprint $table) {
            $table->dropIndex('idx_captains_lat_lng');
            $table->dropIndex('idx_captains_last_updated');
        });

        Schema::table('captain_profiles', function (Blueprint $table) {
            $table->dropIndex('idx_captains_is_online');
        });
    }
};

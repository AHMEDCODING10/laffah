<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Deduplicate captain_locations before applying unique constraint
        $duplicates = DB::table('captain_locations')
            ->select('captain_profile_id', DB::raw('MAX(id) as max_id'))
            ->groupBy('captain_profile_id')
            ->havingRaw('COUNT(*) > 1')
            ->get();

        foreach ($duplicates as $dup) {
            DB::table('captain_locations')
                ->where('captain_profile_id', $dup->captain_profile_id)
                ->where('id', '<', $dup->max_id)
                ->delete();
        }

        // 2. Add Unique constraint on captain_locations(captain_profile_id)
        Schema::table('captain_locations', function (Blueprint $table) {
            $table->unique('captain_profile_id', 'uniq_captain_locations_profile');
        });

        // 3. Add Composite Indexes for history speedup on trips
        Schema::table('trips', function (Blueprint $table) {
            $table->index(['user_id', 'created_at'], 'idx_trips_user_created');
            $table->index(['captain_profile_id', 'created_at'], 'idx_trips_captain_created');
        });

        // 4. Add Composite Indexes for history speedup on parcels
        Schema::table('parcels', function (Blueprint $table) {
            $table->index(['user_id', 'created_at'], 'idx_parcels_user_created');
            $table->index(['captain_profile_id', 'created_at'], 'idx_parcels_captain_created');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('captain_locations', function (Blueprint $table) {
            $table->dropUnique('uniq_captain_locations_profile');
        });

        Schema::table('trips', function (Blueprint $table) {
            $table->dropIndex('idx_trips_user_created');
            $table->dropIndex('idx_trips_captain_created');
        });

        Schema::table('parcels', function (Blueprint $table) {
            $table->dropIndex('idx_parcels_user_created');
            $table->dropIndex('idx_parcels_captain_created');
        });
    }
};

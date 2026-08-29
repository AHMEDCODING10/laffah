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
            $table->index(['status', 'created_at']);
            $table->index('captain_profile_id');
        });

        Schema::table('parcels', function (Blueprint $table) {
            $table->index(['status', 'created_at']);
            $table->index('captain_profile_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->dropIndex(['status', 'created_at']);
            $table->dropIndex(['captain_profile_id']);
        });

        Schema::table('parcels', function (Blueprint $table) {
            $table->dropIndex(['status', 'created_at']);
            $table->dropIndex(['captain_profile_id']);
        });
    }
};

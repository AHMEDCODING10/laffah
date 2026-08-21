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
        if (Schema::hasTable('users') && !Schema::hasColumn('users', 'deleted_at')) {
            Schema::table('users', function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        if (Schema::hasTable('trips') && !Schema::hasColumn('trips', 'deleted_at')) {
            Schema::table('trips', function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        if (Schema::hasTable('parcels') && !Schema::hasColumn('parcels', 'deleted_at')) {
            Schema::table('parcels', function (Blueprint $table) {
                $table->softDeletes();
            });
        }

        if (Schema::hasTable('captain_profiles') && !Schema::hasColumn('captain_profiles', 'deleted_at')) {
            Schema::table('captain_profiles', function (Blueprint $table) {
                $table->softDeletes();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('users') && Schema::hasColumn('users', 'deleted_at')) {
            Schema::table('users', function (Blueprint $table) {
                $table->dropSoftDeletes();
            });
        }

        if (Schema::hasTable('trips') && Schema::hasColumn('trips', 'deleted_at')) {
            Schema::table('trips', function (Blueprint $table) {
                $table->dropSoftDeletes();
            });
        }

        if (Schema::hasTable('parcels') && Schema::hasColumn('parcels', 'deleted_at')) {
            Schema::table('parcels', function (Blueprint $table) {
                $table->dropSoftDeletes();
            });
        }

        if (Schema::hasTable('captain_profiles') && Schema::hasColumn('captain_profiles', 'deleted_at')) {
            Schema::table('captain_profiles', function (Blueprint $table) {
                $table->dropSoftDeletes();
            });
        }
    }
};

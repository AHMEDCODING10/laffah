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
        if (Schema::hasTable('trips') && !Schema::hasColumn('trips', 'cancelled_at')) {
            Schema::table('trips', function (Blueprint $table) {
                $table->timestamp('cancelled_at')->nullable()->after('completed_at');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('trips') && Schema::hasColumn('trips', 'cancelled_at')) {
            Schema::table('trips', function (Blueprint $table) {
                $table->dropColumn('cancelled_at');
            });
        }
    }
};

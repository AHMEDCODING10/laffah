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
            if (!Schema::hasColumn('trips', 'bike_category_id')) {
                $table->foreignId('bike_category_id')->nullable()->after('captain_profile_id')->constrained()->nullOnDelete();
            }
            if (!Schema::hasColumn('trips', 'promo_code_id')) {
                $table->foreignId('promo_code_id')->nullable()->after('bike_category_id')->constrained()->nullOnDelete();
            }
            
            if (!Schema::hasColumn('trips', 'commission_amount')) {
                $table->decimal('commission_amount', 10, 2)->default(0)->after('final_price');
            }
            if (!Schema::hasColumn('trips', 'captain_earnings')) {
                $table->decimal('captain_earnings', 10, 2)->default(0)->after('commission_amount');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->dropForeign(['bike_category_id']);
            $table->dropForeign(['promo_code_id']);
            $table->dropColumn(['bike_category_id', 'promo_code_id', 'commission_amount', 'captain_earnings']);
        });
    }
};

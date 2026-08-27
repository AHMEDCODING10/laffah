<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('parcels', function (Blueprint $table) {
            if (!Schema::hasColumn('parcels', 'captain_profile_id')) {
                $table->foreignId('captain_profile_id')->nullable()->after('user_id')->constrained('captain_profiles')->nullOnDelete();
            }
            if (!Schema::hasColumn('parcels', 'pickup_address')) {
                $table->string('pickup_address')->nullable()->after('receiver_phone');
            }
            if (!Schema::hasColumn('parcels', 'pickup_latitude')) {
                $table->decimal('pickup_latitude', 10, 8)->nullable()->after('pickup_address');
            }
            if (!Schema::hasColumn('parcels', 'pickup_longitude')) {
                $table->decimal('pickup_longitude', 11, 8)->nullable()->after('pickup_latitude');
            }
            if (!Schema::hasColumn('parcels', 'dropoff_address')) {
                $table->string('dropoff_address')->nullable()->after('pickup_longitude');
            }
            if (!Schema::hasColumn('parcels', 'dropoff_latitude')) {
                $table->decimal('dropoff_latitude', 10, 8)->nullable()->after('dropoff_address');
            }
            if (!Schema::hasColumn('parcels', 'dropoff_longitude')) {
                $table->decimal('dropoff_longitude', 11, 8)->nullable()->after('dropoff_latitude');
            }
            if (!Schema::hasColumn('parcels', 'tracking_code')) {
                $table->string('tracking_code')->nullable()->after('price');
            }
            if (!Schema::hasColumn('parcels', 'accepted_at')) {
                $table->timestamp('accepted_at')->nullable()->after('tracking_code');
            }
            if (!Schema::hasColumn('parcels', 'picked_up_at')) {
                $table->timestamp('picked_up_at')->nullable()->after('accepted_at');
            }
            if (!Schema::hasColumn('parcels', 'delivered_at')) {
                $table->timestamp('delivered_at')->nullable()->after('picked_up_at');
            }
            if (!Schema::hasColumn('parcels', 'cancelled_at')) {
                $table->timestamp('cancelled_at')->nullable()->after('delivered_at');
            }
            if (!Schema::hasColumn('parcels', 'cancelled_by')) {
                $table->string('cancelled_by')->nullable()->after('cancelled_at');
            }
            if (!Schema::hasColumn('parcels', 'cancellation_reason')) {
                $table->text('cancellation_reason')->nullable()->after('cancelled_by');
            }
        });
    }

    public function down(): void
    {
        Schema::table('parcels', function (Blueprint $table) {
            // Drop columns if needed
        });
    }
};

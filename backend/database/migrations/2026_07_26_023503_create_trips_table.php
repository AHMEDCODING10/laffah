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
        Schema::create('trips', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete(); // Passenger
            $table->foreignId('captain_profile_id')->nullable()->constrained()->nullOnDelete();
            
            // Core Details
            $table->enum('status', ['pending', 'accepted', 'arrived', 'in_transit', 'completed', 'cancelled'])->default('pending');
            $table->enum('type', ['ride', 'delivery'])->default('ride');
            $table->boolean('is_multi_stop')->default(false);
            
            // Pickup
            $table->string('pickup_address');
            $table->decimal('pickup_latitude', 10, 8);
            $table->decimal('pickup_longitude', 11, 8);
            
            // Dropoff (Final destination)
            $table->string('dropoff_address');
            $table->decimal('dropoff_latitude', 10, 8);
            $table->decimal('dropoff_longitude', 11, 8);
            
            // Pricing & Distance
            $table->decimal('distance_km', 8, 2)->nullable();
            $table->decimal('estimated_price', 10, 2)->nullable();
            $table->decimal('final_price', 10, 2)->nullable();
            
            // Timestamps
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('trips');
    }
};

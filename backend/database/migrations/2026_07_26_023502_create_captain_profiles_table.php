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
        Schema::create('captain_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('vehicle_type')->nullable(); // e.g., دراجة ياماها 125cc
            $table->string('vehicle_model')->nullable();
            $table->string('plate_number')->nullable();
            $table->string('vehicle_color')->nullable();
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->boolean('is_online')->default(false);
            $table->boolean('is_verified')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('captain_profiles');
    }
};

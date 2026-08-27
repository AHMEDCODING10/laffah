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
            $table->foreignId('cancelled_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('cancellation_reason')->nullable();
            
            $table->tinyInteger('rating_by_user')->nullable()->comment('1 to 5 stars');
            $table->text('review_by_user')->nullable();
            
            $table->tinyInteger('rating_by_captain')->nullable()->comment('1 to 5 stars');
            $table->text('review_by_captain')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('trips', function (Blueprint $table) {
            $table->dropForeign(['cancelled_by']);
            $table->dropColumn([
                'cancelled_by',
                'cancellation_reason',
                'rating_by_user',
                'review_by_user',
                'rating_by_captain',
                'review_by_captain',
            ]);
        });
    }
};

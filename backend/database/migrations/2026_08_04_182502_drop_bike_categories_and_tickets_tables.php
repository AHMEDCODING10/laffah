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
        Schema::dropIfExists('ticket_messages');
        Schema::dropIfExists('support_tickets');
        
        // Remove foreign key before dropping the table if necessary, but we can just drop the column
        if (Schema::hasColumn('trips', 'bike_category_id')) {
            Schema::table('trips', function (Blueprint $table) {
                $table->dropForeign(['bike_category_id']);
                $table->dropColumn('bike_category_id');
            });
        }

        Schema::dropIfExists('bike_categories');
    }

    public function down(): void
    {
        // One-way migration
    }
};

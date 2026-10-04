<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Sprint 1: Add held_balance to wallets for Escrow Hold,
     * and add status and parcel_id to transactions.
     */
    public function up(): void
    {
        if (Schema::hasTable('wallets') && !Schema::hasColumn('wallets', 'held_balance')) {
            Schema::table('wallets', function (Blueprint $table) {
                $table->decimal('held_balance', 12, 2)->default(0.00)->after('balance');
            });
        }

        if (Schema::hasTable('transactions')) {
            Schema::table('transactions', function (Blueprint $table) {
                if (!Schema::hasColumn('transactions', 'status')) {
                    $table->string('status', 20)->default('completed')->after('amount');
                }
                if (!Schema::hasColumn('transactions', 'parcel_id')) {
                    $table->foreignId('parcel_id')->nullable()->after('trip_id')->constrained('parcels')->nullOnDelete();
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('wallets') && Schema::hasColumn('wallets', 'held_balance')) {
            Schema::table('wallets', function (Blueprint $table) {
                $table->dropColumn('held_balance');
            });
        }

        if (Schema::hasTable('transactions')) {
            Schema::table('transactions', function (Blueprint $table) {
                if (Schema::hasColumn('transactions', 'parcel_id')) {
                    $table->dropForeign(['parcel_id']);
                    $table->dropColumn('parcel_id');
                }
                if (Schema::hasColumn('transactions', 'status')) {
                    $table->dropColumn('status');
                }
            });
        }
    }
};

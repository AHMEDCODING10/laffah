<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Add receipt proof, payment channel metadata, and admin approval audit fields.
     */
    public function up(): void
    {
        if (Schema::hasTable('transactions')) {
            Schema::table('transactions', function (Blueprint $table) {
                if (!Schema::hasColumn('transactions', 'payment_method')) {
                    $table->string('payment_method', 50)->nullable()->after('type');
                }
                if (!Schema::hasColumn('transactions', 'sender_account')) {
                    $table->string('sender_account', 100)->nullable()->after('payment_method');
                }
                if (!Schema::hasColumn('transactions', 'receipt_url')) {
                    $table->string('receipt_url', 500)->nullable()->after('reference_id');
                }
                if (!Schema::hasColumn('transactions', 'admin_notes')) {
                    $table->text('admin_notes')->nullable()->after('receipt_url');
                }
                if (!Schema::hasColumn('transactions', 'approved_by')) {
                    $table->foreignId('approved_by')->nullable()->after('admin_notes')->constrained('users')->nullOnDelete();
                }
                if (!Schema::hasColumn('transactions', 'approved_at')) {
                    $table->timestamp('approved_at')->nullable()->after('approved_by');
                }
                if (!Schema::hasColumn('transactions', 'rejected_at')) {
                    $table->timestamp('rejected_at')->nullable()->after('approved_at');
                }
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('transactions')) {
            Schema::table('transactions', function (Blueprint $table) {
                if (Schema::hasColumn('transactions', 'approved_by')) {
                    $table->dropForeign(['approved_by']);
                    $table->dropColumn('approved_by');
                }
                $columns = ['payment_method', 'sender_account', 'receipt_url', 'admin_notes', 'approved_at', 'rejected_at'];
                foreach ($columns as $column) {
                    if (Schema::hasColumn('transactions', $column)) {
                        $table->dropColumn($column);
                    }
                }
            });
        }
    }
};

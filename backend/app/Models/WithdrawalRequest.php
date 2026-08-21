<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WithdrawalRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'captain_profile_id',
        'user_id',
        'amount',
        'payment_method',
        'account_number',
        'account_name',
        'status',
        'rejection_reason',
        'transfer_receipt',
        'transfer_reference',
        'notes',
        'processed_by',
        'processed_at',
    ];

    protected $casts = [
        'amount'       => 'decimal:2',
        'processed_at' => 'datetime',
    ];

    public function captainProfile()
    {
        return $this->belongsTo(CaptainProfile::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function processedBy()
    {
        return $this->belongsTo(User::class, 'processed_by');
    }
}
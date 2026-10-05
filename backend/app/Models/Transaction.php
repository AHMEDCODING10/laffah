<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = [
        'wallet_id',
        'trip_id',
        'parcel_id',
        'type',
        'payment_method',
        'sender_account',
        'amount',
        'status',
        'description',
        'reference_id',
        'receipt_url',
        'admin_notes',
        'approved_by',
        'approved_at',
        'rejected_at',
    ];

    protected $casts = [
        'amount'      => 'decimal:2',
        'approved_at' => 'datetime',
        'rejected_at' => 'datetime',
    ];

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    public function trip()
    {
        return $this->belongsTo(Trip::class);
    }

    public function parcel()
    {
        return $this->belongsTo(Parcel::class);
    }
}

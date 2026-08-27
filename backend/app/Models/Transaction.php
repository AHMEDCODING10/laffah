<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    protected $fillable = [
        'wallet_id',
        'trip_id',
        'type',
        'amount',
        'description',
        'reference_id',
    ];

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    public function trip()
    {
        return $this->belongsTo(Trip::class);
    }
}

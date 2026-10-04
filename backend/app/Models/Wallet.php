<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Wallet extends Model
{
    protected $fillable = [
        'user_id',
        'balance',
        'held_balance',
        'currency',
    ];

    protected $casts = [
        'balance'      => 'float',
        'held_balance' => 'float',
    ];

    /**
     * Get available balance excluding escrow/held amounts.
     */
    public function getAvailableBalanceAttribute(): float
    {
        return (float) max(0, ($this->balance ?? 0) - ($this->held_balance ?? 0));
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(Transaction::class);
    }
}

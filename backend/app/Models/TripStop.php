<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TripStop extends Model
{
    protected $fillable = [
        'trip_id',
        'stop_order',
        'address',
        'latitude',
        'longitude',
        'status',
    ];

    public function trip()
    {
        return $this->belongsTo(Trip::class);
    }
}

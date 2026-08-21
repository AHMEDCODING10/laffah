<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;

class Parcel extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'captain_profile_id',
        'sender_name',
        'sender_phone',
        'receiver_name',
        'receiver_phone',
        'pickup_address',
        'pickup_latitude',
        'pickup_longitude',
        'dropoff_address',
        'dropoff_latitude',
        'dropoff_longitude',
        'parcel_type',
        'size',
        'notes',
        'status',
        'price',
        'tracking_code',
        'accepted_at',
        'picked_up_at',
        'delivered_at',
    ];

    protected $casts = [
        'pickup_latitude' => 'float',
        'pickup_longitude' => 'float',
        'dropoff_latitude' => 'float',
        'dropoff_longitude' => 'float',
        'price' => 'float',
        'accepted_at' => 'datetime',
        'picked_up_at' => 'datetime',
        'delivered_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($parcel) {
            if (empty($parcel->tracking_code)) {
                $parcel->tracking_code = 'LF-' . strtoupper(Str::random(6));
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function captain()
    {
        return $this->belongsTo(CaptainProfile::class, 'captain_profile_id');
    }
}
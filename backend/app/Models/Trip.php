<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Trip extends Model
{
    use SoftDeletes;
    protected $fillable = [
        'user_id',
        'captain_profile_id',
        'promo_code_id',
        'status',
        'type',
        'is_multi_stop',
        'pickup_address',
        'pickup_latitude',
        'pickup_longitude',
        'dropoff_address',
        'dropoff_latitude',
        'dropoff_longitude',
        'distance_km',
        'estimated_price',
        'final_price',
        'commission_amount',
        'captain_earnings',
        'cancelled_by',
        'accepted_at',
        'cancellation_reason',
        'rating_by_user',
        'review_by_user',
        'rating_by_captain',
        'review_by_captain',
        'started_at',
        'completed_at',
        'cancelled_at'
    ];

    protected $casts = [
        'is_multi_stop' => 'boolean',
        'accepted_at' => 'datetime',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
        'cancelled_at' => 'datetime',
    ];

    public function passenger()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function captain()
    {
        return $this->belongsTo(CaptainProfile::class, 'captain_profile_id');
    }

    public function stops()
    {
        return $this->hasMany(TripStop::class)->orderBy('stop_order');
    }

    // bikeCategory relationship removed

    public function promoCode()
    {
        return $this->belongsTo(PromoCode::class);
    }

    public function transaction()
    {
        return $this->hasOne(Transaction::class);
    }
}

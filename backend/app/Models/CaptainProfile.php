<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class CaptainProfile extends Model
{
    use SoftDeletes;
    protected $fillable = [
        'user_id',
        'vehicle_type',
        'vehicle_model',
        'plate_number',
        'vehicle_color',
        'identity_number',
        'rating',
        'is_online',
        'is_verified',
    ];

    protected $casts = [
        'is_verified' => 'boolean',
        'is_online' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function location()
    {
        return $this->hasOne(CaptainLocation::class);
    }

    public function trips()
    {
        return $this->hasMany(Trip::class, 'captain_profile_id');
    }

    public function documents()
    {
        return $this->hasMany(Document::class);
    }
}

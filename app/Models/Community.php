<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Community extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'type',
        'specialization',
        'doctor_id',
        'is_private',
        'image'
    ];

    public function doctor()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function members()
    {
        return $this->hasMany(CommunityMember::class);
    }

    public function posts()
    {
        return $this->hasMany(CommunityPost::class);
    }

}

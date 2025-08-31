<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class CommunityPost extends Model
{
    use HasFactory;

    protected $fillable = [
        'community_id',
        'patient_id',
        'doctor_id',
        'case_id',
        'title',
        'content',
        'is_public'
    ];

    public function community()
    {
        return $this->belongsTo(Community::class);
    }

    public function doctorAuthor()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function patientAuthor()
    {
        return $this->belongsTo(Patient::class);
    }

    public function medicalCase()
    {
        return $this->belongsTo(MedicalCase::class);
    }

    public function comments()
    {
        return $this->hasMany(PostComment::class);
    }
}

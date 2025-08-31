<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class PostComment extends Model
{
    use HasFactory;

    protected $fillable = [
        'post_id',
        'patient_id',
        'doctor_id',
        'content'
    ];

    public function post()
    {
        return $this->belongsTo(CommunityPost::class);
    }

    public function doctorCommenter()
    {
        return $this->belongsTo(Doctor::class);
    }

    public function patientCommenter()
    {
        return $this->belongsTo(Patient::class);
    }
}

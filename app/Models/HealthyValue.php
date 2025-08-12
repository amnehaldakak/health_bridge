<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HealthyValue extends Model
{
    public function patient()
    {
        return $this->belongsTo(Patient::class, 'patient_id');
    }
    public function disease()
    {
        return $this->belongsTo(Disease::class, 'disease_id');
    }
}

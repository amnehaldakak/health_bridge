<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MedicationGroup extends Model
{
    public function medicalCase()
    {
        return $this->belongsTo(MedicalCase::class, 'case_id');
    }

    public function medications()
    {
        return $this->hasMany(Medication::class, 'group_id');
    }
}

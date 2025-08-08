<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medication extends Model
{
    public function patient()
    {
        return $this->belongsTo(User::class, 'patient_id');
    }

    public function medicationGroup()
    {
        return $this->belongsTo(MedicationGroup::class, 'group_id');
    }

    public function reminderTimes()
    {
        return $this->hasMany(ReminderTime::class, 'medication_id');
    }
    
}

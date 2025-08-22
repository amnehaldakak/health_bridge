<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Medication extends Model
{

    protected $fillable = [
        'group_id',
        'name',
        'dosage',
        'frequency',
        'duration',
        'start_date',
        'first_dose_time',
        'patient_confirmed'
    ];
    
    public function medicationGroup()
    {
        return $this->belongsTo(MedicationGroup::class, 'group_id', 'group_id');
    }

    public function reminderTimes()
    {
        return $this->hasMany(ReminderTime::class, 'medication_id', 'medication_id');
    }
    
}

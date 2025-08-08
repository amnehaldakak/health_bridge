<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ReminderTime extends Model
{
    public function medication()
    {
        return $this->belongsTo(Medication::class, 'medication_id');
    }
}

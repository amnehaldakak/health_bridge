<?php

namespace App\Http\Controllers;
use App\Models\ReminderTime;
use App\Models\Medication;
use App\Models\Patient;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ReminderController extends Controller
{
    // إنشاء التذكيرات للدواء
    public function generateReminders(Medication $medication)
    {
        // حذف التذكيرات القديمة
       // ReminderTime::where('medication_id', $medication->medication_id)->delete();

        $startDate = Carbon::parse($medication->start_date);
        $firstDoseTime = Carbon::parse($medication->first_dose_time);
        $frequency = $medication->frequency;
        $duration = $medication->duration;

        $interval = 24 / $frequency;

        for ($day = 0; $day < $duration; $day++) {
            $currentDate = $startDate->copy()->addDays($day);

            for ($dose = 0; $dose < $frequency; $dose++) {
                $doseTime = $firstDoseTime->copy()->addHours($dose * $interval);

                if ($doseTime->format('H:i') < $firstDoseTime->format('H:i')) {
                    $currentDate->addDay();
                }

                

                ReminderTime::create([
                    'medication_id' => $medication->id,
                    'date' => $currentDate->format('Y-m-d'),
                    'time' => $doseTime->format('H:i:s'),
                    'status' => 0,
                ]);
            }
        }
    }

    // تحديث حالة التذكير
    public function updateStatus(Request $request, $reminderId)
    {
        $reminder = ReminderTime::findOrFail($reminderId);
        $reminder->update(['status' => $request->status,]);

        return response()->json([
            'message' => 'Reminder status updated successfully'
        ]);

    }

    // الحصول على تذكيرات المريض
    public function getPatientReminders()
    {
        $userId = Auth::id();
        $patient = Patient::where('user_id', $userId)->first();
        
        $patientId=$patient->id;
        $reminders = ReminderTime::whereHas('medication.medicationGroup', function($query) use ($patientId) {
            $query->where('patient_id', $patientId);
        })->with('medication')->get();

        return response()->json([
            'data' => $reminders
        ]);
    }
}

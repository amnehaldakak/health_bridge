<?php

namespace App\Http\Controllers;
use App\Models\Medication;
use App\Models\Patient;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class MedicationController extends Controller
{
    // إنشاء دواء جديد (يستخدم من قبل الكونترولرات الأخرى)
    public function createMedication($group_id, $medicationData)
    {
        $medication = Medication::create([
            'group_id' => $group_id,
            'name' => $medicationData['name'],
            'dosage' => $medicationData['dosage'],
            'frequency' => $medicationData['frequency'],
            'duration' => $medicationData['duration'],
        ]);

        return $medication;
    }

    // المريض يؤكد الدواء ويحدد وقت البدء
    public function confirmMedication(Request $request, $id)
    {
        $request->validate([
            'start_date' => 'required|date',
            'first_dose_time' => 'required|date_format:H:i',
        ]);

        $medication = Medication::where('medication_id', $id)->first();
        if (!$medication) {
        return response()->json(['message' => 'Medication not found'], 404);
    }

        $userId = Auth::id();
        $patient = Patient::where('user_id', $userId)->first();
        
        if ($medication->medicationGroup->patient_id !== $patient->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $medication->where('medication_id', $id)->update([
            'start_date' => $request->start_date,
            'first_dose_time' => $request->first_dose_time,
            'patient_confirmed' => true,
        ]);

        // نستخدم ReminderController لإنشاء التذكيرات
        app('App\Http\Controllers\ReminderController')
            ->generateReminders($medication);

        return response()->json([
            'message' => 'Medication confirmed successfully',
            //'data' => $medication->load('reminderTimes')
        ]);
    }

    // تحديث معلومات الدواء
    public function update(Request $request, $id)
    {
        $medication = Medication::where('medication_id', $id)->first();
        
        $request->validate([
            'name' => 'sometimes|string',
            'dosage' => 'sometimes|string',
            'frequency' => 'sometimes|integer|min:1',
            'duration' => 'sometimes|integer|min:1',
        ]);


        $medication->where('medication_id', $id)->update([
            'name' => $request->name ?? $medication->name,
            'dosage' => $request->dosage ?? $medication->dosage,
            'frequency' => $request->frequency ?? $medication->frequency,
            'duration' => $request->duration ?? $medication->duration,
            ]);

        $medication = Medication::where('medication_id', $id)->first();


        return response()->json([
            'message' => 'Medication updated successfully',
            'data' => $medication
        ]);
    }

    // حذف دواء
    public function destroy($id)
    {
        $deleted = Medication::where('medication_id', $id)->delete();
    
        if ($deleted) {
            return response()->json([
                'message' => 'Medication group deleted successfully'
            ]);
        }
    
        return response()->json([
            'message' => 'Medication group not found'
        ], 404);
    }
}

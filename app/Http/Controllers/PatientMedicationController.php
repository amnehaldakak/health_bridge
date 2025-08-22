<?php

namespace App\Http\Controllers;
use App\Models\MedicationGroup;
use App\Models\Medication;
use App\Models\Patient;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class PatientMedicationController extends Controller
{
    // إضافة دواء جديد من قبل المريض
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'dosage' => 'required|string',
            'frequency' => 'required|integer|min:1',
            'duration' => 'required|integer|min:1',
            'start_date' => 'required|date',
            'first_dose_time' => 'required|date_format:H:i',
        ]);

        $userId = Auth::id();
        $patient = Patient::where('user_id', $userId)->first();
        
        $medicationGroup = MedicationGroup::create([
            'patient_id' => $patient->id,
            'prescription_date' => now(),
        ]);

        // إنشاء الدواء
        $medication = Medication::create([
            'group_id' => $medicationGroup->id,
            'name' => $request->name,
            'dosage' => $request->dosage,
            'frequency' => $request->frequency,
            'duration' => $request->duration,
            'start_date' => $request->start_date,
            'first_dose_time' => $request->first_dose_time,
            'patient_confirmed' => true,
        ]);

        // إنشاء التذكيرات
        app('App\Http\Controllers\ReminderController')
            ->generateReminders($medication);

        return response()->json([
            'message' => 'Medication added successfully',
            'data' => $medication->load('reminderTimes')
        ], 201);
    }

    // عرض أدوية المريض
    public function index()
    {
        $patientId = Auth::id();
        
        $medications = Medication::whereHas('medicationGroup', function($query) use ($patientId) {
            $query->where('patient_id', $patientId);
        })->with(['medicationGroup.doctor', 'reminderTimes'])->get();

        return response()->json([
            'data' => $medications
        ]);
    }
}

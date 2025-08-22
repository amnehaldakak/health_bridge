<?php

namespace App\Http\Controllers;
use App\Models\MedicalCase;
use App\Models\MedicationGroup;
use App\Models\Doctor;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class MedicationGroupController extends Controller
{
    // إنشاء مجموعة أدوية جديدة
    public function store(Request $request, $caseId)
    {
        $request->validate([
            'medications' => 'required|array',
            'medications.*.name' => 'required|string',
            'medications.*.dosage' => 'required|string',
            'medications.*.frequency' => 'required|integer|min:1',
            'medications.*.duration' => 'required|integer|min:1',
        ]);


        $medicalCase = MedicalCase::findOrFail($caseId);

        $userId = Auth::id();
        $doctor = Doctor::where('user_id', $userId)->first();

        $medicationGroup = MedicationGroup::create([
            'case_id' => $caseId,
            'patient_id' => $medicalCase->patient_id,
            'doctor_id' => $doctor->id,
            'prescription_date' => now(),
        ]);

        if (!$medicationGroup->id) {
        return response()->json([
            'message' => 'Failed to create medication group'
        ], 500);
    }
        

        // نستخدم MedicationController لإضافة الأدوية
        foreach ($request->medications as $medicationData) {
            app('App\Http\Controllers\MedicationController')
                ->createMedication($medicationGroup->id, $medicationData);
        }

        return response()->json([
            'message' => 'Medication group created successfully',
            'data' => $medicationGroup = MedicationGroup::with([
            'medications.reminderTimes',
            'patient',
            'doctor'
        ])
        ->where('group_id', $medicationGroup->id)
        ->firstOrFail(),
        ], 201);
    }


    public function show($id)
    {
        $medicationGroup = MedicationGroup::with([
                'medications.reminderTimes',
                'patient',
                'doctor'
            ])
            ->where('group_id', $id)
            ->firstOrFail();

        return response()->json([
            'medicationGroup' => $medicationGroup
        ]);
    }

    // حذف مجموعة أدوية
    public function destroy($id)
    {
        
    $deleted = MedicationGroup::where('group_id', $id)->delete();
    
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

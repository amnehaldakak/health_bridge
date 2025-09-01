<?php

namespace App\Http\Controllers;
use App\Models\Patient;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class AIController extends Controller
{
    public function getPatientData()
    {

        $userId = Auth::id();
        $patient = Patient::where('user_id', $userId)->first();

        $patient = Patient::with([
                'user',
                'medicalCase',
                'medicationGroups.medications.reminderTimes',
        ])->findOrFail($patient->id);

        $casesCount = $patient->medicalCase->count();

        return response()->json([
                'success' => true,
                'cases_count' => $casesCount,
                'data' => $patient
            ]);
    }

}

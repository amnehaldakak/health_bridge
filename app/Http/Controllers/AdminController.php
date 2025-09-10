<?php

namespace App\Http\Controllers;
use App\Models\Doctor;
use App\Models\Patient;
use App\Models\Community;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function getUserCount()
    {
        $patient = Patient::count();
        $approvedDoctors = Doctor::where('verification_status', 'approved')->count();

        return response()->json([
                'success' => true,
                'patient' => $patient,
                'approvedDoctors' => $approvedDoctors
            ]);
    }

    public function getCommunityCount()
    {
        $publicCommunity = Community::where('type', 'public')->count();
        $privateCommunity = Community::where('type', 'private')->count();

        return response()->json([
                'success' => true,
                'publicCommunity' => $publicCommunity,
                'privateCommunity' => $privateCommunity
            ]);
    }
}

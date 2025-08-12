<?php

namespace App\Http\Controllers;
use App\Models\Doctor;
use App\Models\User;
use Illuminate\Http\Request;

class DoctorApprovalController extends Controller
{
    public function pendingDoctors()
    {
        $doctors = Doctor::with('user')
            ->where('verification_status', 'pending')
            ->get();

        return response()->json($doctors);
    }

    public function showCertificate($doctorId)
    {
        $doctor = Doctor::findOrFail($doctorId);
        return response()->file(storage_path('app/public/' . $doctor->certificate_path));
    }

    public function approveDoctor(Request $request, $doctorId)
{
    $request->validate([
        'action' => 'required|in:approve,reject'
    ]);

    $doctor = Doctor::findOrFail($doctorId);
    $user = $doctor->user;

    if ($request->action === 'approve') {
        $doctor->update(['verification_status' => 'approved']);
        $user->update(['is_approved' => true]);

        return response()->json(['message' => 'تمت الموافقة على الطبيب بنجاح']);
    }

    else
    {
        $doctor->update(['verification_status' => 'rejected']);

        return response()->json(['message' => 'تم رفض الطبيب']);
    }
}
}

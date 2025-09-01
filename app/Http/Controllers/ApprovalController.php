<?php

namespace App\Http\Controllers;
use App\Models\DoctorPatientApproval;
use App\Models\Patient;
use App\Models\Doctor;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class ApprovalController extends Controller
{
    public function approve($approvalId)
    {
        $approval = DoctorPatientApproval::findOrFail($approvalId);
        
        // التحقق من أن المستخدم الحالي هو المريض المعني
        if (Auth::id() != $approval->patient->user_id) {
            return response()->json(['message' => 'غير مصرح'], 403);
        }

        $approval->update(['status' => 'approved']);

        return response()->json([
            'message' => 'تم الموافقة على الطبيب بنجاح'
        ]);
    }

    public function reject($approvalId)
    {
        $approval = DoctorPatientApproval::findOrFail($approvalId);
        
        if (Auth::id() != $approval->patient->user_id) {
            return response()->json(['message' => 'غير مصرح'], 403);
        }

        $approval->update(['status' => 'rejected']);

        return response()->json([
            'message' => 'تم رفض الطبيب بنجاح'
        ]);
    }

    public function pendingApprovals()
    {
        $userId = Auth::id();    
        $patient = Patient::where('user_id', $userId)->first();
        
        $approvals = DoctorPatientApproval::with('doctor.user')
            ->where('patient_id', $patient->id)
            ->where('status', 'pending')
            ->get();

        return response()->json($approvals);
    }

    public function requestsForPatients()
    {
        $userId = Auth::id();
        $doctor = Doctor::where('user_id', $userId)->first();
        
        $approvals = DoctorPatientApproval::with('patient.user')
            ->where('doctor_id', $doctor->id)
            ->get();
            //->where('status', 'pending')

        return response()->json($approvals);
    }

    public function request($patient_name)
    {
        $userId = Auth::id();
        $doctor = Doctor::where('user_id', $userId)->first();

        $patient = Patient::with('user')
        ->whereHas('user', function($query) use ($patient_name) {
            $query->where('name', 'like', '%' . $patient_name . '%');
        })
        ->first();

    if (!$patient) {
        return response()->json(['message' => 'لم يتم العثور على المريض: ' . $patient_name], 404);
    }

        DoctorPatientApproval::create([
                'doctor_id' => $doctor->id,
                'patient_id' => $patient->id,
                'status' => 'pending'
            ]);

            return response()->json([
                'message' => 'تم إرسال طلب موافقة للمريض',
                'requires_approval' => true
            ], 202);
    }
}

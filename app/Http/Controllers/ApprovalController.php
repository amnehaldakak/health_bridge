<?php

namespace App\Http\Controllers;
use App\Models\DoctorPatientApproval;
use App\Models\Patient;
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
}

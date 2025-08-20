<?php

namespace App\Http\Controllers;
use App\Models\MedicalCase;
use App\Models\Patient;
use App\Models\Doctor;
use App\Models\DoctorPatientApproval;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class MedicalCaseController extends Controller
{
    public function store(Request $request)
    {
        // إنشاء حالة مرضية جديدة
        /*$request->validate([
            'patient_id' => 'required|exists:patients,id',
            'chief_complaint' => 'required|string',
            'symptoms' => 'required|string',
            'medical_history' => 'required|string',
            'surgical_history' => 'required|string',
            'allergic_history' => 'required|string',
            'smoking_status' => 'required|string',
            'signs' => 'nullable|string',
            'vital_signs' => 'nullable|string',
            'clinical_examination_results' => 'nullable|string',
            'echo' => 'nullable|string',
            'lab_test' => 'nullable|string',
            'diagnosis' => 'required|string',
        ]);*/


        $userId = Auth::id();
    
        $doctor = Doctor::where('user_id', $userId)->first();

        if (!$doctor) {
        return response()->json([
        'message' => 'المستخدم الحالي ليس طبيباً مسجلاً'
        ], 403);
        }

        $approval = DoctorPatientApproval::where('doctor_id', $doctor->id)
            ->where('patient_id', $request->patient_id)
            ->first();

            // إذا لم توجد موافقة مسبقة
        if (!$approval) {
            // إنشاء طلب موافقة جديد
            DoctorPatientApproval::create([
                'doctor_id' => $doctor->id,
                'patient_id' => $request->patient_id,
                'status' => 'pending'
            ]);

            return response()->json([
                'message' => 'تم إرسال طلب موافقة للمريض',
                'requires_approval' => true
            ], 202);
        }

        // إذا كانت الموافقة مرفوضة أو قيد الانتظار
        if ($approval->status != 'approved') {
            return response()->json([
                'message' => 'يجب انتظار موافقة المريض قبل إضافة حالات جديدة',
                'approval_status' => $approval->status
            ], 403);
        }

        if ($request->hasFile('echo')) {
            $echoPath = $request->file('echo')->store('echo_files', 'public');
        }

        if ($request->hasFile('lab_test')) {
            $labTestPath = $request->file('lab_test')->store('lab_test_files', 'public');
        }

        // إذا كانت الموافقة موجودة ومقبولة
        $case = MedicalCase::create([
            'patient_id' => $request->patient_id,
            'doctor_id' => $doctor->id, 
            'chief_complaint' => $request->chief_complaint,
            'symptoms' => $request->symptoms,
            'medical_history' => $request->medical_history,
            'surgical_history' => $request->surgical_history,
            'allergic_history' => $request->allergic_history,
            'smoking_status' => $request->smoking_status,
            'signs' => $request->signs,
            'vital_signs' => $request->vital_signs,
            'clinical_examination_results' => $request->clinical_examination_results,
            'echo' => $echoPath,
            'lab_test' => $labTestPath,
            'diagnosis' => $request->diagnosis,
        ]);

        return response()->json([
            'message' => 'Case created successfully',
            'case' => $case
        ], 201);
    }

    
    public function update(Request $request, $case_id)
    {
        // تحديث حالة مرضية
        /*$request->validate([
            'chief_complaint' => 'sometimes|string',
            'symptoms' => 'sometimes|string',
            'medical_history' => 'sometimes|string',
            'surgical_history' => 'sometimes|string',
            'allergic_history' => 'sometimes|string',
            'smoking_status' => 'sometimes|string',
            'signs' => 'nullable|string',
            'vital_signs' => 'nullable|string',
            'clinical_examination_results' => 'nullable|string',
            'echo' => 'nullable|string',
            'lab_test' => 'nullable|string',
            'diagnosis' => 'sometimes|string',
        ]);*/


        $doctor_id=Auth::id();

        $case = MedicalCase::where('id', $case_id)
            ->where('doctor_id', $doctor_id)
            ->firstOrFail();

        if ($request->hasFile('echo')) {
            $echoPath = $request->file('echo')->store('echo_files', 'public');
            $case->echo = $echoPath;
        }

        if ($request->hasFile('lab_test')) {
            $labTestPath = $request->file('lab_test')->store('lab_test_files', 'public');
            $case->lab_test = $labTestPath;
        }

        $case->update([
            'chief_complaint' => $request->chief_complaint ?? $case->chief_complaint,
            'symptoms' => $request->symptoms ?? $case->symptoms,
            'medical_history' => $request->medical_history ?? $case->medical_history,
            'surgical_history' => $request->surgical_history ?? $case->surgical_history,
            'allergic_history' => $request->allergic_history ?? $case->allergic_history,
            'smoking_status' => $request->smoking_status ?? $case->smoking_status,
            'signs' => $request->signs ?? $case->signs,
            'vital_signs' => $request->vital_signs ?? $case->vital_signs,
            'clinical_examination_results' => $request->clinical_examination_results ?? $case->clinical_examination_results,
            'diagnosis' => $request->diagnosis ?? $case->diagnosis,
        ]);

        $case->save();

        return response()->json([
            'message' => 'Case updated successfully',
            'case' => $case
        ]);


    }


    // الحصول على قائمة المرضى لطبيب معين
    public function getDoctorPatients()
    {
        $doctorId = Auth::id();
        $doctor = Doctor::where('user_id', $doctorId)->first();
        $patients = Patient::whereHas('medicalCase', function($query) use ($doctor) {
            $query->where('doctor_id', $doctor->id);
        })
        ->with(['user' => function($query) {
            $query->select('id', 'name', 'email');
        }])
        ->withCount(['medicalCase as cases_count' => function($query) use ($doctor) {
            $query->where('doctor_id', $doctor->id);
        }])
        ->get([
            'id',
            'user_id',
            'birth_date',
            'gender',
            'phone',
            'chronic_diseases'
        ]);


    return response()->json([
        'success' => true,
        'patients' => $patients
    ]);
    }


    public function getPatientCasesByCurrentDoctor($patientId)
    {
    $doctorId = Auth::id();
    $doctor = Doctor::where('user_id', $doctorId)->first();

    $cases = MedicalCase::where('patient_id', $patientId)
        ->where('doctor_id', $doctor->id)
        ->with(['patient.user', 'doctor.user'])
        ->orderBy('created_at', 'desc')
        ->get();

        return response()->json([
        'success' => true,
        'total_cases' => $cases->count(),
        'cases' => $cases
    ]);
}


        // الحصول على حالات مريض معين
    public function getPatientCases($patientId)
    {
        $cases = MedicalCase::with(['doctor', 'patient'])
            ->where('patient_id', $patientId)
            ->get();

        return response()->json($cases);
    }

        // الحصول على تفاصيل حالة معينة
    public function show($caseId)
    {
        $case = MedicalCase::with(['doctor', 'patient'])
            ->where('id', $caseId)
            ->firstOrFail();

        return response()->json($case);
    }







}

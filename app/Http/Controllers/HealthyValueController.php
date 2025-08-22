<?php

namespace App\Http\Controllers;
use App\Models\Patient;
use App\Models\HealthyValue;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class HealthyValueController extends Controller
{
    public function store_value(Request $request,$id)
    {
        // تخزين قيمة جديدة
        $request->validate([
            'value' => 'required|integer',
            'valuee' => 'nullable|integer',
            'status' => 'nullable|string',
        ]);

        $userId = Auth::id();
        $patient = Patient::where('user_id', $userId)->first();

        $Healthy_Value = HealthyValue::create([
            'patient_id' => $patient->id,
            'disease_id' => $id,
            'value' => $request->value,
            'valuee' => $request->valuee, 
            'status' => $request->status,
        ]);
        return response()->json([
            'message' => 'healthy value stored successfully',
            'Healthy_Value' => $Healthy_Value
        ]);
    }

    public function show_value($id)
    {
        // الحصول على البيانات الصحية لمرض معين الخاصة بمريض معين

        $userId = Auth::id();
        $patient = Patient::where('user_id', $userId)->first();

        $Healthy_Value=HealthyValue::where('patient_id',$patient->id)
        ->where('disease_id', $id)->get();

        return response()->json($Healthy_Value); 
    }

    
    public function delete_value($id)
    {
        // حذف قيمة معينة
        //HealthyValue::findOrFail($id)->delete();
        $deleted = HealthyValue::where('values_id', $id)->delete();
        return response()->json(['message' => 'healthy value deleted successfully']);
    }
}

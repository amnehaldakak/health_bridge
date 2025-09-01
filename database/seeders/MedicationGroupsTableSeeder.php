<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MedicationGroupsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        for ($i = 1; $i <= 15; $i++) {
            $patientId = rand(1, 10);
            $doctorId = rand(1, 10);
            $caseId = (rand(0, 1)) ? rand(1, 20) : null;
            
            DB::table('medication_groups')->insert([
                'case_id' => $caseId,
                'patient_id' => $patientId,
                'doctor_id' => $doctorId,
                'prescription_date' => now()->subDays(rand(1, 30))->format('Y-m-d'),
                'description' => 'وصفة طبية للمريض ' . $patientId . ' بواسطة الطبيب ' . $doctorId,
                'created_at' => now()->subDays(rand(1, 30)),
                'updated_at' => now()->subDays(rand(1, 30))
            ]);
        }
    }
}
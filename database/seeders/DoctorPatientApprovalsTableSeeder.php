<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DoctorPatientApprovalsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // إنشاء موافقات عشوائية
        for ($i = 1; $i <= 10; $i++) {
            for ($j = 1; $j <= 10; $j++) {
                if (rand(0, 1)) { // 50% احتمال إنشاء موافقة
                    DB::table('doctor_patient_approvals')->insert([
                        'doctor_id' => $i,
                        'patient_id' => $j,
                        'status' => rand(0, 2) ? 'approved' : 'pending', // 66% approved, 33% pending
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            }
        }
    }
}

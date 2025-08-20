<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PatientsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $chronicDiseases = [
            'لا يوجد', 'سكري', 'ضغط', 'ربو', 'قلب',
            'كلى', 'كبد', 'أمراض دم', 'حساسية', 'أمراض عصبية'
        ];

        // إنشاء بيانات المرضى
        for ($i = 1; $i <= 10; $i++) {
            DB::table('patients')->insert([
                'user_id' => $i + 11, // 11 لأن 1 أدمن + 10 أطباء
                'birth_date' => now()->subYears(rand(18, 70))->format('Y-m-d'),
                'gender' => ($i % 2) ? 'male' : 'female',
                'phone' => '093' . rand(1000000, 9999999),
                'chronic_diseases' => $chronicDiseases[$i - 1],
                'created_at' => now(),
                'updated_at' => now()
            ]);
        }
    }
}

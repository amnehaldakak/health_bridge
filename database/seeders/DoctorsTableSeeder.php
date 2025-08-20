<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DoctorsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $specializations = [
            'قلب', 'أعصاب', 'عظام', 'باطنة', 'أطفال',
            'جلدية', 'عيون', 'أنف وأذن وحنجرة', 'نساء وتوليد', 'أسنان'
        ];

        // إنشاء بيانات الأطباء
        for ($i = 1; $i <= 10; $i++) {
            DB::table('doctors')->insert([
                'user_id' => $i + 1, // لأن المستخدم الأول هو الأدمن
                'specialization' => $specializations[$i - 1],
                'clinic_address' => 'عنوان العيادة ' . $i,
                'clinic_phone' => '091234567' . $i,
                'certificate_path' => 'certificates/doctor'.$i.'.pdf',
                'verification_status' => 'approved', // تم التحقق منهم
                'created_at' => now(),
                'updated_at' => now()
            ]);
        }
    }
}

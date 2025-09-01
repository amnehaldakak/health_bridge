<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MedicalCasesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $complaints = [
            'ألم في الصدر',
            'صداع شديد',
            'ضيق في التنفس',
            'ألم في البطن',
            'دوخة وإغماء',
            'ألم في المفاصل',
            'سعال مستمر',
            'ارتفاع في درجة الحرارة',
            'غثيان وتقيؤ',
            'آلام الظهر'
        ];

        $symptoms = [
            'ألم حاد في منتصف الصدر مع انتشار إلى الذراع اليسرى',
            'صداع نصفي مع حساسية للضوء والصوت',
            'صعوبة في التنفس عند بذل مجهود',
            'ألم في الربع العلوي الأيمن من البطن',
            'دوخة عند الوقوف مفاجئ مع تشوش في الرؤية',
            'تورم واحمرار في المفاصل مع ألم شديد',
            'سعال جاف مصحوب ببلغم أحياناً',
            'حمى وقشعريرة مع تعرق ليلي',
            'غثيان بعد تناول الطعام مع تقيؤ متكرر',
            'ألم أسفل الظهر مع صعوبة في الحركة'
        ];

        $diagnoses = [
            'ذبحة صدرية غير مستقرة',
            'صداع نصفي (Migraine)',
            'ربو قصبي',
            'التهاب المرارة',
            'انخفاض ضغط الدم الانتصابي',
            'التهاب المفاصل الروماتويدي',
            'التهاب رئوي',
            'عدوى فيروسية',
            'التهاب المعدة',
            'انزلاق غضروفي'
        ];

        for ($i = 1; $i <= 20; $i++) {
            $patientId = rand(1, 10);
            $doctorId = rand(1, 10);
            
            DB::table('medical_cases')->insert([
                'patient_id' => $patientId,
                'doctor_id' => $doctorId,
                'chief_complaint' => $complaints[array_rand($complaints)],
                'symptoms' => $symptoms[array_rand($symptoms)],
                'medical_history' => 'تاريخ طبي للمريض ' . $patientId,
                'surgical_history' => 'تاريخ جراحي للمريض ' . $patientId,
                'allergic_history' => 'حساسية تجاه ' . (rand(0, 1) ? 'البنسلين' : 'لا يوجد'),
                'smoking_status' => (rand(0, 1) ? 'مدخن' : 'غير مدخن'),
                'signs' => 'علامات سريرية ملاحظة',
                'vital_signs' => 'ضغط: 120/80, نبض: 75, حرارة: 36.8',
                'clinical_examination_results' => 'نتائج الفحص السريري طبيعية في معظمها',
                'echo' => (rand(0, 1) ? 'نتائج Echo طبيعية' : null),
                'lab_test' => 'تحاليل الدم ضمن المعدل الطبيعي',
                'diagnosis' => $diagnoses[array_rand($diagnoses)],
                'created_at' => now()->subDays(rand(1, 365)),
                'updated_at' => now()->subDays(rand(1, 365))
            ]);
        }
    }
}
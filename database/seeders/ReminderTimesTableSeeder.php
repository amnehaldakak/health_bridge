<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Medication;
use App\Models\ReminderTime;
use Carbon\Carbon;

class ReminderTimesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // الحصول على جميع الأدوية
        $medications = Medication::all();
        
        foreach ($medications as $medication) {
            $this->generateRemindersForMedication($medication->medication_id);
        }
    }

    /**
     * إنشاء تذكيرات لدواء معين
     */
    private function generateRemindersForMedication($medicationId)
    {
        if (!is_numeric($medicationId)) {
            throw new \Exception('Medication ID must be numeric');
        }

        $medication = Medication::where('medication_id', $medicationId)->first();
        
        if (!$medication) {
            throw new \Exception('Medication not found with ID: ' . $medicationId);
        }

        // ✅ التأكد من وجود البيانات المطلوبة
        if (!$medication->start_date || !$medication->first_dose_time) {
            throw new \Exception('Medication is missing start date or first dose time');
        }

        $startDate = Carbon::parse($medication->start_date);
        $firstDoseTime = Carbon::parse($medication->first_dose_time);
        $frequency = $medication->frequency;
        $duration = $medication->duration;

        $interval = 24 / $frequency;

        for ($day = 0; $day < $duration; $day++) {
            $currentDate = $startDate->copy()->addDays($day);

            for ($dose = 0; $dose < $frequency; $dose++) {
                $doseTime = $firstDoseTime->copy()->addHours($dose * $interval);

                // إذا كان وقت الجرعة قبل وقت الجرعة الأولى، نضيف يوم
                if ($doseTime->format('H:i') < $firstDoseTime->format('H:i')) {
                    $currentDate->addDay();
                }
                
                // التحقق من عدم وجود تذكير مسبق بنفس الوقت
                $existingReminder = ReminderTime::where('medication_id', $medication->medication_id)
                    ->where('date', $currentDate->format('Y-m-d'))
                    ->where('time', $doseTime->format('H:i:s'))
                    ->first();

                if (!$existingReminder) {
                    ReminderTime::create([
                        'medication_id' => $medication->medication_id,
                        'date' => $currentDate->format('Y-m-d'),
                        'time' => $doseTime->format('H:i:s'),
                        'status' => rand(0, 1), // حالة عشوائية لأغراض الاختبار
                        'created_at' => now(),
                        'updated_at' => now()
                    ]);
                }
            }
        }
    }
}
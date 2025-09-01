<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MedicationsTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $medications = [
            ['name' => 'أسبرين', 'dosage' => '100 ملغ'],
            ['name' => 'باراسيتامول', 'dosage' => '500 ملغ'],
            ['name' => 'أموكسيسيلين', 'dosage' => '500 ملغ'],
            ['name' => 'أتورفاستاتين', 'dosage' => '20 ملغ'],
            ['name' => 'لوزارتان', 'dosage' => '50 ملغ'],
            ['name' => 'ميتفورمين', 'dosage' => '850 ملغ'],
            ['name' => 'أوميبرازول', 'dosage' => '20 ملغ'],
            ['name' => 'سيمفاستاتين', 'dosage' => '40 ملغ'],
            ['name' => 'أملوديبين', 'dosage' => '5 ملغ'],
            ['name' => 'ديكلوفيناك', 'dosage' => '50 ملغ']
        ];

        for ($i = 1; $i <= 30; $i++) {
            $med = $medications[array_rand($medications)];
            $groupId = rand(1, 15);
            
            DB::table('medications')->insert([
                'group_id' => $groupId,
                'name' => $med['name'],
                'dosage' => $med['dosage'],
                'frequency' => rand(1, 3),
                'duration' => rand(7, 30),
                'start_date' => now()->subDays(rand(1, 10))->format('Y-m-d'),
                'first_dose_time' => rand(8, 20) . ':00:00',
                'patient_confirmed' => (bool)rand(0, 1),
                'created_at' => now()->subDays(rand(1, 10)),
                'updated_at' => now()->subDays(rand(1, 10))
            ]);
        }
    }
}
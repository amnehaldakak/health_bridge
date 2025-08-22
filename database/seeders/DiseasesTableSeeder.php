<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Disease;

class DiseasesTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {

            Disease::create([
                'name' => 'ضغط الدم',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
    
            Disease::create([
                'name' => 'سكري',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
    
            Disease::create([
                'name' => 'الصحة النفسية',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
    
            Disease::create([
                'name' => 'الوزن',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        
    }
}

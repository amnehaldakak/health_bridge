<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UsersTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // إنشاء الأدمن
        DB::table('users')->insert([
            'name' => 'مدير النظام',
            'email' => 'admin@example.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'is_approved' => true,
            'created_at' => now(),
            'updated_at' => now()
        ]);

        // إنشاء 10 أطباء
        for ($i = 1; $i <= 10; $i++) {
            DB::table('users')->insert([
                'name' => 'طبيب ' . $i,
                'email' => 'doctor'.$i.'@example.com',
                'password' => Hash::make('password'),
                'role' => 'doctor',
                'is_approved' => true, // تمت الموافقة عليهم من الأدمن
                'created_at' => now(),
                'updated_at' => now()
            ]);
        }

        // إنشاء 10 مرضى
        for ($i = 1; $i <= 10; $i++) {
            DB::table('users')->insert([
                'name' => 'مريض ' . $i,
                'email' => 'patient'.$i.'@example.com',
                'password' => Hash::make('password'),
                'role' => 'patient',
                'is_approved' => true, // تمت الموافقة عليهم
                'created_at' => now(),
                'updated_at' => now()
            ]);
        }
    }
    
}

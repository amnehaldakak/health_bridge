<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\User::create([
        'name' => 'Admin',
        'email' => 'admin@example.com',
        'password' => bcrypt('admin123'), // غيّر كلمة السر
        'role' => 'admin',
        'is_approved' => true
        ]);
    
    $this->command->info('تم إنشاء حساب الآدمن بنجاح!');
    }
}

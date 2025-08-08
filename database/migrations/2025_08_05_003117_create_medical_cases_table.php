<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('medical_cases', function (Blueprint $table) {
            $table->id('case_id');
            $table->foreignId('doctor_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('patient_id')->constrained('users')->onDelete('cascade');
            $table->text('chief_complaint');
            $table->text('symptoms');
            $table->text('medical_history');
            $table->text('surgical_history');
            $table->text('allergic_history');
            $table->string('smoking_status');
            $table->text('signs')->nullable();
            $table->text('vital_signs')->nullable();
            $table->text('clinical_examination_results')->nullable();
            $table->text('echo')->nullable();
            $table->text('lab_test')->nullable();
            $table->text('diagnosis');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('medical_cases');
    }
};

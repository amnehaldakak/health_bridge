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
        Schema::create('medication_groups', function (Blueprint $table) {
            $table->id('group_id');
            $table->foreignId('case_id')->nullable()->references('id')->on('medical_cases')->onDelete('cascade');
            $table->foreignId('patient_id')->references('id')->on('patients');
            $table->foreignId('doctor_id')->nullable()->references('id')->on('doctors');
            $table->date('prescription_date');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('medication_groups');
    }
};

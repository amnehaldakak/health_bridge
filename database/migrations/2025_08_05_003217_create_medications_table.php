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
        Schema::create('medications', function (Blueprint $table) {
            $table->id('medication_id');
            $table->foreignId('group_id')->references('group_id')->on('medication_groups');
            $table->foreignId('patient_id')->references('id')->on('users');
            $table->string('name');
            $table->string('dosage');
            $table->integer('frequency');
            $table->integer('duration');
            $table->date('start_date');
            $table->time('first_dose_time');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('medications');
    }
};

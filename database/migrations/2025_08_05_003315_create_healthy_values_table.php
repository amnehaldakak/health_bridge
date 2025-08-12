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
        Schema::create('healthy_values', function (Blueprint $table) {
            $table->id('values_id');
            $table->foreignId('disease_id')->references('disease_id')->on('diseases');
            //$table->foreignId('patient_id')->references('patient_id')->on('patients');
            $table->integer('value');
            $table->integer('valuee')->default(0);
            $table->string('status')->default('null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('healthy_values');
    }
};

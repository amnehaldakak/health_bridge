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
        Schema::create('community_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('community_id')->references('id')->on('communities')->cascadeOnDelete();
            $table->foreignId('patient_id')->nullable()->references('id')->on('patients');
            $table->foreignId('doctor_id')->nullable()->references('id')->on('doctors');
            $table->foreignId('case_id')->nullable()->references('id')->on('medical_cases')->nullOnDelete();
            $table->string('title');
            $table->text('content');
            $table->boolean('is_public')->default(true);
            $table->timestamps();

        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('community_posts');
    }
};

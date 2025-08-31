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
        Schema::create('community_members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('community_id')->references('id')->on('communities')->cascadeOnDelete();
            $table->foreignId('patient_id')->nullable()->references('id')->on('patients');
            $table->foreignId('doctor_id')->nullable()->references('id')->on('doctors');
            $table->enum('role', ['admin', 'member'])->default('member');
            $table->timestamp('join_date')->useCurrent();
            $table->timestamps();
            
            $table->unique(['community_id', 'patient_id']);
            $table->unique(['community_id', 'doctor_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('community_members');
    }
};

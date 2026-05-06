<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vouchers', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code')->nullable()->unique();
            $table->enum('type', ['percent', 'nominal']);
            $table->decimal('value', 10, 2);
            $table->dateTime('start_date')->nullable();
            $table->dateTime('expired_date')->nullable();
            $table->decimal('min_purchase', 10, 2)->default(0);
            $table->integer('quota')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vouchers');
    }
};

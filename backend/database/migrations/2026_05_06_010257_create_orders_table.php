<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null'); // Nullable for guests
            $table->string('guest_id')->nullable(); // Device ID or Temp Session
            $table->string('customer_name')->nullable(); // For guests
            $table->string('customer_phone')->nullable(); // For guests
            $table->string('idempotency_key')->unique()->nullable(); // Anti double submit
            $table->string('order_number')->unique();
            $table->enum('type', ['dine-in', 'delivery']);
            $table->enum('status', ['pending', 'processing', 'completed', 'cancelled'])->default('pending');
            $table->decimal('total_amount', 12, 2);
            $table->decimal('discount_amount', 12, 2)->default(0); // Member benefit
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};

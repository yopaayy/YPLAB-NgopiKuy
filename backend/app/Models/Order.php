<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id', 
        'guest_id',
        'customer_name',
        'customer_phone',
        'idempotency_key',
        'order_number', 
        'type', 
        'status', 
        'total_amount', 
        'discount_amount',
        'notes',
        'voucher_id',
    ];

    protected $casts = [
        'total_amount' => 'float',
        'discount_amount' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }
}

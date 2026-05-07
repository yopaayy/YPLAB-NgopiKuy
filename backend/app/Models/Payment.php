<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = ['order_id', 'method', 'status', 'amount', 'transaction_id', 'snap_token'];

    protected $casts = [
        'amount' => 'float',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}

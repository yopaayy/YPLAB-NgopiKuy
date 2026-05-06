<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Voucher extends Model
{
    protected $fillable = [
        'name',
        'code',
        'type',
        'value',
        'start_date',
        'expired_date',
        'min_purchase',
        'quota'
    ];

    protected $casts = [
        'value' => 'float',
        'min_purchase' => 'float',
        'start_date' => 'datetime',
        'expired_date' => 'datetime',
    ];

    public function userVouchers()
    {
        return $this->hasMany(UserVoucher::class);
    }
}

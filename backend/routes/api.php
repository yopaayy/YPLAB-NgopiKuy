<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\OrderController;

use App\Http\Controllers\Api\VoucherController;
use App\Http\Controllers\Api\MidtransController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Public routes for Categories, Menus, Vouchers
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{category}', [CategoryController::class, 'show']);
Route::get('/menus', [MenuController::class, 'index']);
Route::get('/menus/{menu}', [MenuController::class, 'show']);
Route::get('/vouchers', [VoucherController::class, 'index']);

// Public Checkout with Rate Limiting (e.g. 5 requests per minute)
Route::middleware('throttle:5,1')->post('/orders', [OrderController::class, 'store']);

// Midtrans Webhook Callback
Route::post('/midtrans/callback', [MidtransController::class, 'callback']);

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::put('/user/profile', [AuthController::class, 'updateProfile']);

    // Orders (Logged in specific)
    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    
    // Admin only routes
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::put('/categories/{category}', [CategoryController::class, 'update']);
    Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);
    
    Route::post('/menus', [MenuController::class, 'store']);
    Route::put('/menus/{menu}', [MenuController::class, 'update']);
    Route::delete('/menus/{menu}', [MenuController::class, 'destroy']);
    
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);

    // Vouchers (Admin)
    Route::post('/vouchers', [VoucherController::class, 'store']);
    Route::put('/vouchers/{voucher}', [VoucherController::class, 'update']);
    Route::delete('/vouchers/{voucher}', [VoucherController::class, 'destroy']);
    
    // Vouchers (Member)
    Route::post('/vouchers/{voucher}/claim', [VoucherController::class, 'claim']);
    Route::get('/my-vouchers', [VoucherController::class, 'myVouchers']);
});

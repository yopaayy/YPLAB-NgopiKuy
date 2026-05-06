<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Menu;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
        * Seed the application's database.
        */
    public function run(): void
    {
        // 1. Create Admin User
        User::factory()->create([
            'name' => 'Admin NgopiKuy',
            'email' => 'admin@ngopikuy.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
            'phone_number' => '081234567890',
        ]);

        // 2. Create Regular User
        User::factory()->create([
            'name' => 'Budi Pelanggan',
            'email' => 'budi@gmail.com',
            'password' => Hash::make('password123'),
            'role' => 'user',
            'phone_number' => '089876543210',
        ]);

        // 3. Create Categories
        $catEspresso = Category::create([
            'name' => 'Espresso Based',
            'description' => 'Kopi pekat dengan dasar espresso murni',
            'icon' => 'coffee',
        ]);

        $catMilk = Category::create([
            'name' => 'Milk Based',
            'description' => 'Kopi dengan perpaduan susu segar',
            'icon' => 'coffee_maker',
        ]);

        $catNonCoffee = Category::create([
            'name' => 'Non Coffee',
            'description' => 'Minuman segar tanpa kopi',
            'icon' => 'local_drink',
        ]);

        $catSnack = Category::create([
            'name' => 'Snacks',
            'description' => 'Cemilan teman ngopi',
            'icon' => 'cookie',
        ]);

        // 4. Create Menus
        $menus = [
            [
                'category_id' => $catEspresso->id,
                'name' => 'Americano',
                'description' => 'Espresso dengan tambahan air panas, cocok untuk pecinta kopi hitam.',
                'price' => 18000,
                'image' => 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catEspresso->id,
                'name' => 'Espresso Single Shot',
                'description' => 'Pekat, strong, dan langsung melek.',
                'price' => 15000,
                'image' => 'https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catMilk->id,
                'name' => 'Cappuccino',
                'description' => 'Perpaduan seimbang antara espresso, susu, dan busa susu.',
                'price' => 25000,
                'image' => 'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catMilk->id,
                'name' => 'Cafe Latte',
                'description' => 'Susu yang lebih dominan, memberikan rasa kopi yang sangat lembut.',
                'price' => 24000,
                'image' => 'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catMilk->id,
                'name' => 'Kopi Susu Gula Aren',
                'description' => 'Menu andalan! Espresso, susu segar, dan manis legitnya gula aren asli.',
                'price' => 22000,
                'image' => 'https://images.unsplash.com/photo-1558024220-b6118b6fc1c8?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catNonCoffee->id,
                'name' => 'Matcha Latte',
                'description' => 'Teh hijau premium dari Jepang dipadukan dengan susu segar.',
                'price' => 26000,
                'image' => 'https://images.unsplash.com/photo-1536514498073-50e69d39c6cf?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catNonCoffee->id,
                'name' => 'Red Velvet Latte',
                'description' => 'Rasa kue red velvet yang lembut dalam bentuk minuman.',
                'price' => 26000,
                'image' => 'https://images.unsplash.com/photo-1620189507195-68309c04c4d0?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catSnack->id,
                'name' => 'Croissant Butter',
                'description' => 'Renyah di luar, lembut dan buttery di dalam.',
                'price' => 20000,
                'image' => 'https://images.unsplash.com/photo-1555507036-ab1f40ce88cb?auto=format&fit=crop&w=500&q=60',
            ],
            [
                'category_id' => $catSnack->id,
                'name' => 'French Fries',
                'description' => 'Kentang goreng renyah dengan taburan bumbu gurih.',
                'price' => 15000,
                'image' => 'https://images.unsplash.com/photo-1576107232684-1279f390859f?auto=format&fit=crop&w=500&q=60',
            ],
        ];

        foreach ($menus as $menu) {
            Menu::create($menu);
        }
    }
}

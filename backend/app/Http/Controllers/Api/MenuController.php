<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Menu;
use Illuminate\Http\Request;

class MenuController extends Controller
{
    public function index()
    {
        // Load relationships to get category name
        return response()->json(Menu::with('category')->get());
    }

    public function show(Menu $menu)
    {
        return response()->json($menu->load('category'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'description' => 'nullable|string',
            'image' => 'nullable|string',
            'is_available' => 'boolean',
        ]);

        $menu = Menu::create($request->all());

        return response()->json($menu, 201);
    }

    public function update(Request $request, Menu $menu)
    {
        $menu->update($request->all());
        return response()->json($menu);
    }

    public function destroy(Menu $menu)
    {
        $menu->delete();
        return response()->json(null, 204);
    }
}

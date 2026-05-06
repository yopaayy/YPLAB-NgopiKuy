import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/menu.dart';
import '../services/api_service.dart';

class MenuProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Category> _categories = [];
  List<Menu> _menus = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  List<Menu> get menus => _menus;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.dio.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _categories = data.map((json) => Category.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchMenus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/menus');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _menus = data.map((json) => Menu.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching menus: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.wait([
      fetchCategories(),
      fetchMenus(),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/menu.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<CartItem> _items = [];
  bool _isLoading = false;
  Map<String, dynamic>? _selectedVoucher;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get selectedVoucher => _selectedVoucher;

  int get totalItems {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotalPrice {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  double get discountAmount {
    if (_selectedVoucher == null) return 0.0;
    
    final voucher = _selectedVoucher!['voucher'];
    final type = voucher['type'];
    final value = double.parse(voucher['value'].toString());
    
    double discount = 0.0;
    if (type == 'percent') {
      discount = subtotalPrice * (value / 100);
    } else {
      discount = value;
    }
    
    return discount > subtotalPrice ? subtotalPrice : discount;
  }

  double get totalPrice {
    return subtotalPrice - discountAmount;
  }

  void applyVoucher(Map<String, dynamic>? voucher) {
    _selectedVoucher = voucher;
    notifyListeners();
  }

  void addToCart(Menu menu) {
    final existingIndex = _items.indexWhere((item) => item.menu.id == menu.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(menu: menu));
    }
    notifyListeners();
  }

  void decreaseQuantity(int menuId) {
    final existingIndex = _items.indexWhere((item) => item.menu.id == menuId);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity -= 1;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int menuId) {
    _items.removeWhere((item) => item.menu.id == menuId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _selectedVoucher = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkout({
    required String type,
    required String paymentMethod,
    String? customerName,
    String? customerPhone,
    String? notes,
  }) async {
    if (_items.isEmpty) return {'success': false, 'message': 'Cart is empty'};

    if (_selectedVoucher != null) {
      final minPurchase = double.parse(_selectedVoucher!['voucher']['min_purchase'].toString());
      if (subtotalPrice < minPurchase) {
        return {'success': false, 'message': 'Minimum pembelian untuk voucher ini adalah Rp ${minPurchase.toInt()}'};
      }
    }

    _isLoading = true;
    notifyListeners();

    try {
      final idempotencyKey = const Uuid().v4();
      
      final payload = {
        'type': type,
        'payment_method': paymentMethod,
        'idempotency_key': idempotencyKey,
        'notes': notes,
        'voucher_id': _selectedVoucher?['voucher_id'],
        'items': _items.map((item) => {
          'menu_id': item.menu.id,
          'quantity': item.quantity,
          'price': item.menu.price,
        }).toList(),
      };

      if (customerName != null && customerName.isNotEmpty) {
        payload['customer_name'] = customerName;
      }
      if (customerPhone != null && customerPhone.isNotEmpty) {
        payload['customer_phone'] = customerPhone;
      }

      final response = await _apiService.dio.post('/orders', data: payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        clearCart();
        _isLoading = false;
        notifyListeners();
        return {'success': true, 'data': response.data};
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Checkout failed. Please try again.'};
    }

    _isLoading = false;
    notifyListeners();
    return {'success': false, 'message': 'Unknown error occurred'};
  }
}

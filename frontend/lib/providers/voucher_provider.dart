import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/voucher.dart';
import '../services/api_service.dart';

class VoucherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Voucher> _publicVouchers = [];
  List<dynamic> _myVouchers = [];
  bool _isLoading = false;

  List<Voucher> get publicVouchers => _publicVouchers;
  List<dynamic> get myVouchers => _myVouchers;
  bool get isLoading => _isLoading;

  Future<void> fetchPublicVouchers() async {
    try {
      final response = await _apiService.dio.get('/vouchers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _publicVouchers = data.map((json) => Voucher.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching vouchers: $e');
    }
  }

  Future<void> fetchMyVouchers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/my-vouchers');
      if (response.statusCode == 200) {
        _myVouchers = response.data;
      }
    } catch (e) {
      debugPrint('Error fetching my vouchers: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> claimVoucher(int voucherId) async {
    try {
      final response = await _apiService.dio.post('/vouchers/$voucherId/claim');
      if (response.statusCode == 201) {
        await fetchMyVouchers(); // Refresh my vouchers
        return {'success': true, 'message': 'Voucher berhasil diklaim!'};
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null && e.response?.data != null) {
          return {'success': false, 'message': e.response?.data['message'] ?? 'Gagal klaim voucher'};
        }
      }
    }
    return {'success': false, 'message': 'Terjadi kesalahan sistem'};
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const SuccessScreen({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orderNumber = orderData['order_number'] ?? '-';
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              const Text(
                'Pesanan Berhasil Dibuat!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.5, end: 0),
              
              const SizedBox(height: 16),
              
              Text(
                'Nomor Pesanan:\n$orderNumber',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: colorScheme.primary, fontWeight: FontWeight.bold),
              ).animate().fade(delay: 400.ms),
              
              const SizedBox(height: 24),
              
              const Text(
                'Pemberitahuan lebih lanjut akan kami kirimkan melalui WhatsApp ke nomor Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ).animate().fade(delay: 600.ms),
              
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Home'),
                ),
              ).animate().fade(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

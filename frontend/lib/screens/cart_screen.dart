import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/voucher_provider.dart' as import_voucher;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'success_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _orderType = 'dine-in';
  String _paymentMethod = 'cash';

  void _handleCheckout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Guest validation
    if (!auth.isAuthenticated) {
      if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest wajib mengisi Nama dan Nomor HP')),
        );
        return;
      }
    }

    final result = await cart.checkout(
      type: _orderType,
      paymentMethod: _paymentMethod,
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      notes: _notesController.text,
    );

    if (result['success']) {
      final orderData = result['data'];
      final payment = orderData['payment'];
      
      if (payment != null && payment['snap_token'] != null) {
        final snapToken = payment['snap_token'];
        final snapUrl = Uri.parse('https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken');
        try {
          await launchUrl(snapUrl, mode: LaunchMode.inAppWebView);
        } catch (e) {
          debugPrint('Could not launch Midtrans URL: $e');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SuccessScreen(orderData: orderData),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // Custom Curved Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Cart',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 48), // Balance for centering
              ],
            ),
          ),

          if (cart.items.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Order Type Toggles
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          _buildOrderTypeToggle('Dine-In', 'dine-in', colorScheme),
                          _buildOrderTypeToggle('Takeaway', 'takeaway', colorScheme),
                          _buildOrderTypeToggle('Delivery', 'delivery', colorScheme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cart Items
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Image
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: colorScheme.secondary.withOpacity(0.1),
                                  image: item.menu.image != null
                                      ? DecorationImage(image: NetworkImage(item.menu.image!), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: item.menu.image == null
                                    ? Icon(Icons.coffee, color: colorScheme.primary)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menu.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${item.menu.price.toInt()}',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                                    ),
                                  ],
                                ),
                              ),
                              // Counter
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      color: colorScheme.primary,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                      onPressed: () => cart.decreaseQuantity(item.menu.id),
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      color: colorScheme.primary,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                      onPressed: () => cart.addToCart(item.menu),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ).animate().fade(delay: Duration(milliseconds: 100 * index)).slideX();
                      },
                    ),

                    const SizedBox(height: 24),
                    
                    // Guest Info Form
                    if (!auth.isAuthenticated) ...[
                      const Text('Guest Information', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildTextField(_nameController, 'Full Name', Icons.person_outline),
                      const SizedBox(height: 12),
                      _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, isPhone: true),
                      const SizedBox(height: 24),
                    ],

                    // Payment Method & Voucher
                    const Text('Payment & Promo', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _paymentMethod,
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.payment),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                        DropdownMenuItem(value: 'transfer', child: Text('Bank Transfer')),
                      ],
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    const SizedBox(height: 12),
                    
                    if (auth.isAuthenticated)
                      Consumer<import_voucher.VoucherProvider>(
                        builder: (context, voucherProv, child) {
                          final displayVouchers = voucherProv.myVouchers.where((v) => v['status'] != 'expired').toList();
                          return DropdownButtonFormField<int?>(
                            initialValue: cart.selectedVoucher?['voucher_id'],
                            decoration: InputDecoration(
                              labelText: 'Promo Code',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.local_offer_outlined, color: colorScheme.primary),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(value: null, child: Text('No Promo')),
                              ...displayVouchers.map((v) {
                                final voucher = v['voucher'];
                                final isUsed = v['status'] == 'used';
                                return DropdownMenuItem<int?>(
                                  value: v['voucher_id'],
                                  enabled: !isUsed,
                                  child: Text(
                                    isUsed ? '${voucher['name']} (Used)' : voucher['name'],
                                    style: TextStyle(color: isUsed ? Colors.grey : Colors.black),
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              if (val == null) {
                                cart.applyVoucher(null);
                              } else {
                                final selected = displayVouchers.firstWhere((v) => v['voucher_id'] == val);
                                cart.applyVoucher(selected);
                              }
                            },
                          );
                        },
                      ),
                      
                    const SizedBox(height: 32),
                    
                    // Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                        Text('Rp ${cart.subtotalPrice.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (cart.discountAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount', style: TextStyle(color: Colors.green)),
                          Text('- Rp ${cart.discountAmount.toInt()}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          'Rp ${cart.totalPrice.toInt()}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: cart.isLoading ? null : _handleCheckout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: cart.isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeToggle(String title, String value, ColorScheme colorScheme) {
    final isSelected = _orderType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _orderType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

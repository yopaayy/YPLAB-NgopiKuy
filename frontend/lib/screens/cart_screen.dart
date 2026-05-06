import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/voucher_provider.dart' as import_voucher;
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
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SuccessScreen(orderData: result['data']),
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
      appBar: AppBar(
        title: const Text('Keranjang 🛒'),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.remove_shopping_cart, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Keranjangmu masih kosong!', style: TextStyle(fontSize: 18)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                            image: item.menu.image != null
                                ? DecorationImage(
                                    image: NetworkImage(item.menu.image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        title: Text(item.menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Rp ${item.menu.price.toInt()} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: colorScheme.primary,
                              onPressed: () => cart.decreaseQuantity(item.menu.id),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: colorScheme.primary,
                              onPressed: () => cart.addToCart(item.menu),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Form Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!auth.isAuthenticated) ...[
                        const Text('Informasi Pemesan (Guest)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Nama Lengkap', isDense: true),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Nomor WhatsApp', isDense: true),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _orderType,
                              decoration: const InputDecoration(labelText: 'Tipe Order', isDense: true),
                              items: const [
                                DropdownMenuItem(value: 'dine-in', child: Text('Dine-in')),
                                DropdownMenuItem(value: 'delivery', child: Text('Delivery')),
                              ],
                              onChanged: (val) => setState(() => _orderType = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _paymentMethod,
                              decoration: const InputDecoration(labelText: 'Pembayaran', isDense: true),
                              items: const [
                                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                                DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                                DropdownMenuItem(value: 'transfer', child: Text('Transfer Bank')),
                              ],
                              onChanged: (val) => setState(() => _paymentMethod = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Voucher Dropdown for Authenticated users
                      if (auth.isAuthenticated) ...[
                        Consumer<import_voucher.VoucherProvider>(
                          builder: (context, voucherProv, child) {
                            final displayVouchers = voucherProv.myVouchers
                                .where((v) => v['status'] != 'expired')
                                .toList();

                            return DropdownButtonFormField<int?>(
                              value: cart.selectedVoucher?['voucher_id'],
                              decoration: const InputDecoration(
                                labelText: 'Gunakan Voucher (Opsional)', 
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.local_offer, color: Colors.orange),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Tidak pakai voucher'),
                                ),
                                ...displayVouchers.map((v) {
                                  final voucher = v['voucher'];
                                  final name = voucher['name'];
                                  final minPurchase = voucher['min_purchase'];
                                  final isUsed = v['status'] == 'used';
                                  
                                  return DropdownMenuItem<int?>(
                                    value: v['voucher_id'],
                                    enabled: !isUsed,
                                    child: Text(
                                      isUsed 
                                        ? '$name (Sudah digunakan)' 
                                        : '$name (Min. Rp ${double.parse(minPurchase.toString()).toInt()})',
                                      style: TextStyle(
                                        color: isUsed ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              isExpanded: true,
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
                        const SizedBox(height: 16),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(fontSize: 14)),
                          Text('Rp ${cart.subtotalPrice.toInt()}', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      if (cart.discountAmount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Diskon Voucher', style: TextStyle(fontSize: 14, color: Colors.green)),
                            Text('- Rp ${cart.discountAmount.toInt()}', style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            'Rp ${cart.totalPrice.toInt()}',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: cart.isLoading ? null : _handleCheckout,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: cart.isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Proses Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}

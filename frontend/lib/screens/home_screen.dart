import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/voucher_provider.dart';
import '../models/menu.dart';
import 'login_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).loadAllData();
    });
  }

  // Helper method to convert Icon string from backend to Flutter IconData
  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'coffee': return Icons.coffee;
      case 'coffee_maker': return Icons.coffee_maker;
      case 'local_drink': return Icons.local_drink;
      case 'cookie': return Icons.cookie;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Menu NgopiKuy ☕'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cart.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cart.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              if (auth.isAuthenticated) {
                return IconButton(
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: auth.user?['avatar'] != null && auth.user!['avatar'].toString().isNotEmpty
                        ? NetworkImage(auth.user!['avatar'])
                        : null,
                    child: auth.user?['avatar'] == null || auth.user!['avatar'].toString().isEmpty
                        ? const Icon(Icons.person, size: 18, color: Colors.white)
                        : null,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                );
              } else {
                return TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Login'),
                );
              }
            },
          )
        ],
      ),
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => menuProvider.loadAllData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pesan Kopi\nFavoritmu Sekarang!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: colorScheme.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Order Now'),
                          )
                        ],
                      ),
                    ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 32),

                    // Vouchers
                    Consumer<VoucherProvider>(
                      builder: (context, voucherProv, child) {
                        if (voucherProv.publicVouchers.isEmpty) return const SizedBox.shrink();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voucher Spesial Untukmu 🎫',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ).animate().fade(delay: 100.ms),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: voucherProv.publicVouchers.length,
                                itemBuilder: (context, index) {
                                  final voucher = voucherProv.publicVouchers[index];
                                  return Container(
                                    width: 280,
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: colorScheme.secondary.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.local_offer, size: 40, color: colorScheme.primary),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                voucher.name,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                voucher.type == 'percent' 
                                                    ? 'Diskon ${voucher.value.toInt()}%' 
                                                    : 'Potongan Rp ${voucher.value.toInt()}',
                                                style: TextStyle(color: colorScheme.primary, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            final auth = Provider.of<AuthProvider>(context, listen: false);
                                            if (!auth.isAuthenticated) {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                                              );
                                              return;
                                            }
                                            
                                            // Claim process
                                            final result = await voucherProv.claimVoucher(voucher.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(result['message'])),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: colorScheme.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            minimumSize: Size.zero,
                                          ),
                                          child: const Text('Klaim', style: TextStyle(fontSize: 12)),
                                        )
                                      ],
                                    ),
                                  ).animate().fade(delay: Duration(milliseconds: 200 + (index * 100))).slideX();
                                },
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        );
                      },
                    ),
                    
                    // Categories
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fade(delay: 200.ms),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: menuProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = menuProvider.categories[index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _getIconData(category.icon),
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.name,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ).animate().fade(delay: Duration(milliseconds: 300 + (index * 100))).scale();
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Menus Grid
                    Text(
                      'Menu Spesial',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fade(delay: 400.ms),
                    const SizedBox(height: 16),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: menuProvider.menus.length,
                      itemBuilder: (context, index) {
                        final menu = menuProvider.menus[index];
                        return _buildMenuCard(context, menu, index);
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMenuCard(BuildContext context, Menu menu, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: menu.image != null
                  ? Image.network(
                      menu.image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.coffee, color: Colors.grey[400], size: 40),
                    ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${menu.price.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      cart.addToCart(menu);
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${menu.name} ditambahkan!'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tambah', style: TextStyle(fontSize: 12)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: Duration(milliseconds: 500 + (index * 50))).slideY(begin: 0.1, end: 0);
  }
}

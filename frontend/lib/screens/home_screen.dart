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
    final auth = Provider.of<AuthProvider>(context);
    
    final String greeting = 'Good Morning!';
    final String userName = auth.isAuthenticated ? (auth.user?['name'] ?? 'Guest') : 'Guest';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => menuProvider.loadAllData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Curved Header
                    Container(
                      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    greeting,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => const CartScreen()),
                                          );
                                        },
                                      ),
                                      if (cart.totalItems > 0)
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${cart.totalItems}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ).animate().scale(duration: 200.ms),
                                        ),
                                    ],
                                  ),
                                  if (auth.isAuthenticated)
                                    PopupMenuButton<String>(
                                      offset: const Offset(0, 40),
                                      icon: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: colorScheme.secondary,
                                        backgroundImage: auth.user?['avatar'] != null && auth.user!['avatar'].toString().isNotEmpty
                                            ? NetworkImage(auth.user!['avatar'])
                                            : null,
                                        child: auth.user?['avatar'] == null || auth.user!['avatar'].toString().isEmpty
                                            ? const Icon(Icons.person, size: 24, color: Colors.white)
                                            : null,
                                      ),
                                      onSelected: (value) async {
                                        if (value == 'profile') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                          );
                                        } else if (value == 'logout') {
                                          await auth.logout();
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'profile',
                                          child: Row(
                                            children: [
                                              Icon(Icons.person, size: 20),
                                              SizedBox(width: 12),
                                              Text('My Profile'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'logout',
                                          child: Row(
                                            children: [
                                              Icon(Icons.logout, size: 20, color: Colors.red),
                                              SizedBox(width: 12),
                                              Text('Logout', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                                        );
                                      },
                                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                                      child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Search best item for you',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                prefixIcon: Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Our Menu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ).animate().fade(delay: 200.ms),
                    ),
                    const SizedBox(height: 16),
                    
                    // Categories
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: menuProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = menuProvider.categories[index];
                          // Simple active state mock (first item active)
                          final isActive = index == 0;
                          return Container(
                            width: 76,
                            margin: const EdgeInsets.only(right: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  // future: filter by category
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isActive ? colorScheme.primary : colorScheme.secondary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        boxShadow: isActive ? [
                                          BoxShadow(
                                            color: colorScheme.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        ] : [],
                                      ),
                                      child: Icon(
                                        _getIconData(category.icon),
                                        color: isActive ? Colors.white : colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                        color: isActive ? colorScheme.primary : Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fade(delay: Duration(milliseconds: 300 + (index * 100))).scale();
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Vouchers (Today's Special Offer)
                    Consumer<VoucherProvider>(
                      builder: (context, voucherProv, child) {
                        if (voucherProv.publicVouchers.isEmpty) return const SizedBox.shrink();
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                'Special Offers',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ).animate().fade(delay: 100.ms),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 130,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: voucherProv.publicVouchers.length,
                                itemBuilder: (context, index) {
                                  final voucher = voucherProv.publicVouchers[index];
                                  return Container(
                                    width: 300,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(20),
                                      image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1497935586351-b67a49e012bf?auto=format&fit=crop&w=600&q=80'),
                                        fit: BoxFit.cover,
                                        opacity: 0.3,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  voucher.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  voucher.type == 'percent' 
                                                      ? '${voucher.value.toInt()}% OFF' 
                                                      : 'Rp ${voucher.value.toInt()} OFF',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (!auth.isAuthenticated) {
                                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                                                      return;
                                                    }
                                                    final result = await voucherProv.claimVoucher(voucher.id);
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      'Claim Now',
                                                      style: TextStyle(
                                                        color: colorScheme.primary,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                    
                    // Menus Grid (Best Seller)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Best Seller',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ).animate().fade(delay: 400.ms),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 40),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisExtent: 240,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: menuProvider.menus.length,
                        itemBuilder: (context, index) {
                          final menu = menuProvider.menus[index];
                          return _buildMenuCard(context, menu, index);
                        },
                      ),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // detail screen if needed
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.secondary.withOpacity(0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: menu.image != null
                        ? Image.network(
                            menu.image!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.coffee, color: colorScheme.primary, size: 40),
                          )
                        : Icon(Icons.coffee, color: colorScheme.primary, size: 40),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      menu.description ?? 'Delicious coffee',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Rp ${menu.price.toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            cart.addToCart(menu);
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('${menu.name} added to cart!')),
                                  ],
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Colors.green.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade(delay: Duration(milliseconds: 500 + (index * 50))).slideY(begin: 0.1, end: 0);
  }
}

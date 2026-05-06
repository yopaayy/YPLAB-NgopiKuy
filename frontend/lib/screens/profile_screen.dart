import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/voucher_provider.dart' as import_voucher;
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _avatarController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      _nameController.text = auth.user!['name'] ?? '';
      _emailController.text = auth.user!['email'] ?? '';
      _phoneController.text = auth.user!['phone_number'] ?? '';
      _addressController.text = auth.user!['address'] ?? '';
      _avatarController.text = auth.user!['avatar'] ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<import_voucher.VoucherProvider>(context, listen: false).fetchMyVouchers();
    });
  }

  void _saveProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    final data = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone_number': _phoneController.text,
      'address': _addressController.text,
      'avatar': _avatarController.text,
    };

    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _passwordConfirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password konfirmasi tidak cocok')),
        );
        return;
      }
      data['password'] = _passwordController.text;
      data['password_confirmation'] = _passwordConfirmController.text;
    }

    final success = await auth.updateProfile(data);
    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      _passwordController.clear();
      _passwordConfirmController.clear();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black87),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top Header with Avatar
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Background Graphic
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.secondary, colorScheme.primary.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      
                      // Back Button
                      Positioned(
                        top: 50,
                        left: 16,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),

                      // Main Form Container
                      Container(
                        margin: const EdgeInsets.only(top: 150),
                        padding: const EdgeInsets.only(top: 80, left: 24, right: 24, bottom: 40),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            _buildTextField('Nama Lengkap', _nameController),
                            const SizedBox(height: 16),
                            
                            _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 16),
                            
                            _buildTextField('Nomor WhatsApp', _phoneController, keyboardType: TextInputType.phone),
                            const SizedBox(height: 16),
                            
                            _buildTextField('Alamat Pengiriman', _addressController, maxLines: 3),
                            const SizedBox(height: 16),
                            
                            _buildTextField('URL Foto Profil (Opsional)', _avatarController),
                            const SizedBox(height: 32),
                            
                            const Divider(),
                            const SizedBox(height: 16),
                            
                            const Text(
                              'Ubah Password',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Kosongkan jika tidak ingin mengubah password.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildTextField('Password Baru', _passwordController, obscureText: true),
                            const SizedBox(height: 16),
                            
                            _buildTextField('Konfirmasi Password Baru', _passwordConfirmController, obscureText: true),
                            const SizedBox(height: 32),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                onPressed: _saveProfile,
                                icon: const Icon(Icons.lock, size: 18),
                                label: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D47A1), // Dark blue like the reference image
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),

                            // VOUCHERS SECTION
                            const SizedBox(height: 48),
                            const Text(
                              'Voucher Saya 🎫',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Consumer<import_voucher.VoucherProvider>(
                              builder: (context, voucherProv, child) {
                                if (voucherProv.isLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (voucherProv.myVouchers.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(child: Text('Anda belum memiliki voucher.')),
                                  );
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: voucherProv.myVouchers.length,
                                  itemBuilder: (context, index) {
                                    final item = voucherProv.myVouchers[index];
                                    final status = item['status'];
                                    final vName = item['voucher']['name'];
                                    final vType = item['voucher']['type'];
                                    final vVal = item['voucher']['value'];
                                    
                                    final isClaimed = status == 'claimed';
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: isClaimed ? colorScheme.secondary.withOpacity(0.1) : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isClaimed ? colorScheme.secondary.withOpacity(0.5) : Colors.grey.shade300,
                                        )
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: CircleAvatar(
                                          backgroundColor: isClaimed ? colorScheme.primary.withOpacity(0.1) : Colors.grey[300],
                                          child: Icon(
                                            Icons.local_offer, 
                                            color: isClaimed ? colorScheme.primary : Colors.grey
                                          ),
                                        ),
                                        title: Text(vName, style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: !isClaimed ? TextDecoration.lineThrough : null,
                                        )),
                                        subtitle: Text(
                                          'Status: ${status.toString().toUpperCase()}',
                                          style: TextStyle(color: isClaimed ? Colors.green : Colors.grey),
                                        ),
                                        trailing: Text(
                                          vType == 'percent' ? '${vVal.toInt()}%' : 'Rp ${vVal.toInt()}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Avatar Overlapping
                      Positioned(
                        top: 100, // 150 (container top) - 50 (half of avatar height)
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: colorScheme.secondary,
                                backgroundImage: _avatarController.text.isNotEmpty
                                    ? NetworkImage(_avatarController.text)
                                    : null,
                                child: _avatarController.text.isEmpty
                                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // Simply focus the avatar URL field
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Silakan edit URL Foto Profil di form bawah')),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47A1), // Match button color
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

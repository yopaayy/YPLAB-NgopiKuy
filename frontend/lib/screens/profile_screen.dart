import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/voucher_provider.dart' as import_voucher;
import 'login_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: colorScheme.secondary,
                    backgroundImage: _avatarController.text.isNotEmpty
                        ? NetworkImage(_avatarController.text)
                        : null,
                    child: _avatarController.text.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Nomor WhatsApp', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Alamat Pengiriman Default', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _avatarController,
                    decoration: const InputDecoration(labelText: 'URL Foto Profil (Opsional)', border: OutlineInputBorder()),
                    onChanged: (val) => setState(() {}),
                  ),
                  const SizedBox(height: 32),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Ubah Password (kosongkan jika tidak ingin diubah)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password Baru', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordConfirmController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Konfirmasi Password Baru', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan Perubahan'),
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Voucher Saya 🎫', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  
                  Consumer<import_voucher.VoucherProvider>(
                    builder: (context, voucherProv, child) {
                      if (voucherProv.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (voucherProv.myVouchers.isEmpty) {
                        return const Text('Anda belum memiliki voucher.');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: voucherProv.myVouchers.length,
                        itemBuilder: (context, index) {
                          final item = voucherProv.myVouchers[index];
                          final status = item['status'];
                          final vName = item['voucher']['name'];
                          final vType = item['voucher']['type'];
                          final vVal = item['voucher']['value'];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: status == 'claimed' ? colorScheme.secondary.withOpacity(0.2) : Colors.grey[200],
                            child: ListTile(
                              leading: Icon(
                                Icons.local_offer, 
                                color: status == 'claimed' ? colorScheme.primary : Colors.grey
                              ),
                              title: Text(vName, style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: status != 'claimed' ? TextDecoration.lineThrough : null,
                              )),
                              subtitle: Text('Status: ${status.toString().toUpperCase()}'),
                              trailing: Text(
                                vType == 'percent' ? '${vVal.toInt()}%' : 'Rp ${vVal.toInt()}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}

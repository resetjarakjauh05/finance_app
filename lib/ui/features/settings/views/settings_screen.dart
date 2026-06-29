import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../../core/dialogs.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;
  final String? displayName;
  final String? email;

  const SettingsScreen({
    super.key,
    required this.userId,
    this.displayName,
    this.email,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AuthViewModel _authViewModel;
  late String _currentDisplayName;

  @override
  void initState() {
    super.initState();
    _currentDisplayName = widget.displayName ?? '';
    _authViewModel = AuthViewModel(
      authRepository: AuthRepository(authService: AuthService()),
    );
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  Future<void> _handleEditName() async {
    final controller = TextEditingController(text: _currentDisplayName);
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ubah Nama'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Simpan')),
          ],
        ),
      );
      if (confirmed == true && controller.text.trim().isNotEmpty && mounted) {
        try {
          await _authViewModel.authRepository.updateDisplayName(controller.text.trim());
          setState(() => _currentDisplayName = controller.text.trim());
          if (mounted) {
            await showSuccessDialog(context,
                title: 'Nama Diperbarui',
                message: 'Nama berhasil diubah.',
                icon: Icons.check_circle);
          }
        } catch (e) {
          if (mounted) {
            final msg = e.toString().replaceFirst('Exception: ', '');
            await showErrorDialog(context, message: msg.isNotEmpty ? msg : 'Gagal memperbarui nama.');
          }
        }
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _handleChangePassword() async {
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('Ganti Password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setStateDialog(() => obscureNew = !obscureNew),
                      ),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setStateDialog(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Batal')),
              FilledButton(onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Simpan')),
            ],
          ),
        ),
      );

      if (confirmed == true && mounted) {
        final newPass = newPasswordController.text;
        final confirmPass = confirmController.text;

        if (newPass.isEmpty) {
          await showErrorDialog(context, message: 'Password baru tidak boleh kosong.');
        } else if (newPass.length < 6) {
          await showErrorDialog(context, message: 'Password minimal 6 karakter.');
        } else if (newPass != confirmPass) {
          await showErrorDialog(context, message: 'Konfirmasi password tidak cocok.');
        } else {
          try {
            await _authViewModel.authRepository.updatePassword(newPass);
            if (mounted) {
              await showSuccessDialog(context,
                  title: 'Password Diperbarui',
                  message: 'Password berhasil diubah.',
                  icon: Icons.check_circle);
            }
          } catch (e) {
            if (mounted) {
              final msg = e.toString().replaceFirst('Exception: ', '');
              // Jika Firebase minta re-auth, minta user login ulang
              if (msg.contains('login ulang') || msg.contains('recent-login') || msg.contains('requires-recent-login')) {
                await showErrorDialog(
                  context,
                  title: 'Sesi Kedaluwarsa',
                  message: 'Sesi Anda sudah terlalu lama. Silakan keluar lalu masuk kembali, kemudian coba ganti password lagi.',
                );
              } else {
                await showErrorDialog(context, message: msg.isNotEmpty ? msg : 'Gagal mengganti password.');
              }
            }
          }
        }
      }
    } finally {
      newPasswordController.dispose();
      confirmController.dispose();
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // AuthGate StreamBuilder otomatis redirect ke LoginScreen saat signOut
      // Tidak perlu popUntil atau showSuccessDialog — akan menyebabkan orphan dialog
      await _authViewModel.signOut();
    }
  }

  Widget _creditRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          // Profile section
          UserAccountsDrawerHeader(
            accountName: Text(
              _currentDisplayName.isNotEmpty ? _currentDisplayName : 'User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(widget.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                (_currentDisplayName.isNotEmpty ? _currentDisplayName : widget.email ?? 'U')
                    .substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer),
          ),

          // Profil section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('PROFIL', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text('Ubah Nama'),
            subtitle: Text(_currentDisplayName.isNotEmpty ? _currentDisplayName : '-'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _handleEditName,
          ),
          ListTile(
            leading: const Icon(Icons.lock_outlined),
            title: const Text('Ganti Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _handleChangePassword,
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(widget.email ?? '-'),
          ),

          const Divider(),

          // App section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('APLIKASI', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Aplikasi Keuangan v1.0.0'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Aplikasi Keuangan',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
              children: const [
                Text('Aplikasi tracking keuangan personal dengan Firebase & SQLite.'),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.favorite_outline, color: Colors.pink),
            title: const Text('Credit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.code, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Credit'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Aplikasi ini dibuat dengan:'),
                    const SizedBox(height: 12),
                    _creditRow(Icons.person, 'Developer', 'resetjarakjauhDev'),
                    const SizedBox(height: 8),
                    _creditRow(Icons.smart_toy, 'AI Model', 'Claude Sonnet'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Dukung pengembang:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(
                            text: 'https://saweria.co/Atoilahputra'));
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link Saweria disalin ke clipboard'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'saweria.co/Atoilahputra',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(Icons.copy, size: 16, color: Colors.orange.shade700),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('AKUN', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}

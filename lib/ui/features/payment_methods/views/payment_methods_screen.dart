import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../view_models/payment_method_view_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../core/dialogs.dart';
import 'add_edit_payment_method_screen.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final String userId;

  const PaymentMethodsScreen({super.key, required this.userId});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late final PaymentMethodViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PaymentMethodViewModel(
      repository: PaymentMethodRepository(
        service: PaymentMethodService(),
      ),
      userId: widget.userId,
    );
    // Tunggu stream emit data pertama, baru cek inisialisasi default
    _viewModel.addListener(_onFirstLoad);
  }

  bool _firstLoadDone = false;

  // Filter: 0=Semua, 1=Aktif, 2=Non-aktif
  int _filterIndex = 0;

  void _onFirstLoad() {
    if (_firstLoadDone) return;
    if (_viewModel.isLoading) return;
    _firstLoadDone = true;
    _viewModel.removeListener(_onFirstLoad);
    _checkInitDefaults();
  }

  Future<void> _checkInitDefaults() async {
    if (_viewModel.paymentMethods.isEmpty && mounted) {
      final shouldInit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Inisialisasi Metode Pembayaran'),
          content: const Text(
            'Anda belum memiliki metode pembayaran. Inisialisasi dengan metode default?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya, Inisialisasi'),
            ),
          ],
        ),
      );

      if (shouldInit == true) {
        await _viewModel.initializeDefaults();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Metode pembayaran default berhasil ditambahkan'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _loadData() async {
    // Manual refresh via RefreshIndicator
    await _viewModel.loadPaymentMethods();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _navigateToAddEdit({PaymentMethodModel? method}) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => AddEditPaymentMethodScreen(
          userId: widget.userId,
          method: method,
        ),
      ),
    );

    // Selalu reload setelah kembali dari AddEdit — terlepas sukses/gagal/batal
    // Fix: jika exception di AddEdit screen, result == null tapi data mungkin sudah berubah
    if (mounted) {
      await _viewModel.loadPaymentMethods();
    }

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete(PaymentMethodModel method) async {
    final isUsed = await _viewModel.isUsedInTransactions(method.id);

    if (!mounted) return;

    if (isUsed) {
      // Sudah dipakai → hanya soft delete (nonaktifkan)
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nonaktifkan Metode Pembayaran'),
          content: Text(
            '"${method.name}" sudah digunakan dalam transaksi sehingga tidak bisa dihapus permanen. '
            'Metode ini akan dinonaktifkan dan tidak muncul di pilihan transaksi baru.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Nonaktifkan'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await _viewModel.deletePaymentMethod(method.id);
          if (mounted) {
            await showSuccessDialog(
              context,
              title: 'Berhasil Dinonaktifkan',
              message: '"${method.name}" berhasil dinonaktifkan.',
              icon: Icons.do_not_disturb_on,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _viewModel.errorMessage ??
                      'Gagal menonaktifkan metode pembayaran',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } else {
      // Belum dipakai → tawarkan permanent delete
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hapus Metode Pembayaran'),
          content: Text(
            '"${method.name}" belum pernah digunakan dalam transaksi. '
            'Pilih tindakan yang ingin dilakukan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Batal'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop('soft'),
              child: const Text('Nonaktifkan'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop('permanent'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus Permanen'),
            ),
          ],
        ),
      );

      if (action == null || !mounted) return;

        try {
          if (action == 'permanent') {
            await _viewModel.permanentDeletePaymentMethod(method.id);
            if (mounted) {
              await showSuccessDialog(
                context,
                title: 'Berhasil Dihapus',
                message: '"${method.name}" berhasil dihapus permanen.',
                icon: Icons.delete_forever,
              );
            }
          } else {
            await _viewModel.deletePaymentMethod(method.id);
            if (mounted) {
              await showSuccessDialog(
                context,
                title: 'Berhasil Dinonaktifkan',
                message: '"${method.name}" berhasil dinonaktifkan.',
                icon: Icons.do_not_disturb_on,
              );
            }
          }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _viewModel.errorMessage ??
                    'Gagal menghapus metode pembayaran',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.paymentMethods.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_viewModel.paymentMethods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada metode pembayaran',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambah metode pembayaran pertama Anda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Semua'),
                      selected: _filterIndex == 0,
                      onSelected: (_) => setState(() => _filterIndex = 0),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                    ),
                    FilterChip(
                      label: const Text('Aktif'),
                      selected: _filterIndex == 1,
                      onSelected: (_) => setState(() => _filterIndex = 1),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                    ),
                    FilterChip(
                      label: const Text('Non-aktif'),
                      selected: _filterIndex == 2,
                      onSelected: (_) => setState(() => _filterIndex = 2),
                      showCheckmark: false,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: Builder(builder: (context) {
                    final filtered = switch (_filterIndex) {
                      1 => _viewModel.paymentMethods.where((m) => m.isActive).toList(),
                      2 => _viewModel.paymentMethods.where((m) => !m.isActive).toList(),
                      _ => _viewModel.paymentMethods,
                    };
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          _filterIndex == 1
                              ? 'Tidak ada rekening aktif'
                              : _filterIndex == 2
                                  ? 'Tidak ada rekening non-aktif'
                                  : 'Belum ada metode pembayaran',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final method = filtered[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        method.type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      method.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: method.isActive ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(method.type.displayName),
                        if (method.bankName != null)
                          Text(method.bankName!, style: const TextStyle(fontSize: 12)),
                        if (method.accountNumber != null && method.accountNumber!.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: method.accountNumber!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nomor ${method.accountNumber} disalin'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(method.accountNumber!,
                                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy, size: 12, color: Colors.grey),
                              ],
                            ),
                          ),
                        if (!method.isActive)
                          const Text('Tidak Aktif',
                              style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToAddEdit(method: method);
                        } else if (value == 'delete') {
                          _handleDelete(method);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

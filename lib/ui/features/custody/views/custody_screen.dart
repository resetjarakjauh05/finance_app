import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/custody_service.dart';
import '../../../../data/repositories/custody_repository.dart';
import '../../../../domain/models/custody_model.dart';
import '../../../core/dialogs.dart';
import '../view_models/custody_view_model.dart';
import 'add_edit_custody_screen.dart';
import 'custody_detail_screen.dart';

class CustodyScreen extends StatefulWidget {
  final String userId;
  const CustodyScreen({super.key, required this.userId});

  @override
  State<CustodyScreen> createState() => _CustodyScreenState();
}

class _CustodyScreenState extends State<CustodyScreen> {
  late final CustodyViewModel _viewModel;

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _viewModel = CustodyViewModel(
      repository: CustodyRepository(service: CustodyService()),
      userId: widget.userId,
    );
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _navigateToAddEdit({CustodyModel? custody}) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) =>
            AddEditCustodyScreen(userId: widget.userId, custody: custody),
      ),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.green,
            duration: const Duration(seconds: 2)),
      );
      _viewModel.init();
    }
  }

  void _navigateToDetail(CustodyModel custody) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustodyDetailScreen(
          userId: widget.userId,
          custody: custody,
        ),
      ),
    ).then((_) => _viewModel.init());
  }

  Future<void> _handleDelete(CustodyModel custody) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Titipan'),
        content: Text('Yakin hapus titipan "${custody.depositorName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _viewModel.deleteCustody(custody);
        if (mounted) {
          await showSuccessDialog(context,
              title: 'Berhasil Dihapus',
              message: '"${custody.depositorName}" berhasil dihapus.',
              icon: Icons.delete_outline);
        }
      } catch (e) {
        if (mounted) await showErrorDialog(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Titipan')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.custodies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_viewModel.custodies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swap_horiz, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Belum ada titipan',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _viewModel.init(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _viewModel.custodies.length,
              itemBuilder: (context, index) {
                final c = _viewModel.custodies[index];
                final isDiterima = c.type == CustodyType.diterima;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => _navigateToDetail(c),
                    onLongPress: () => _handleDelete(c),
                    leading: CircleAvatar(
                      backgroundColor: isDiterima
                          ? Colors.blue.shade50
                          : Colors.orange.shade50,
                      child: Icon(
                        isDiterima ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isDiterima ? Colors.blue : Colors.orange,
                      ),
                    ),
                    title: Text(c.depositorName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.type.displayName,
                            style: TextStyle(
                              color: isDiterima ? Colors.blue : Colors.orange,
                              fontSize: 12,
                            )),
                        if (c.description != null)
                          Text(c.description!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _currencyFormat.format(c.currentBalance),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: c.currentBalance >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        Text('Saldo',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'custody_fab',
        onPressed: () => _navigateToAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

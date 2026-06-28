import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/spending_limit_model.dart';
import '../../../../data/repositories/spending_limit_repository.dart';
import '../../../../data/services/spending_limit_service.dart';
import '../../../../data/local/spending_limit_dao.dart';
import '../../../../data/local/transaction_dao.dart';
import '../../../../data/local/database_helper.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/services/category_service.dart';
import '../../../../data/local/category_dao.dart';
import '../view_models/spending_limit_view_model.dart';
import 'spending_limit_form_screen.dart';

class SpendingLimitScreen extends StatefulWidget {
  final String userId;
  const SpendingLimitScreen({super.key, required this.userId});

  @override
  State<SpendingLimitScreen> createState() => _SpendingLimitScreenState();
}

class _SpendingLimitScreenState extends State<SpendingLimitScreen> {
  late final SpendingLimitViewModel _vm;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _vm = SpendingLimitViewModel(
      repository: SpendingLimitRepository(
        service: SpendingLimitService(
          dao: SpendingLimitDao(),
          txDao: TransactionDao(dbHelper: DatabaseHelper()),
        ),
      ),
    );
    _vm.loadLimits(widget.userId);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limit Pengeluaran Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_vm.status == SpendingLimitLoadStatus.error) {
            return _ErrorView(
              message: _vm.errorMessage ?? 'Terjadi kesalahan',
              onRetry: () => _vm.loadLimits(widget.userId),
            );
          }
          if (_vm.limits.isEmpty) {
            return _EmptyView(onAdd: () => _openForm(context));
          }
          return RefreshIndicator(
            onRefresh: () => _vm.loadLimits(widget.userId),
              child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _InfoBanner(),
                const SizedBox(height: 16),
                ..._vm.limits.map((limit) => _LimitCard(
                      limit: limit,
                      spent: _vm.spentForLimit(limit),
                      remaining: _vm.remainingForLimit(limit),
                      progress: _vm.progressForLimit(limit),
                      status: _vm.statusForLimit(limit),
                      currency: _currency,
                      onEdit: () => _openForm(context, existing: limit),
                      onDelete: () => _confirmDelete(context, limit),
                    )),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Limit'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context,
      {SpendingLimitModel? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SpendingLimitFormScreen(
          userId: widget.userId,
          existing: existing,
          viewModel: _vm,
          categoryRepository: CategoryRepository(
            service: CategoryService(dao: CategoryDao()),
          ),
        ),
      ),
    );
    if (result == true) await _vm.loadLimits(widget.userId);
  }

  Future<void> _confirmDelete(
      BuildContext context, SpendingLimitModel limit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Limit'),
        content: Text('Hapus limit "${limit.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final ok = await _vm.deleteLimit(limit);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_vm.errorMessage ?? 'Gagal menghapus'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Notifikasi muncul saat mendekati limit (80%). Transaksi tetap bisa dilakukan meski melewati limit.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Belum ada limit pengeluaran',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Atur limit harian agar pengeluaran terkontrol',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Limit'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(message),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  final SpendingLimitModel limit;
  final int spent;
  final int remaining;
  final double progress;
  final SpendingLimitStatus status;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LimitCard({
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.status,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(status.color);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    limit.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clampedProgress,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 8),

            // Angka
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terpakai: ${currency.format(spent)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Limit: ${currency.format(limit.dailyLimit)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              status == SpendingLimitStatus.exceeded
                  ? 'Melewati limit ${currency.format(spent - limit.dailyLimit)}'
                  : 'Sisa hari ini: ${currency.format(remaining)}',
              style: TextStyle(
                  fontSize: 13,
                  color: statusColor,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

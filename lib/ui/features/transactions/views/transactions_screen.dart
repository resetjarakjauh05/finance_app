import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../view_models/transaction_view_model.dart';
import '../../../../domain/models/transaction_model.dart';
import '../../../core/dialogs.dart';
import '../../../core/widgets.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_filter_modal.dart';
import '../../../../main.dart' show syncEngine;
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final String userId;
  const TransactionsScreen({super.key, required this.userId});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final TransactionViewModel _viewModel;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _activeQuickFilter = 'Semua';

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _viewModel = TransactionViewModel(
      transactionRepository: TransactionRepository(service: TransactionService()),
      paymentMethodRepository: PaymentMethodRepository(service: PaymentMethodService()),
      userId: widget.userId,
    );
    _viewModel.init();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _viewModel.loadTransactions();
    await _viewModel.checkOnlineStatus();
    await _viewModel.loadUnsyncedCount();
  }

  Future<void> _handleDelete(TransactionModel transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus transaksi "${transaction.description}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
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
        await _viewModel.deleteTransaction(transaction);
        if (mounted) {
          await showSuccessDialog(context,
              title: 'Transaksi Dihapus',
              message: 'Transaksi "${transaction.description}" berhasil dihapus.',
              icon: Icons.delete_outline);
        }
      } catch (e) {
        if (mounted) await showErrorDialog(context, message: e.toString());
      }
    }
  }

  void _navigateToAddEdit({TransactionModel? transaction}) async {
    // BUG FIX: push<bool> bukan <String> — AddEditTransactionScreen pop(true)
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(
          userId: widget.userId,
          transaction: transaction,
        ),
      ),
    );
    if (result == true && mounted) {
      _handleRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(transaction == null
              ? 'Transaksi berhasil disimpan'
              : 'Transaksi berhasil diperbarui'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFilterModal() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TransactionFilterModal(
        initialCategory: _viewModel.filterCategory,
        initialPaymentMethodId: _viewModel.filterPaymentMethodId,
        initialStartDate: _viewModel.filterStartDate,
        initialEndDate: _viewModel.filterEndDate,
        paymentMethods: _viewModel.paymentMethods,
      ),
    );
    if (result != null && mounted) {
      setState(() => _activeQuickFilter = '');
      await _viewModel.applyFilters(
        category: result['category'],
        paymentMethodId: result['paymentMethodId'],
        startDate: result['startDate'],
        endDate: result['endDate'],
      );
    }
  }

  Widget _quickFilterChip(
    String label,
    DateTime? startDate,
    DateTime? endDate, {
    TransactionCategory? category,
  }) {
    final isActive = _activeQuickFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      showCheckmark: true,
      onSelected: (_) async {
        setState(() => _activeQuickFilter = label);
        if (label == 'Semua') {
          await _viewModel.clearFilters();
        } else {
          await _viewModel.applyFilters(
            category: category,
            startDate: startDate,
            endDate: endDate,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          // Sync status
          ListenableBuilder(
            listenable: syncEngine,
            builder: (context, _) {
              if (syncEngine.isSyncing) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (syncEngine.pendingCount > 0) {
                return Badge(
                  label: Text('${syncEngine.pendingCount}'),
                  child: IconButton(
                    icon: const Icon(Icons.sync),
                    tooltip: 'Sync ${syncEngine.pendingCount} pending',
                    onPressed: () => syncEngine.manualSync(),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Filter button
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              final hasFilter = _viewModel.filterCategory != null ||
                  _viewModel.filterPaymentMethodId != null ||
                  _viewModel.filterStartDate != null ||
                  _viewModel.filterEndDate != null;
              return IconButton(
                icon: Icon(
                  hasFilter ? Icons.filter_list : Icons.filter_list_outlined,
                  color: hasFilter ? Theme.of(context).colorScheme.primary : null,
                ),
                onPressed: _showFilterModal,
                tooltip: hasFilter ? 'Filter aktif' : 'Filter',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Online/Offline indicator
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              if (!_viewModel.isOnline || _viewModel.unsyncedCount > 0) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: _viewModel.isOnline ? Colors.orange.shade100 : Colors.red.shade100,
                  child: Row(
                    children: [
                      Icon(
                        _viewModel.isOnline ? Icons.sync : Icons.wifi_off,
                        size: 16,
                        color: _viewModel.isOnline ? Colors.orange.shade900 : Colors.red.shade900,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _viewModel.isOnline
                              ? 'Ada ${_viewModel.unsyncedCount} transaksi belum tersinkron'
                              : 'Mode Offline — Perubahan akan disinkronkan saat online',
                          style: TextStyle(
                            fontSize: 12,
                            color: _viewModel.isOnline ? Colors.orange.shade900 : Colors.red.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _viewModel.search('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 400), () {
                  _viewModel.search(value);
                });
              },
            ),
          ),

          // Quick filter chips
          ListenableBuilder(
            listenable: _viewModel,
            builder: (context, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _quickFilterChip('Semua', null, null),
                    const SizedBox(width: 8),
                    _quickFilterChip('Hari Ini',
                        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59)),
                    const SizedBox(width: 8),
                    _quickFilterChip('Minggu Ini',
                        DateTime.now().subtract(const Duration(days: 7)),
                        DateTime.now()),
                    const SizedBox(width: 8),
                    _quickFilterChip('Bulan Ini',
                        DateTime(DateTime.now().year, DateTime.now().month, 1),
                        DateTime(DateTime.now().year, DateTime.now().month + 1, 0)),
                    const SizedBox(width: 8),
                    _quickFilterChip('Pemasukan', null, null,
                        category: TransactionCategory.income),
                    const SizedBox(width: 8),
                    _quickFilterChip('Pengeluaran', null, null,
                        category: TransactionCategory.expense),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Transaction list
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading && _viewModel.transactions.isEmpty) {
                  return const LoadingListWidget();
                }

                if (_viewModel.transactions.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada transaksi',
                    subtitle: 'Tambahkan transaksi pertama Anda',
                    actionLabel: 'Tambah Transaksi',
                    onAction: () => _navigateToAddEdit(),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    itemCount: _viewModel.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _viewModel.transactions[index];
                      final isIncome = transaction.category == TransactionCategory.income;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                            child: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(transaction.description,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transaction.paymentMethodName,
                                  style: const TextStyle(fontSize: 12)),
                              Text(DateFormat('dd MMM yyyy', 'id_ID').format(transaction.date),
                                  style: const TextStyle(fontSize: 11)),
                              if (!transaction.isSynced)
                                Row(children: [
                                  const Icon(Icons.sync_disabled, size: 12, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text('Belum tersinkron',
                                      style: TextStyle(fontSize: 11, color: Colors.orange)),
                                ]),
                            ],
                          ),
                          trailing: Text(
                            _currencyFormat.format(transaction.nominal),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          onTap: () => _navigateToAddEdit(transaction: transaction),
                          onLongPress: () => _handleDelete(transaction),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

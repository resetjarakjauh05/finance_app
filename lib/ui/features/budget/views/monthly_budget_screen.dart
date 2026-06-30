import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/monthly_budget_model.dart';
import '../../../../domain/models/category_model.dart';
import '../../../../data/repositories/monthly_budget_repository.dart';
import '../../../../data/services/monthly_budget_service.dart';
import '../../../../data/local/monthly_budget_dao.dart';
import '../../../../data/local/transaction_dao.dart';
import '../../../../data/local/database_helper.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/services/category_service.dart';
import '../../../../data/local/category_dao.dart';
import '../view_models/monthly_budget_view_model.dart';
import '../../../core/currency_input_formatter.dart';

class MonthlyBudgetScreen extends StatefulWidget {
  final String userId;
  const MonthlyBudgetScreen({super.key, required this.userId});

  @override
  State<MonthlyBudgetScreen> createState() => _MonthlyBudgetScreenState();
}

class _MonthlyBudgetScreenState extends State<MonthlyBudgetScreen> {
  late final MonthlyBudgetViewModel _vm;
  late final CategoryRepository _categoryRepo;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _vm = MonthlyBudgetViewModel(
      repository: MonthlyBudgetRepository(
        service: MonthlyBudgetService(
          dao: MonthlyBudgetDao(),
          txDao: TransactionDao(dbHelper: DatabaseHelper()),
        ),
      ),
    );
    _categoryRepo = CategoryRepository(
      service: CategoryService(dao: CategoryDao()),
    );
    _vm.loadBudgets(widget.userId);
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
        title: const Text('Anggaran Bulanan'),
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
          if (_vm.status == MonthlyBudgetStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_vm.errorMessage ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _vm.loadBudgets(widget.userId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _vm.loadBudgets(widget.userId),
            child: CustomScrollView(
              slivers: [
                // Month selector
                SliverToBoxAdapter(
                  child: _MonthSelector(
                    selectedMonth: _vm.selectedMonth,
                    availableMonths: _vm.availableMonths,
                    onMonthChanged: (m) => _vm.selectMonth(widget.userId, m),
                  ),
                ),

                // Summary card
                if (_vm.items.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _SummaryCard(
                      totalBudget: _vm.totalBudget,
                      totalActual: _vm.totalActual,
                      totalRemaining: _vm.totalRemaining,
                      currency: _currency,
                    ),
                  ),

                // Empty state
                if (_vm.items.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pie_chart_outline,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Belum ada anggaran bulan ini',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(
                            'Buat rencana pengeluaran untuk ${_vm.selectedMonth}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => _openForm(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Anggaran'),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Budget list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = _vm.items[i];
                        return _BudgetCard(
                          item: item,
                          currency: _currency,
                          onEdit: () => _openForm(context, existing: item.budget),
                          onDelete: () => _confirmDelete(context, item.budget),
                        );
                      },
                      childCount: _vm.items.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Anggaran'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context,
      {MonthlyBudgetModel? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MonthlyBudgetFormScreen(
          userId: widget.userId,
          yearMonth: _vm.selectedMonth,
          viewModel: _vm,
          categoryRepository: _categoryRepo,
          existing: existing,
        ),
      ),
    );
    if (result == true) await _vm.loadBudgets(widget.userId);
  }

  Future<void> _confirmDelete(
      BuildContext context, MonthlyBudgetModel budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggaran'),
        content: Text(
            'Hapus anggaran "${budget.categoryIcon} ${budget.categoryName}"?'),
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
      final ok = await _vm.deleteBudget(budget, widget.userId);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_vm.errorMessage ?? 'Gagal menghapus'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}

// ─── Month Selector ──────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  final String selectedMonth;
  final List<String> availableMonths;
  final ValueChanged<String> onMonthChanged;

  const _MonthSelector({
    required this.selectedMonth,
    required this.availableMonths,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: DropdownButtonFormField<String>(
        initialValue: availableMonths.contains(selectedMonth) ? selectedMonth : null,
        decoration: const InputDecoration(
          labelText: 'Pilih Bulan',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_month),
          isDense: true,
        ),
        items: availableMonths.map((m) {
          final parts = m.split('-');
          final months = [
            '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
          ];
          final label = parts.length == 2
              ? '${months[int.tryParse(parts[1]) ?? 0]} ${parts[0]}'
              : m;
          return DropdownMenuItem(value: m, child: Text(label));
        }).toList(),
        onChanged: (v) {
          if (v != null) onMonthChanged(v);
        },
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int totalBudget;
  final int totalActual;
  final int totalRemaining;
  final NumberFormat currency;

  const _SummaryCard({
    required this.totalBudget,
    required this.totalActual,
    required this.totalRemaining,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        totalBudget > 0 ? (totalActual / totalBudget).clamp(0.0, 1.0) : 0.0;
    final exceeded = totalActual > totalBudget;
    final progressColor = exceeded ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Bulan Ini',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                    label: 'Total Anggaran',
                    value: currency.format(totalBudget),
                    color: Colors.blue),
                _StatItem(
                    label: 'Terpakai',
                    value: currency.format(totalActual),
                    color: progressColor),
                _StatItem(
                    label: exceeded ? 'Lebih' : 'Sisa',
                    value: currency
                        .format((totalBudget - totalActual).abs()),
                    color: exceeded ? Colors.red : Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// ─── Budget Card ──────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final BudgetItem item;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.item,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(item.status.color);
    final progress = item.progress.clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item.budget.categoryIcon,
                    style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.budget.categoryName,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status.label,
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
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${currency.format(item.actualSpending)} terpakai',
                    style: const TextStyle(fontSize: 12)),
                Text('Anggaran: ${currency.format(item.budget.budgetAmount)}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Form Screen ─────────────────────────────────────────────────────────────

class MonthlyBudgetFormScreen extends StatefulWidget {
  final String userId;
  final String yearMonth;
  final MonthlyBudgetViewModel viewModel;
  final CategoryRepository categoryRepository;
  final MonthlyBudgetModel? existing;

  const MonthlyBudgetFormScreen({
    super.key,
    required this.userId,
    required this.yearMonth,
    required this.viewModel,
    required this.categoryRepository,
    this.existing,
  });

  @override
  State<MonthlyBudgetFormScreen> createState() =>
      _MonthlyBudgetFormScreenState();
}

class _MonthlyBudgetFormScreenState extends State<MonthlyBudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  CategoryModel? _selectedCategory;
  bool _isSaving = false;
  List<CategoryModel> _categories = [];
  bool _loadingCategories = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _amountController.text = ThousandsSeparatorInputFormatter.formatWithDots(widget.existing!.budgetAmount.toString());
      _notesController.text = widget.existing!.notes ?? '';
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats =
          await widget.categoryRepository.getCategories(widget.userId);
      setState(() {
        _categories = cats;
        _loadingCategories = false;
        if (_isEdit) {
          _selectedCategory = cats
              .where((c) => c.id == widget.existing!.categoryId)
              .firstOrNull;
        }
      });
    } catch (e) {
      setState(() => _loadingCategories = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Anggaran' : 'Tambah Anggaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Kategori
            Text('Kategori', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _loadingCategories
                ? const Center(child: CircularProgressIndicator())
                : _buildCategorySelector(),
            const SizedBox(height: 20),

            // Nominal anggaran
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Target Anggaran (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal tidak boleh kosong';
                final val = ThousandsSeparatorInputFormatter.parseValue(v);
                if (val <= 0) return 'Nominal harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Catatan
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Anggaran'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_categories.isEmpty) {
      return const Text('Belum ada kategori',
          style: TextStyle(color: Colors.grey));
    }
    return DropdownButtonFormField<CategoryModel>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Pilih Kategori',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: _categories
          .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text('${cat.icon} ${cat.name}'),
              ))
          .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
      validator: (v) => v == null ? 'Kategori harus dipilih' : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final amount = ThousandsSeparatorInputFormatter.parseValue(_amountController.text);
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    bool ok;
    if (_isEdit) {
      ok = await widget.viewModel.updateBudget(
        widget.existing!.copyWith(
          categoryId: _selectedCategory!.id,
          categoryName: _selectedCategory!.name,
          categoryIcon: _selectedCategory!.icon,
          budgetAmount: amount,
          notes: notes,
          updatedAt: DateTime.now(),
        ),
        widget.userId,
      );
    } else {
      ok = await widget.viewModel.createBudget(
        userId: widget.userId,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        categoryIcon: _selectedCategory!.icon,
        budgetAmount: amount,
        notes: notes,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(widget.viewModel.errorMessage ?? 'Gagal menyimpan'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

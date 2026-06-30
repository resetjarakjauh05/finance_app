import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/savings_plan_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../../../data/repositories/savings_plan_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../data/services/savings_plan_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/local/savings_plan_dao.dart';
import '../view_models/savings_plan_view_model.dart';
import '../../../core/currency_input_formatter.dart';
import 'savings_history_screen.dart';

class SavingsPlanScreen extends StatefulWidget {
  final String userId;
  const SavingsPlanScreen({super.key, required this.userId});

  @override
  State<SavingsPlanScreen> createState() => _SavingsPlanScreenState();
}

class _SavingsPlanScreenState extends State<SavingsPlanScreen> {
  late final SavingsPlanViewModel _vm;
  final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _vm = SavingsPlanViewModel(
      repository: SavingsPlanRepository(
        service: SavingsPlanService(
          dao: SavingsPlanDao(),
          allocDao: SavingsAllocationDao(),
        ),
      ),
    );
    _vm.loadPlans(widget.userId);
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
        title: const Text('Rencana Tabungan'),
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
          if (_vm.status == SavingsPlanStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_vm.errorMessage ?? 'Terjadi kesalahan'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _vm.loadPlans(widget.userId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (_vm.plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Belum ada rencana tabungan',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Mulai rencanakan tabunganmu sekarang',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Buat Rencana'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _vm.loadPlans(widget.userId),
            child: CustomScrollView(
              slivers: [
                // Summary
                SliverToBoxAdapter(
                  child: _SummaryCard(
                    totalSaved: _vm.totalSaved,
                    totalTarget: _vm.totalTarget,
                    currency: _currency,
                  ),
                ),

                // Plans list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final plan = _vm.plans[i];
                        return _PlanCard(
                          plan: plan,
                          allocations: _vm.allocationsFor(plan.id),
                          currency: _currency,
                          onEdit: () => _openForm(context, existing: plan),
                          onDelete: () => _confirmDelete(context, plan),
                          onAddAllocation: () =>
                              _openAllocationForm(context, plan),
                          onViewHistory: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SavingsHistoryScreen(
                                userId: widget.userId,
                                plan: plan,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _vm.plans.length,
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
        label: const Text('Buat Rencana'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context,
      {SavingsPlanModel? existing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SavingsPlanFormScreen(
          userId: widget.userId,
          viewModel: _vm,
          existing: existing,
        ),
      ),
    );
    if (result == true) await _vm.loadPlans(widget.userId);
  }

  Future<void> _openAllocationForm(
      BuildContext context, SavingsPlanModel plan) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SavingsAllocationFormScreen(
          userId: widget.userId,
          plan: plan,
          viewModel: _vm,
        ),
      ),
    );
    if (result == true) await _vm.loadPlans(widget.userId);
  }

  Future<void> _confirmDelete(
      BuildContext context, SavingsPlanModel plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rencana Tabungan'),
        content: Text('Hapus rencana "${plan.name}"? Semua riwayat alokasi juga akan dihapus.'),
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
      final ok = await _vm.deletePlan(plan, widget.userId);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_vm.errorMessage ?? 'Gagal menghapus'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int totalSaved;
  final int totalTarget;
  final NumberFormat currency;

  const _SummaryCard({
    required this.totalSaved,
    required this.totalTarget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTarget > 0
        ? (totalSaved / totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Tabungan',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Terkumpul',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(currency.format(totalSaved),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Target',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(currency.format(totalTarget),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final SavingsPlanModel plan;
  final List<SavingsAllocationModel> allocations;
  final NumberFormat currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddAllocation;
  final VoidCallback onViewHistory;

  const _PlanCard({
    required this.plan,
    required this.allocations,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
    required this.onAddAllocation,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(plan.statusColor);
    final progress = plan.progress;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(plan.icon ?? '🐷',
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name,
                              style: Theme.of(context).textTheme.titleSmall),
                          if (plan.description != null)
                            Text(plan.description!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        plan.statusLabel,
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
                        if (v == 'history') onViewHistory();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'history',
                            child: Row(children: [
                              Icon(Icons.history, size: 18),
                              SizedBox(width: 8),
                              Text('Lihat Histori'),
                            ])),
                        const PopupMenuItem(
                            value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Text('Hapus',
                                style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                const SizedBox(height: 6),

                // Angka
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currency.format(plan.savedAmount)} terkumpul',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Target: ${currency.format(plan.targetAmount)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                if (plan.monthlyTarget > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Target/bulan: ${currency.format(plan.monthlyTarget)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
                if (plan.targetDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Deadline: ${DateFormat('d MMMM yyyy', 'id_ID').format(plan.targetDate!)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onAddAllocation,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah Tabungan'),
                  ),
                ),
                if (allocations.isNotEmpty)
                  Text(
                    '${allocations.length} transaksi',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Rencana Tabungan ────────────────────────────────────────────────────

class SavingsPlanFormScreen extends StatefulWidget {
  final String userId;
  final SavingsPlanViewModel viewModel;
  final SavingsPlanModel? existing;

  const SavingsPlanFormScreen({
    super.key,
    required this.userId,
    required this.viewModel,
    this.existing,
  });

  @override
  State<SavingsPlanFormScreen> createState() => _SavingsPlanFormScreenState();
}

class _SavingsPlanFormScreenState extends State<SavingsPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  final _monthlyController = TextEditingController();
  String _icon = '🐷';
  DateTime? _targetDate;
  bool _isSaving = false;

  // Rekening tujuan tabungan
  List<PaymentMethodModel> _paymentMethods = [];
  PaymentMethodModel? _savingsMethod;
  bool _isLoadingMethods = true;

  bool get _isEdit => widget.existing != null;

  // Daftar emoji pilihan untuk tabungan
  static const _icons = [
    '🐷', '🏠', '✈️', '🚗', '💍', '📱', '💻', '🎓', '💰', '🏖️',
    '🏋️', '🎮', '👶', '🏥', '🛒', '⚡', '🌍', '🎵', '📷', '🎁',
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    if (_isEdit) {
      _nameController.text = widget.existing!.name;
      _descController.text = widget.existing!.description ?? '';
      _targetController.text = ThousandsSeparatorInputFormatter.formatWithDots(widget.existing!.targetAmount.toString());
      _monthlyController.text = widget.existing!.monthlyTarget > 0
          ? ThousandsSeparatorInputFormatter.formatWithDots(widget.existing!.monthlyTarget.toString())
          : '';
      _icon = widget.existing!.icon ?? '🐷';
      _targetDate = widget.existing!.targetDate;
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final repo = PaymentMethodRepository(service: PaymentMethodService());
      final methods = await repo.getAllPaymentMethods(widget.userId);
      if (mounted) {
        setState(() {
          _paymentMethods = methods.where((m) => m.isActive).toList();
          _isLoadingMethods = false;
          // Pre-fill rekening tabungan jika edit
          if (_isEdit && widget.existing!.savingsPaymentMethodId != null) {
            _savingsMethod = _paymentMethods
                .where((m) => m.id == widget.existing!.savingsPaymentMethodId)
                .firstOrNull;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMethods = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _targetController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Rencana' : 'Buat Rencana Tabungan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Icon picker
            Text('Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildIconPicker(),
            const SizedBox(height: 16),

            // Nama
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Tabungan',
                hintText: 'cth: DP Rumah, Liburan, Emergency Fund',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
              maxLength: 30,
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Nama tidak boleh kosong';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Deskripsi
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Target
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Target Total (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag_outlined),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Target tidak boleh kosong';
                final val = ThousandsSeparatorInputFormatter.parseValue(v);
                if (val <= 0) return 'Target harus lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Target per bulan (opsional)
            TextFormField(
              controller: _monthlyController,
              decoration: const InputDecoration(
                labelText: 'Target per Bulan (Rp, opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_month_outlined),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorInputFormatter()],
            ),
            const SizedBox(height: 12),

            // Deadline
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(
                _targetDate != null
                    ? 'Deadline: ${DateFormat('d MMMM yyyy', 'id_ID').format(_targetDate!)}'
                    : 'Deadline (opsional)',
              ),
              trailing: _targetDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _targetDate = null),
                    )
                  : null,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                );
                if (picked != null) setState(() => _targetDate = picked);
              },
            ),
            const SizedBox(height: 12),

            // Rekening Tujuan Tabungan
            if (_isLoadingMethods)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<PaymentMethodModel?>(
                initialValue: _savingsMethod,
                decoration: const InputDecoration(
                  labelText: 'Rekening Tabungan (opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.savings_outlined),
                  helperText: 'Rekening tempat uang tabungan disimpan',
                ),
                items: [
                  const DropdownMenuItem<PaymentMethodModel?>(
                    value: null,
                    child: Text('— Tanpa Rekening Khusus —'),
                  ),
                  ..._paymentMethods.map((m) => DropdownMenuItem<PaymentMethodModel?>(
                        value: m,
                        child: Text(m.name),
                      )),
                ],
                onChanged: (v) => setState(() => _savingsMethod = v),
              ),
            const Divider(),
            const SizedBox(height: 20),

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
              label: Text(_isEdit ? 'Simpan Perubahan' : 'Buat Rencana'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _icons.map((icon) {
        final isSelected = icon == _icon;
        return GestureDetector(
          onTap: () => setState(() => _icon = icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 20)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final targetVal = ThousandsSeparatorInputFormatter.parseValue(_targetController.text);
    final monthlyVal = ThousandsSeparatorInputFormatter.parseValue(_monthlyController.text);
    final desc = _descController.text.trim().isEmpty
        ? null
        : _descController.text.trim();

    bool ok;
    if (_isEdit) {
      ok = await widget.viewModel.updatePlan(
        widget.existing!.copyWith(
          name: _nameController.text.trim(),
          description: desc,
          icon: _icon,
          targetAmount: targetVal,
          monthlyTarget: monthlyVal,
          targetDate: _targetDate,
          savingsPaymentMethodId: _savingsMethod?.id,
          savingsPaymentMethodName: _savingsMethod?.name,
          updatedAt: DateTime.now(),
        ),
        widget.userId,
      );
    } else {
      ok = await widget.viewModel.createPlan(
        userId: widget.userId,
        name: _nameController.text.trim(),
        description: desc,
        icon: _icon,
        targetAmount: targetVal,
        monthlyTarget: monthlyVal,
        targetDate: _targetDate,
        savingsPaymentMethodId: _savingsMethod?.id,
        savingsPaymentMethodName: _savingsMethod?.name,
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.viewModel.errorMessage ?? 'Gagal menyimpan'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

// ─── Form Alokasi ─────────────────────────────────────────────────────────────

class SavingsAllocationFormScreen extends StatefulWidget {
  final String userId;
  final SavingsPlanModel plan;
  final SavingsPlanViewModel viewModel;

  const SavingsAllocationFormScreen({
    super.key,
    required this.userId,
    required this.plan,
    required this.viewModel,
  });

  @override
  State<SavingsAllocationFormScreen> createState() =>
      _SavingsAllocationFormScreenState();
}

class _SavingsAllocationFormScreenState
    extends State<SavingsAllocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transferFeeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isSaving = false;
  bool _isLoadingMethods = true;

  List<PaymentMethodModel> _paymentMethods = [];
  PaymentMethodModel? _fromMethod; // rekening sumber
  PaymentMethodModel? _toMethod;   // rekening tujuan/simpan

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final repo = PaymentMethodRepository(
        service: PaymentMethodService(),
      );
      final methods = await repo.getAllPaymentMethods(widget.userId);
      if (mounted) {
        setState(() {
          _paymentMethods = methods.where((m) => m.isActive).toList();
          _isLoadingMethods = false;
          // Pre-fill rekening tujuan dari plan.savingsPaymentMethodId
          if (widget.plan.savingsPaymentMethodId != null) {
            _toMethod = _paymentMethods
                .where((m) => m.id == widget.plan.savingsPaymentMethodId)
                .firstOrNull;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingMethods = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transferFeeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tabung ke ${widget.plan.name}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info plan
            Card(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(widget.plan.icon ?? '🐷',
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.plan.name,
                            style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          'Terkumpul: ${currency.format(widget.plan.savedAmount)} / ${currency.format(widget.plan.targetAmount)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nominal
            TextFormField(
              controller: _amountController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Jumlah Tabungan (Rp)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.savings_outlined),
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
            const SizedBox(height: 12),

            // Rekening Sumber
            if (_isLoadingMethods)
              const Center(child: CircularProgressIndicator())
            else ...[
              DropdownButtonFormField<PaymentMethodModel>(
                initialValue: _fromMethod,
                decoration: const InputDecoration(
                  labelText: 'Ambil dari Rekening *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  helperText: 'Rekening yang akan didebit',
                ),
                items: _paymentMethods.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.name),
                )).toList(),
                onChanged: (v) => setState(() => _fromMethod = v),
                validator: (v) => v == null ? 'Pilih rekening sumber' : null,
              ),
              const SizedBox(height: 12),

              // Rekening Simpan — hanya tampil jika plan belum punya rekening khusus
              if (widget.plan.savingsPaymentMethodId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.savings_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Disimpan ke Rekening',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.grey)),
                            Text(widget.plan.savingsPaymentMethodName ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<PaymentMethodModel?>(
                  initialValue: _toMethod,
                  decoration: const InputDecoration(
                    labelText: 'Simpan di Rekening (Opsional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.savings_outlined),
                    helperText: 'Kosongkan jika rekening sama / tidak tracking',
                  ),
                  items: [
                    const DropdownMenuItem<PaymentMethodModel?>(
                      value: null,
                      child: Text('— Tidak tracking —'),
                    ),
                    ..._paymentMethods.map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.name),
                    )),
                  ],
                  onChanged: (v) => setState(() => _toMethod = v),
                ),
              const SizedBox(height: 12),

              // Biaya Transfer (opsional)
              TextFormField(
                controller: _transferFeeController,
                decoration: const InputDecoration(
                  labelText: 'Biaya Transfer (Rp) - Opsional',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.price_change_outlined),
                  prefixText: 'Rp ',
                  helperText: 'Kosongkan jika tidak ada biaya transfer',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsSeparatorInputFormatter()],
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final val = ThousandsSeparatorInputFormatter.parseValue(v);
                    if (val < 0) return 'Biaya transfer tidak boleh negatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            // Tanggal
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(DateFormat('d MMMM yyyy', 'id_ID').format(_date)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Catatan
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
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
                  : const Icon(Icons.savings),
              label: const Text('Simpan Tabungan'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final ok = await widget.viewModel.addAllocation(
      userId: widget.userId,
      planId: widget.plan.id,
      planName: widget.plan.name,
      amount: ThousandsSeparatorInputFormatter.parseValue(_amountController.text),
      fromPaymentMethodId: _fromMethod!.id,
      fromPaymentMethodName: _fromMethod!.name,
      toPaymentMethodId: _toMethod?.id,
      toPaymentMethodName: _toMethod?.name,
      transferFee: ThousandsSeparatorInputFormatter.parseValue(_transferFeeController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      date: _date,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.viewModel.errorMessage ?? 'Gagal menyimpan'),
        backgroundColor: Colors.red,
      ));
    }
  }
}

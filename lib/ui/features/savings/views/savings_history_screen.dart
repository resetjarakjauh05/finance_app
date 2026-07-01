import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/savings_plan_model.dart';
import '../../../../data/repositories/savings_plan_repository.dart';
import '../../../../data/services/savings_plan_service.dart';
import '../../../core/icon_helper.dart';
import '../../../../data/local/savings_plan_dao.dart';

class SavingsHistoryScreen extends StatefulWidget {
  final String userId;
  final SavingsPlanModel plan;

  const SavingsHistoryScreen({
    super.key,
    required this.userId,
    required this.plan,
  });

  @override
  State<SavingsHistoryScreen> createState() => _SavingsHistoryScreenState();
}

class _SavingsHistoryScreenState extends State<SavingsHistoryScreen> {
  final _currency = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  List<SavingsAllocationModel> _allocations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = SavingsPlanRepository(
        service: SavingsPlanService(
          dao: SavingsPlanDao(),
          allocDao: SavingsAllocationDao(),
        ),
      );
      final allocs = await repo.getAllocations(widget.plan.id, widget.userId);
      // Sort terbaru dulu
      allocs.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) setState(() { _allocations = allocs; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Histori Tabungan', style: TextStyle(fontSize: 16)),
            Text(widget.plan.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(iconFromHex(widget.plan.icon ?? kSavingsMaterialIcons.first),
                        size: 28, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.plan.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: widget.plan.progress,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withValues(alpha: 0.2),
                            color: Theme.of(context).colorScheme.primary,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SummaryItem(
                      label: 'Terkumpul',
                      value: _currency.format(widget.plan.savedAmount),
                      color: Colors.green,
                    ),
                    _SummaryItem(
                      label: 'Target',
                      value: _currency.format(widget.plan.targetAmount),
                      color: Colors.blue,
                    ),
                    _SummaryItem(
                      label: 'Sisa',
                      value: _currency.format(widget.plan.remaining),
                      color: Colors.orange,
                    ),
                    _SummaryItem(
                      label: 'Setoran',
                      value: '${_allocations.length}x',
                      color: Colors.purple,
                    ),
                  ],
                ),
                if (widget.plan.savingsPaymentMethodName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.savings_outlined, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Rekening: ${widget.plan.savingsPaymentMethodName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // List header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('Riwayat Setoran',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!_isLoading)
                  Text('${_allocations.length} transaksi',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
              ],
            ),
          ),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(_error!),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: _loadHistory,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _allocations.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inbox_outlined,
                                    size: 56, color: Colors.grey),
                                SizedBox(height: 12),
                                Text('Belum ada setoran',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadHistory,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _allocations.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final a = _allocations[i];
                                return Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.green
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_upward,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                a.notes?.isNotEmpty == true
                                                    ? a.notes!
                                                    : 'Setoran tabungan',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${_dateFormat.format(a.date)} • Dari: ${a.fromPaymentMethodName}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                        color: Colors.grey),
                                              ),
                                              if (a.toPaymentMethodName !=
                                                  null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Ke: ${a.toPaymentMethodName}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          color: Colors.grey),
                                                ),
                                              ],
                                              if (a.transferFee > 0) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Biaya transfer: ${_currency.format(a.transferFee)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          color: Colors.red),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '+${_currency.format(a.amount)}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

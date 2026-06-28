import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/transaction_model.dart';
import '../../../../domain/models/payment_method_model.dart';

/// Filter modal untuk TransactionsScreen
class TransactionFilterModal extends StatefulWidget {
  final TransactionCategory? initialCategory;
  final String? initialPaymentMethodId;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final List<PaymentMethodModel> paymentMethods;

  const TransactionFilterModal({
    super.key,
    this.initialCategory,
    this.initialPaymentMethodId,
    this.initialStartDate,
    this.initialEndDate,
    required this.paymentMethods,
  });

  @override
  State<TransactionFilterModal> createState() => _TransactionFilterModalState();
}

class _TransactionFilterModalState extends State<TransactionFilterModal> {
  TransactionCategory? _category;
  String? _paymentMethodId;
  DateTime? _startDate;
  DateTime? _endDate;

  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
    _paymentMethodId = widget.initialPaymentMethodId;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  bool get _hasFilters =>
      _category != null ||
      _paymentMethodId != null ||
      _startDate != null ||
      _endDate != null;

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-fix: start > end → reset end
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Filter Transaksi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  if (_hasFilters)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _category = null;
                          _paymentMethodId = null;
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Kategori
                  Text(
                    'Kategori',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Semua'),
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      FilterChip(
                        label: const Text('Uang Masuk'),
                        selected: _category == TransactionCategory.income,
                        onSelected: (_) => setState(
                          () => _category = _category == TransactionCategory.income
                              ? null
                              : TransactionCategory.income,
                        ),
                        avatar: const Icon(Icons.arrow_downward, size: 14),
                        selectedColor: Colors.green.shade100,
                      ),
                      FilterChip(
                        label: const Text('Uang Keluar'),
                        selected: _category == TransactionCategory.expense,
                        onSelected: (_) => setState(
                          () => _category = _category == TransactionCategory.expense
                              ? null
                              : TransactionCategory.expense,
                        ),
                        avatar: const Icon(Icons.arrow_upward, size: 14),
                        selectedColor: Colors.red.shade100,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Metode Pembayaran
                  Text(
                    'Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String?>(
                    value: _paymentMethodId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Semua metode pembayaran'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Semua'),
                      ),
                      ...widget.paymentMethods.map(
                        (m) => DropdownMenuItem<String?>(
                          value: m.id,
                          child: Text(m.name),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _paymentMethodId = value),
                  ),

                  const SizedBox(height: 20),

                  // Rentang Tanggal
                  Text(
                    'Rentang Tanggal',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: true),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _startDate != null
                                ? _dateFormat.format(_startDate!)
                                : 'Dari tanggal',
                            style: TextStyle(
                              color: _startDate != null
                                  ? null
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('—'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDate(isStart: false),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            _endDate != null
                                ? _dateFormat.format(_endDate!)
                                : 'Sampai tanggal',
                            style: TextStyle(
                              color: _endDate != null
                                  ? null
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_startDate != null || _endDate != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _startDate = _endDate = null),
                      icon: const Icon(Icons.clear, size: 14),
                      label: const Text('Hapus rentang tanggal'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Apply button
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'category': _category,
                      'paymentMethodId': _paymentMethodId,
                      'startDate': _startDate,
                      'endDate': _endDate,
                    });
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _hasFilters ? 'Terapkan Filter' : 'Tampilkan Semua',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

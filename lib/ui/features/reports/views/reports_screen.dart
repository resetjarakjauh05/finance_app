import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/csv_export_service.dart';
import '../../../../data/repositories/transaction_repository.dart';

/// Pilihan range laporan
enum _ReportRange { thisMonth, last3Months, last6Months, thisYear, lastYear, custom }

extension _ReportRangeExt on _ReportRange {
  String get label {
    switch (this) {
      case _ReportRange.thisMonth: return 'Bulan Ini';
      case _ReportRange.last3Months: return '3 Bulan';
      case _ReportRange.last6Months: return '6 Bulan';
      case _ReportRange.thisYear: return 'Tahun Ini';
      case _ReportRange.lastYear: return 'Tahun Lalu';
      case _ReportRange.custom: return 'Custom';
    }
  }

  /// Return (startDate, endDate) untuk range ini
  (DateTime, DateTime) dateRange([DateTime? customStart, DateTime? customEnd]) {
    final now = DateTime.now();
    switch (this) {
      case _ReportRange.thisMonth:
        return (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0, 23, 59, 59));
      case _ReportRange.last3Months:
        return (DateTime(now.year, now.month - 2, 1), DateTime(now.year, now.month + 1, 0, 23, 59, 59));
      case _ReportRange.last6Months:
        return (DateTime(now.year, now.month - 5, 1), DateTime(now.year, now.month + 1, 0, 23, 59, 59));
      case _ReportRange.thisYear:
        return (DateTime(now.year, 1, 1), DateTime(now.year, 12, 31, 23, 59, 59));
      case _ReportRange.lastYear:
        return (DateTime(now.year - 1, 1, 1), DateTime(now.year - 1, 12, 31, 23, 59, 59));
      case _ReportRange.custom:
        return (customStart ?? DateTime(now.year, now.month, 1), customEnd ?? now);
    }
  }

  int get months {
    switch (this) {
      case _ReportRange.thisMonth: return 1;
      case _ReportRange.last3Months: return 3;
      case _ReportRange.last6Months: return 6;
      case _ReportRange.thisYear: return 12;
      case _ReportRange.lastYear: return 12;
      case _ReportRange.custom: return 6;
    }
  }
}

class ReportsScreen extends StatefulWidget {
  final String userId;
  const ReportsScreen({super.key, required this.userId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final _monthFormat = DateFormat('MMM yy', 'id_ID');
  final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

  bool _isLoading = false;
  List<Map<String, dynamic>> _monthlySummary = [];
  Map<String, int> _categoryBreakdown = {};
  int _totalIncome = 0;
  int _totalExpense = 0;

  // Date range state
  _ReportRange _selectedRange = _ReportRange.thisYear;
  DateTime? _customStart;
  DateTime? _customEnd;

  DateTime get _startDate => _selectedRange.dateRange(_customStart, _customEnd).$1;
  DateTime get _endDate => _selectedRange.dateRange(_customStart, _customEnd).$2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = TransactionRepository(service: TransactionService());
      final start = _startDate;
      final end = _endDate;
      final months = _selectedRange.months;

      final results = await Future.wait([
        repo.getMonthlySummary(widget.userId, months: months),
        repo.getCategoryBreakdown(widget.userId, startDate: start, endDate: end),
        repo.getTotalIncome(widget.userId, startDate: start, endDate: end),
        repo.getTotalExpense(widget.userId, startDate: start, endDate: end),
      ]);
      if (mounted) {
        setState(() {
          _monthlySummary = results[0] as List<Map<String, dynamic>>;
          _categoryBreakdown = results[1] as Map<String, int>;
          _totalIncome = results[2] as int;
          _totalExpense = results[3] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportCsv() async {
    try {
      final repo = TransactionRepository(service: TransactionService());
      // Export hanya dalam range yang dipilih
      final transactions = await repo.getTransactionsByDateRange(
        widget.userId,
        startDate: _startDate,
        endDate: _endDate,
      );
      final csv = CsvExportService.exportTransactions(transactions);
      await Clipboard.setData(ClipboardData(text: csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV (${transactions.length} transaksi) disalin ke clipboard'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal export: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && mounted) {
      setState(() {
        _customStart = picked.start;
        _customEnd = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
        _selectedRange = _ReportRange.custom;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Column(
            children: [
              // Range filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    ..._ReportRange.values.where((r) => r != _ReportRange.custom).map((r) =>
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(r.label),
                          selected: _selectedRange == r,
                          onSelected: (_) {
                            setState(() => _selectedRange = r);
                            _loadData();
                          },
                        ),
                      ),
                    ),
                    FilterChip(
                      label: Text(_selectedRange == _ReportRange.custom
                          ? '${_dateFormat.format(_startDate)} – ${_dateFormat.format(_endDate)}'
                          : 'Custom'),
                      selected: _selectedRange == _ReportRange.custom,
                      onSelected: (_) => _pickCustomRange(),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Ringkasan'),
                  Tab(text: 'Bulanan'),
                  Tab(text: 'Kategori'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildMonthlyTab(),
                _buildCategoryTab(),
              ],
            ),
    );
  }

  // ===== SUMMARY TAB =====
  Widget _buildSummaryTab() {
    final net = _totalIncome - _totalExpense;
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_dateFormat.format(_startDate)} – ${_dateFormat.format(_endDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            // Summary cards
            Row(
              children: [
                Expanded(child: _summaryCard('Total Pemasukan', _totalIncome, Colors.green, Icons.arrow_downward)),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard('Total Pengeluaran', _totalExpense, Colors.red, Icons.arrow_upward)),
              ],
            ),
            const SizedBox(height: 12),
            _summaryCard('Saldo Bersih', net, net >= 0 ? Colors.blue : Colors.red, Icons.account_balance_wallet),
            const SizedBox(height: 24),

            // Pie chart income vs expense
            if (_totalIncome > 0 || _totalExpense > 0) ...[
              Text('Komposisi Keuangan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: _totalIncome.toDouble(),
                        color: Colors.green,
                        title: 'Masuk',
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        radius: 80,
                      ),
                      PieChartSectionData(
                        value: _totalExpense.toDouble(),
                        color: Colors.red,
                        title: 'Keluar',
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        radius: 80,
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(Colors.green, 'Pemasukan ${_currencyFormat.format(_totalIncome)}'),
                  const SizedBox(width: 16),
                  _legendItem(Colors.red, 'Pengeluaran ${_currencyFormat.format(_totalExpense)}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===== MONTHLY TAB =====
  Widget _buildMonthlyTab() {
    if (_monthlySummary.isEmpty) {
      return const Center(child: Text('Tidak ada data untuk periode ini'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tren Bulanan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                barGroups: _monthlySummary.asMap().entries.map((e) {
                  final income = (e.value['income'] as int).toDouble();
                  final expense = (e.value['expense'] as int).toDouble();
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(toY: income, color: Colors.green, width: 8, borderRadius: BorderRadius.circular(4)),
                      BarChartRodData(toY: expense, color: Colors.red, width: 8, borderRadius: BorderRadius.circular(4)),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= _monthlySummary.length) return const SizedBox.shrink();
                        final month = _monthlySummary[idx]['month'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(_monthFormat.format(month), style: const TextStyle(fontSize: 9)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.green, 'Pemasukan'),
              const SizedBox(width: 16),
              _legendItem(Colors.red, 'Pengeluaran'),
            ],
          ),
          const SizedBox(height: 24),
          // List detail per bulan
          ..._monthlySummary.reversed.map((m) {
            final month = m['month'] as DateTime;
            final income = m['income'] as int;
            final expense = m['expense'] as int;
            final net = m['net'] as int;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(DateFormat('MMMM yyyy', 'id_ID').format(month), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Row(
                  children: [
                    _legendItem(Colors.green, _currencyFormat.format(income)),
                    const SizedBox(width: 12),
                    _legendItem(Colors.red, _currencyFormat.format(expense)),
                  ],
                ),
                trailing: Text(
                  _currencyFormat.format(net),
                  style: TextStyle(
                    color: net >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===== CATEGORY TAB =====
  Widget _buildCategoryTab() {
    if (_categoryBreakdown.isEmpty) {
      return const Center(child: Text('Tidak ada data pengeluaran untuk periode ini'));
    }
    final sorted = _categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<int>(0, (s, e) => s + e.value);
    final colors = [
      Colors.blue, Colors.orange, Colors.purple, Colors.teal,
      Colors.pink, Colors.indigo, Colors.brown, Colors.cyan,
      Colors.lime, Colors.amber,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pengeluaran per Kategori',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (sorted.isNotEmpty)
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: sorted.take(8).toList().asMap().entries.map((e) {
                    final pct = total > 0 ? (e.value.value / total * 100) : 0.0;
                    return PieChartSectionData(
                      value: e.value.value.toDouble(),
                      color: colors[e.key % colors.length],
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      radius: 80,
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          const SizedBox(height: 16),
          ...sorted.take(10).toList().asMap().entries.map((e) {
            final pct = total > 0 ? (e.value.value / total * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: colors[e.key % colors.length], shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(e.value.key, style: const TextStyle(fontSize: 13))),
                  Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 8),
                  Text(_currencyFormat.format(e.value.value),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int amount, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
            ]),
            const SizedBox(height: 8),
            Text(_currencyFormat.format(amount),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(children: [
      Container(width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

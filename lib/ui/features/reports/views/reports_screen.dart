import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/csv_export_service.dart';
import '../../../../data/repositories/transaction_repository.dart';

class ReportsScreen extends StatefulWidget {
  final String userId;
  const ReportsScreen({super.key, required this.userId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0,
  );
  final _monthFormat = DateFormat('MMM yy', 'id_ID');

  bool _isLoading = false;
  List<Map<String, dynamic>> _monthlySummary = [];
  Map<String, int> _categoryBreakdown = {};
  int _totalIncome = 0;
  int _totalExpense = 0;

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
      final results = await Future.wait([
        repo.getMonthlySummary(widget.userId, months: 6),
        repo.getCategoryBreakdown(widget.userId),
        repo.getTotalIncome(widget.userId),
        repo.getTotalExpense(widget.userId),
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
      final transactions = await repo.getTransactions(widget.userId);
      final csv = CsvExportService.exportTransactions(transactions);
      await Clipboard.setData(ClipboardData(text: csv));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV disalin ke clipboard'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Bulanan'),
            Tab(text: 'Kategori'),
          ],
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
      return const Center(child: Text('Belum ada data transaksi'));
    }
    final maxVal = _monthlySummary.fold<double>(0, (max, m) {
      final income = (m['income'] as int).toDouble();
      final expense = (m['expense'] as int).toDouble();
      return [max, income, expense].reduce((a, b) => a > b ? a : b);
    });

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('6 Bulan Terakhir',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  maxY: maxVal > 0 ? maxVal * 1.2 : 100,
                  barGroups: _monthlySummary.asMap().entries.map((e) {
                    final idx = e.key;
                    final data = e.value;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: (data['income'] as int).toDouble(),
                          color: Colors.green,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: (data['expense'] as int).toDouble(),
                          color: Colors.red,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < _monthlySummary.length) {
                            final month = _monthlySummary[idx]['month'] as DateTime;
                            return Text(_monthFormat.format(month),
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(Colors.green, 'Pemasukan'),
                const SizedBox(width: 16),
                _legendItem(Colors.red, 'Pengeluaran'),
              ],
            ),
            const SizedBox(height: 24),
            // Monthly table
            Text('Detail Bulanan',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._monthlySummary.map((m) {
              final month = m['month'] as DateTime;
              final income = m['income'] as int;
              final expense = m['expense'] as int;
              final net = m['net'] as int;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(DateFormat('MMMM yyyy', 'id_ID').format(month),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+${_currencyFormat.format(income)}',
                              style: const TextStyle(color: Colors.green, fontSize: 12)),
                          Text('-${_currencyFormat.format(expense)}',
                              style: const TextStyle(color: Colors.red, fontSize: 12)),
                          Text(_currencyFormat.format(net),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: net >= 0 ? Colors.blue : Colors.red,
                                fontSize: 13,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ===== CATEGORY TAB =====
  Widget _buildCategoryTab() {
    if (_categoryBreakdown.isEmpty) {
      return const Center(child: Text('Belum ada data pengeluaran'));
    }
    final sorted = _categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<int>(0, (sum, e) => sum + e.value);
    final colors = [
      Colors.blue, Colors.orange, Colors.purple, Colors.teal,
      Colors.pink, Colors.cyan, Colors.lime, Colors.brown,
    ];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pengeluaran per Kategori',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: sorted.asMap().entries.map((e) {
                    final color = colors[e.key % colors.length];
                    final pct = total > 0 ? (e.value.value / total * 100) : 0;
                    return PieChartSectionData(
                      value: e.value.value.toDouble(),
                      color: color,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      radius: 75,
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend + breakdown list
            ...sorted.asMap().entries.map((e) {
              final color = colors[e.key % colors.length];
              final pct = total > 0 ? (e.value.value / total * 100) : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 14, height: 14,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.value.key)),
                    Text('${pct.toStringAsFixed(1)}%',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text(_currencyFormat.format(e.value.value),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ),
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

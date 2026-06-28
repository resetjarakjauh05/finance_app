import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/transaction_service.dart';
import '../../../../data/services/notification_service.dart';
import '../../../../data/services/payment_method_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../data/repositories/payment_method_repository.dart';
import '../../../../domain/models/transaction_model.dart';
import '../../../../domain/models/payment_method_model.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../payment_methods/views/payment_methods_screen.dart';
import '../../transactions/views/transactions_screen.dart';
import '../../transactions/views/add_edit_transaction_screen.dart';
import '../../bills/views/bills_screen.dart';
import '../../custody/views/custody_screen.dart';
import '../../reports/views/reports_screen.dart';
import '../../settings/views/settings_screen.dart';
import '../../settings/views/help_screen.dart';
import '../../categories/views/category_list_screen.dart';
import '../../spending_limit/views/spending_limit_screen.dart';
import '../../budget/views/monthly_budget_screen.dart';
import '../../savings/views/savings_plan_screen.dart';
import '../../transactions/views/transfer_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final AuthViewModel _authViewModel;
  int _selectedIndex = 0;
  int _transactionRefreshKey = 0;

  // Balance state
  int _netBalance = 0;
  int _totalIncome = 0;
  int _totalExpense = 0;
  int _incomeThisMonth = 0;
  int _expenseThisMonth = 0;
  bool _isLoadingBalance = false;

  // Recent transactions
  List<TransactionModel> _recentTransactions = [];
  bool _isLoadingRecent = false;

  // Saldo per metode pembayaran
  Map<String, int> _balancePerMethod = {};
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoadingMethods = false;

  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final _dateFormat = DateFormat('dd MMM', 'id_ID');

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(
      authRepository: AuthRepository(authService: AuthService()),
    );
    _authViewModel.addListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authViewModel.removeListener(_onAuthStateChanged);
    _authViewModel.dispose();
    super.dispose();
  }

  void _onAuthStateChanged() {
    if (_authViewModel.isAuthenticated && mounted) {
      _loadDashboardData();
      // Save FCM token + check bills due (async, non-blocking)
      final user = _authViewModel.currentUser;
      if (user != null) {
        Future.microtask(() async {
          final notif = NotificationService();
          await notif.saveTokenToFirestore(user.id);
          await notif.checkBillsDue(user.id);
        });
      }
    }
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([
      _loadBalance(),
      _loadRecentTransactions(),
      _loadPaymentMethodBalances(),
    ]);
  }

  Future<void> _loadBalance() async {
    final user = _authViewModel.currentUser;
    if (user == null) return;
    setState(() => _isLoadingBalance = true);
    try {
      final repo = TransactionRepository(service: TransactionService());
      // Sync Firestore → SQLite dulu agar data terkini
      await repo.initialSyncFromFirestore(user.id);
      final results = await Future.wait([
        repo.getTotalIncome(user.id),
        repo.getTotalExpense(user.id),
        repo.getTotalIncomeThisMonth(user.id),
        repo.getTotalExpenseThisMonth(user.id),
      ]);
      if (mounted) {
        setState(() {
          _totalIncome = results[0];
          _totalExpense = results[1];
          _netBalance = results[0] - results[1];
          _incomeThisMonth = results[2];
          _expenseThisMonth = results[3];
          _isLoadingBalance = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingBalance = false);
    }
  }

  Future<void> _loadRecentTransactions() async {
    final user = _authViewModel.currentUser;
    if (user == null) return;
    setState(() => _isLoadingRecent = true);
    try {
      final repo = TransactionRepository(service: TransactionService());
      final recent = await repo.getRecentTransactions(user.id, limit: 5);
      if (mounted) {
        setState(() {
          _recentTransactions = recent;
          _isLoadingRecent = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRecent = false);
    }
  }

  Future<void> _loadPaymentMethodBalances() async {
    final user = _authViewModel.currentUser;
    if (user == null) return;
    setState(() => _isLoadingMethods = true);
    try {
      final txRepo = TransactionRepository(service: TransactionService());
      final pmRepo = PaymentMethodRepository(
        service: PaymentMethodService(),
      );
      final results = await Future.wait([
        txRepo.getBalancePerPaymentMethod(user.id),
        pmRepo.getAllPaymentMethods(user.id),
      ]);
      if (mounted) {
        setState(() {
          _balancePerMethod = results[0] as Map<String, int>;
          _paymentMethods = results[1] as List<PaymentMethodModel>;
          _isLoadingMethods = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMethods = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _authViewModel.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authViewModel,
      builder: (context, _) {
        final user = _authViewModel.currentUser;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Aplikasi Keuangan'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Keluar',
                onPressed: _handleLogout,
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(user),
              if (user != null)
                TransactionsScreen(
                  key: ValueKey('transactions_$_transactionRefreshKey'),
                  userId: user.id,
                )
              else
                const Center(child: CircularProgressIndicator()),
              if (user != null)
                BillsScreen(userId: user.id)
              else
                const Center(child: CircularProgressIndicator()),
              _buildMoreTab(user),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
                // Refresh transactions when switching to tab 1
                if (index == 1) _transactionRefreshKey++;
              });
              if (index == 0) _loadDashboardData();
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Transaksi',
              ),
              NavigationDestination(
                icon: Icon(Icons.credit_card_outlined),
                selectedIcon: Icon(Icons.credit_card),
                label: 'Tagihan',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                selectedIcon: Icon(Icons.menu),
                label: 'Lainnya',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeTab(user) {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        (user?.displayName ?? user?.email ?? 'U')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selamat Datang,',
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text(
                          user?.displayName ?? user?.email ?? 'User',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Total saldo
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saldo',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _isLoadingBalance
                        ? const SizedBox(
                            height: 32,
                            width: 32,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _currencyFormat.format(_netBalance),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats all time
            Text(
              'Total Keseluruhan',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    label: 'Pemasukan',
                    amount: _totalIncome,
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    label: 'Pengeluaran',
                    amount: _totalExpense,
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats bulan ini
            Text(
              'Bulan Ini',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    label: 'Pemasukan',
                    amount: _incomeThisMonth,
                    icon: Icons.arrow_downward,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    label: 'Pengeluaran',
                    amount: _expenseThisMonth,
                    icon: Icons.arrow_upward,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick actions
            Text(
              'Aksi Cepat',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: user == null
                        ? null
                        : () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditTransactionScreen(
                                        userId: user.id),
                              ),
                            );
                            setState(() => _transactionRefreshKey++);
                            _loadDashboardData();
                          },
                    icon: const Icon(Icons.add),
                    label: const Text('Transaksi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => setState(() => _selectedIndex = 2),
                    icon: const Icon(Icons.receipt),
                    label: const Text('Tagihan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Transfer button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: user == null
                    ? null
                    : () async {
                        final result = await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (context) =>
                                TransferScreen(userId: user.id),
                          ),
                        );
                        if (result == 'transfer_success') {
                          setState(() => _transactionRefreshKey++);
                          _loadDashboardData();
                        }
                      },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Transfer Antar Rekening'),
              ),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 24),

            // Saldo per metode pembayaran
            Text(
              'Saldo per Metode Pembayaran',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isLoadingMethods
                ? const Center(child: CircularProgressIndicator())
                : _paymentMethods.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Belum ada metode pembayaran',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: _paymentMethods.map((m) {
                          final balance = _balancePerMethod[m.id] ?? 0;
                          final isPositive = balance >= 0;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _methodColor(m.type)
                                    .withAlpha(30),
                                child: Text(
                                  m.type.icon,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              title: Text(
                                m.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: m.isActive ? null : Colors.grey,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text(m.type.displayName),
                                  if (!m.isActive) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        border: Border.all(
                                            color: Colors.red.shade200),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Nonaktif',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Text(
                                _currencyFormat.format(balance),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: m.isActive
                                      ? (isPositive
                                          ? Colors.green.shade700
                                          : Colors.red.shade700)
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

            // Recent transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Terakhir',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoadingRecent
                ? const Center(child: CircularProgressIndicator())
                : _recentTransactions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Belum ada transaksi',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: _recentTransactions.map((t) {
                          final isIncome =
                              t.category == TransactionCategory.income;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: isIncome
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color:
                                    isIncome ? Colors.green : Colors.red,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              t.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${t.paymentMethodName} · ${_dateFormat.format(t.date)}',
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}${_currencyFormat.format(t.nominal)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Color _methodColor(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.cash:
        return Colors.orange;
      case PaymentMethodType.bank:
        return Colors.blue;
      case PaymentMethodType.wallet:
        return Colors.green;
      case PaymentMethodType.digital:
        return Colors.purple;
    }
  }

  Widget _statCard({
    required String label,
    required int amount,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            _isLoadingBalance
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _currencyFormat.format(amount),
                    style:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreTab(user) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('Metode Pembayaran'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentMethodsScreen(userId: user.id),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.swap_horiz),
          title: const Text('Titipan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CustodyScreen(userId: user.id),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Laporan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportsScreen(userId: user.id),
                ),
              );
            }
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('Perencanaan',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  )),
        ),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: const Text('Kategori'),
          subtitle: const Text('Kelola kategori pengeluaran'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryListScreen(userId: user.id),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.speed_outlined),
          title: const Text('Limit Harian'),
          subtitle: const Text('Atur batas pengeluaran harian'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SpendingLimitScreen(userId: user.id),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.pie_chart_outline),
          title: const Text('Anggaran Bulanan'),
          subtitle: const Text('Rencanakan pengeluaran per kategori'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MonthlyBudgetScreen(userId: user.id),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.savings_outlined),
          title: const Text('Rencana Tabungan'),
          subtitle: const Text('Kelola target tabungan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SavingsPlanScreen(userId: user.id),
                ),
              );
            }
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Pengaturan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    userId: user.id,
                    displayName: user.displayName,
                    email: user.email,
                  ),
                ),
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Bantuan'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Tentang Aplikasi'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Aplikasi Keuangan',
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(
              Icons.account_balance_wallet,
              size: 48,
              color: Colors.blue,
            ),
            children: const [
              Text('Aplikasi tracking keuangan personal dengan Firebase & SQLite.'),
              SizedBox(height: 8),
              Text('Fitur: Transaksi, Tagihan, Titipan, Laporan'),
            ],
          ),
        ),
      ],
    );
  }
}

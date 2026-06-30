import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

/// DatabaseHelper - Singleton class untuk manage SQLite database
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'financial_app.db');

    return openDatabase(
      path,
      version: 10,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
      onOpen: (db) async {
        // Ensure bills table has all required columns regardless of version
        final billsCols = await db.rawQuery('PRAGMA table_info(bills)');
        final billsColNames = billsCols.map((c) => c['name'] as String).toSet();
        if (!billsColNames.contains('type')) {
          await db.execute(
            "ALTER TABLE bills ADD COLUMN type TEXT NOT NULL DEFAULT 'HUTANG'",
          );
          debugPrint('DB onOpen: added bills.type');
        }
        if (!billsColNames.contains('isDeleted')) {
          await db.execute(
            "ALTER TABLE bills ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0",
          );
          debugPrint('DB onOpen: added bills.isDeleted');
        }
        if (!billsColNames.contains('categoryId')) {
          await db.execute("ALTER TABLE bills ADD COLUMN categoryId TEXT");
          debugPrint('DB onOpen: added bills.categoryId');
        }
        if (!billsColNames.contains('categoryName')) {
          await db.execute("ALTER TABLE bills ADD COLUMN categoryName TEXT");
          debugPrint('DB onOpen: added bills.categoryName');
        }
        if (!billsColNames.contains('paymentMethodId')) {
          await db.execute("ALTER TABLE bills ADD COLUMN paymentMethodId TEXT");
          debugPrint('DB onOpen: added bills.paymentMethodId');
        }
        if (!billsColNames.contains('paymentMethodName')) {
          await db.execute("ALTER TABLE bills ADD COLUMN paymentMethodName TEXT");
          debugPrint('DB onOpen: added bills.paymentMethodName');
        }
        if (!billsColNames.contains('transferFee')) {
          await db.execute("ALTER TABLE bills ADD COLUMN transferFee INTEGER NOT NULL DEFAULT 0");
          debugPrint('DB onOpen: added bills.transferFee');
        }

        // Ensure custody table has all required columns
        final custodyCols = await db.rawQuery('PRAGMA table_info(custody)');
        final custodyColNames = custodyCols.map((c) => c['name'] as String).toSet();
        if (!custodyColNames.contains('isDeleted')) {
          await db.execute(
            "ALTER TABLE custody ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0",
          );
          debugPrint('DB onOpen: added custody.isDeleted');
        }
        if (!custodyColNames.contains('updatedAt')) {
          await db.execute(
            "ALTER TABLE custody ADD COLUMN updatedAt INTEGER",
          );
          debugPrint('DB onOpen: added custody.updatedAt');
        }

        // Ensure custody_movements table has custodyFirebaseDocId + isDeleted
        final movCols = await db.rawQuery('PRAGMA table_info(custody_movements)');
        final movColNames = movCols.map((c) => c['name'] as String).toSet();
        if (!movColNames.contains('custodyFirebaseDocId')) {
          await db.execute(
            "ALTER TABLE custody_movements ADD COLUMN custodyFirebaseDocId TEXT",
          );
          debugPrint('DB onOpen: added custody_movements.custodyFirebaseDocId');
        }
        // BUG-6 FIX: isDeleted diperlukan untuk soft-delete movements
        if (!movColNames.contains('isDeleted')) {
          await db.execute(
            "ALTER TABLE custody_movements ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0",
          );
          debugPrint('DB onOpen: added custody_movements.isDeleted');
        }
        if (!movColNames.contains('transferFee')) {
          await db.execute(
            "ALTER TABLE custody_movements ADD COLUMN transferFee INTEGER NOT NULL DEFAULT 0",
          );
          debugPrint('DB onOpen: added custody_movements.transferFee');
        }

        // Ensure transactions table has categoryId + categoryName
        final txCols = await db.rawQuery('PRAGMA table_info(transactions)');
        final txColNames = txCols.map((c) => c['name'] as String).toSet();
        if (!txColNames.contains('categoryId')) {
          await db.execute("ALTER TABLE transactions ADD COLUMN categoryId TEXT");
          debugPrint('DB onOpen: added transactions.categoryId');
        }
        if (!txColNames.contains('categoryName')) {
          await db.execute("ALTER TABLE transactions ADD COLUMN categoryName TEXT");
          debugPrint('DB onOpen: added transactions.categoryName');
        }

        // Ensure spending_limits table exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS spending_limits(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            categoryId TEXT,
            categoryName TEXT,
            categoryIcon TEXT,
            dailyLimit INTEGER NOT NULL,
            warningThreshold REAL DEFAULT 0.8,
            isActive INTEGER DEFAULT 1,
            firebaseDocId TEXT,
            isSynced INTEGER DEFAULT 0,
            syncedAt INTEGER,
            localCreatedAt INTEGER NOT NULL,
            updatedAt INTEGER,
            isDeleted INTEGER DEFAULT 0
          )
        ''');
        debugPrint('DB onOpen: spending_limits table ensured');

        // Ensure categories table exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS categories(
            id TEXT PRIMARY KEY,
            firebaseDocId TEXT,
            userId TEXT NOT NULL,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color INTEGER NOT NULL,
            isPreset INTEGER DEFAULT 0,
            isActive INTEGER DEFAULT 1,
            isSynced INTEGER DEFAULT 0,
            syncedAt INTEGER,
            localCreatedAt INTEGER NOT NULL,
            updatedAt INTEGER,
            isDeleted INTEGER DEFAULT 0
          )
        ''');
        debugPrint('DB onOpen: categories table ensured');

        // Ensure monthly_budgets table exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS monthly_budgets(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            yearMonth TEXT NOT NULL,
            categoryId TEXT NOT NULL,
            categoryName TEXT NOT NULL,
            categoryIcon TEXT NOT NULL,
            budgetAmount INTEGER NOT NULL,
            notes TEXT,
            firebaseDocId TEXT,
            isSynced INTEGER DEFAULT 0,
            syncedAt INTEGER,
            localCreatedAt INTEGER NOT NULL,
            updatedAt INTEGER,
            isDeleted INTEGER DEFAULT 0
          )
        ''');
        debugPrint('DB onOpen: monthly_budgets table ensured');

        // Ensure savings_plans table exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS savings_plans(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            icon TEXT,
            targetAmount INTEGER NOT NULL,
            savedAmount INTEGER DEFAULT 0,
            monthlyTarget INTEGER DEFAULT 0,
            targetDate INTEGER,
            savingsPaymentMethodId TEXT,
            savingsPaymentMethodName TEXT,
            isActive INTEGER DEFAULT 1,
            firebaseDocId TEXT,
            isSynced INTEGER DEFAULT 0,
            syncedAt INTEGER,
            localCreatedAt INTEGER NOT NULL,
            updatedAt INTEGER,
            isDeleted INTEGER DEFAULT 0
          )
        ''');
        // Migration: tambah kolom baru jika belum ada (device lama)
        final spCols = await db.rawQuery('PRAGMA table_info(savings_plans)');
        final spColNames = spCols.map((c) => c['name'] as String).toSet();
        if (!spColNames.contains('savingsPaymentMethodId')) {
          await db.execute('ALTER TABLE savings_plans ADD COLUMN savingsPaymentMethodId TEXT');
          debugPrint('DB onOpen: added savings_plans.savingsPaymentMethodId');
        }
        if (!spColNames.contains('savingsPaymentMethodName')) {
          await db.execute('ALTER TABLE savings_plans ADD COLUMN savingsPaymentMethodName TEXT');
          debugPrint('DB onOpen: added savings_plans.savingsPaymentMethodName');
        }
        debugPrint('DB onOpen: savings_plans table ensured');

        // Ensure savings_allocations table exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS savings_allocations(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            savingsPlanId TEXT NOT NULL,
            amount INTEGER NOT NULL,
            notes TEXT,
            date INTEGER NOT NULL,
            fromPaymentMethodId TEXT NOT NULL DEFAULT '',
            fromPaymentMethodName TEXT NOT NULL DEFAULT '',
            toPaymentMethodId TEXT,
            toPaymentMethodName TEXT,
            firebaseDocId TEXT,
            isSynced INTEGER DEFAULT 0,
            localCreatedAt INTEGER NOT NULL,
            isDeleted INTEGER DEFAULT 0
          )
        ''');
        // ALTER TABLE untuk device yang sudah punya tabel lama
        final allocCols = await db.rawQuery('PRAGMA table_info(savings_allocations)');
        final allocColNames = allocCols.map((c) => c['name'] as String).toSet();
        if (!allocColNames.contains('fromPaymentMethodId')) {
          await db.execute("ALTER TABLE savings_allocations ADD COLUMN fromPaymentMethodId TEXT NOT NULL DEFAULT ''");
          debugPrint('DB onOpen: added savings_allocations.fromPaymentMethodId');
        }
        if (!allocColNames.contains('fromPaymentMethodName')) {
          await db.execute("ALTER TABLE savings_allocations ADD COLUMN fromPaymentMethodName TEXT NOT NULL DEFAULT ''");
          debugPrint('DB onOpen: added savings_allocations.fromPaymentMethodName');
        }
        if (!allocColNames.contains('toPaymentMethodId')) {
          await db.execute("ALTER TABLE savings_allocations ADD COLUMN toPaymentMethodId TEXT");
          debugPrint('DB onOpen: added savings_allocations.toPaymentMethodId');
        }
        if (!allocColNames.contains('toPaymentMethodName')) {
          await db.execute("ALTER TABLE savings_allocations ADD COLUMN toPaymentMethodName TEXT");
          debugPrint('DB onOpen: added savings_allocations.toPaymentMethodName');
        }
        if (!allocColNames.contains('transferFee')) {
          await db.execute("ALTER TABLE savings_allocations ADD COLUMN transferFee INTEGER NOT NULL DEFAULT 0");
          debugPrint('DB onOpen: added savings_allocations.transferFee');
        }
        debugPrint('DB onOpen: savings_allocations table ensured');

        // Ensure payment_methods SQLite cache table exists
        // Detect schema lama (id INTEGER) → drop & recreate dengan schema baru (id TEXT)
        final pmColsCheck = await db.rawQuery('PRAGMA table_info(payment_methods)');
        final pmIdCol = pmColsCheck.where((c) => c['name'] == 'id').firstOrNull;
        final pmIdIsInteger = pmIdCol != null &&
            (pmIdCol['type'] as String).toUpperCase().contains('INTEGER');
        if (pmIdIsInteger) {
          // Tabel lama tidak kompatibel — hapus dan buat ulang
          await db.execute('DROP TABLE IF EXISTS payment_methods');
          debugPrint('DB onOpen: dropped old payment_methods (INTEGER id schema)');
        }
        await db.execute('''
          CREATE TABLE IF NOT EXISTS payment_methods(
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            bankName TEXT,
            accountNumber TEXT,
            isActive INTEGER DEFAULT 1,
            "order" INTEGER DEFAULT 0,
            createdAt INTEGER,
            updatedAt INTEGER
          )
        ''');
        // ALTER TABLE untuk device yang sudah punya tabel lama tanpa kolom baru
        final pmCols = await db.rawQuery('PRAGMA table_info(payment_methods)');
        final pmColNames = pmCols.map((c) => c['name'] as String).toSet();
        if (!pmColNames.contains('order')) {
          await db.execute('ALTER TABLE payment_methods ADD COLUMN "order" INTEGER DEFAULT 0');
          debugPrint('DB onOpen: added payment_methods.order');
        }
        if (!pmColNames.contains('accountNumber')) {
          await db.execute('ALTER TABLE payment_methods ADD COLUMN accountNumber TEXT');
          debugPrint('DB onOpen: added payment_methods.accountNumber');
        }
        if (!pmColNames.contains('bankName')) {
          await db.execute('ALTER TABLE payment_methods ADD COLUMN bankName TEXT');
          debugPrint('DB onOpen: added payment_methods.bankName');
        }
        if (!pmColNames.contains('createdAt')) {
          await db.execute('ALTER TABLE payment_methods ADD COLUMN createdAt INTEGER');
          debugPrint('DB onOpen: added payment_methods.createdAt');
        }
        if (!pmColNames.contains('updatedAt')) {
          await db.execute('ALTER TABLE payment_methods ADD COLUMN updatedAt INTEGER');
          debugPrint('DB onOpen: added payment_methods.updatedAt');
        }
        if (!pmColNames.contains('isDeleted')) {
          await db.execute('ALTER TABLE payment_methods ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');
          debugPrint('DB onOpen: added payment_methods.isDeleted');
        }
        debugPrint('DB onOpen: payment_methods table ensured');
      },
    );
  }

  /// Create tables on first run
  Future<void> _onCreate(Database db, int version) async {
    await _createTransactionsTable(db);
    await _createBillsTable(db);
    await _createCustodyTable(db);
    await _createCustodyMovementsTable(db);
    await _createPaymentMethodsTable(db);
    await _createPendingOperationsTable(db);
    await _createSyncLogTable(db);
    await _createCategoriesTable(db);
    await _createSpendingLimitsTable(db);
    await _createMonthlyBudgetsTable(db);
    await _createSavingsPlansTable(db);
    await _createSavingsAllocationsTable(db);
    await _createIndexes(db);
  }

  /// Handle database upgrades — BUG-02 FIX: additive migrations, no drop
  /// Data lokal (offline-only, belum sync ke Firestore) aman saat upgrade versi.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('DatabaseHelper: onUpgrade v$oldVersion→v$newVersion');

    // v1→v2: tabel awal sudah ada dari onCreate
    // v2→v3: tambah categoryId/categoryName ke transactions & bills
    if (oldVersion < 3) {
      final txCols = await db.rawQuery('PRAGMA table_info(transactions)');
      final txColNames = txCols.map((c) => c['name'] as String).toSet();
      if (!txColNames.contains('categoryId')) {
        await db.execute('ALTER TABLE transactions ADD COLUMN categoryId TEXT');
      }
      if (!txColNames.contains('categoryName')) {
        await db.execute('ALTER TABLE transactions ADD COLUMN categoryName TEXT');
      }

      final billCols = await db.rawQuery('PRAGMA table_info(bills)');
      final billColNames = billCols.map((c) => c['name'] as String).toSet();
      if (!billColNames.contains('type')) {
        await db.execute("ALTER TABLE bills ADD COLUMN type TEXT NOT NULL DEFAULT 'HUTANG'");
      }
      if (!billColNames.contains('isDeleted')) {
        await db.execute('ALTER TABLE bills ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');
      }
      if (!billColNames.contains('categoryId')) {
        await db.execute('ALTER TABLE bills ADD COLUMN categoryId TEXT');
      }
      if (!billColNames.contains('categoryName')) {
        await db.execute('ALTER TABLE bills ADD COLUMN categoryName TEXT');
      }
    }

    // v3→v4: tambah isDeleted ke custody
    if (oldVersion < 4) {
      final custodyCols = await db.rawQuery('PRAGMA table_info(custody)');
      final custodyColNames = custodyCols.map((c) => c['name'] as String).toSet();
      if (!custodyColNames.contains('isDeleted')) {
        await db.execute('ALTER TABLE custody ADD COLUMN isDeleted INTEGER NOT NULL DEFAULT 0');
      }
    }

    // v4→v10: tabel baru (CREATE IF NOT EXISTS aman untuk tabel yang belum ada)
    if (oldVersion < 10) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories(
          id TEXT PRIMARY KEY,
          firebaseDocId TEXT,
          userId TEXT NOT NULL,
          name TEXT NOT NULL,
          icon TEXT NOT NULL,
          color INTEGER NOT NULL,
          isPreset INTEGER DEFAULT 0,
          isActive INTEGER DEFAULT 1,
          isSynced INTEGER DEFAULT 0,
          syncedAt INTEGER,
          localCreatedAt INTEGER NOT NULL,
          updatedAt INTEGER,
          isDeleted INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS spending_limits(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          categoryId TEXT,
          categoryName TEXT,
          categoryIcon TEXT,
          dailyLimit INTEGER NOT NULL,
          warningThreshold REAL DEFAULT 0.8,
          isActive INTEGER DEFAULT 1,
          firebaseDocId TEXT,
          isSynced INTEGER DEFAULT 0,
          syncedAt INTEGER,
          localCreatedAt INTEGER NOT NULL,
          updatedAt INTEGER,
          isDeleted INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS monthly_budgets(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          yearMonth TEXT NOT NULL,
          categoryId TEXT NOT NULL,
          categoryName TEXT NOT NULL,
          categoryIcon TEXT NOT NULL,
          budgetAmount INTEGER NOT NULL,
          notes TEXT,
          firebaseDocId TEXT,
          isSynced INTEGER DEFAULT 0,
          syncedAt INTEGER,
          localCreatedAt INTEGER NOT NULL,
          updatedAt INTEGER,
          isDeleted INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_plans(
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          icon TEXT,
          targetAmount INTEGER NOT NULL,
          savedAmount INTEGER DEFAULT 0,
          monthlyTarget INTEGER DEFAULT 0,
          targetDate INTEGER,
          isActive INTEGER DEFAULT 1,
          firebaseDocId TEXT,
          isSynced INTEGER DEFAULT 0,
          syncedAt INTEGER,
          localCreatedAt INTEGER NOT NULL,
          updatedAt INTEGER,
          isDeleted INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_allocations(
          id TEXT PRIMARY KEY,
          savingsPlanId TEXT NOT NULL,
          userId TEXT NOT NULL,
          amount INTEGER NOT NULL,
          fromPaymentMethodId TEXT NOT NULL,
          fromPaymentMethodName TEXT NOT NULL,
          toPaymentMethodId TEXT,
          toPaymentMethodName TEXT,
          transferFee INTEGER DEFAULT 0,
          notes TEXT,
          date INTEGER NOT NULL,
          firebaseDocId TEXT,
          isSynced INTEGER DEFAULT 0,
          syncedAt INTEGER,
          localCreatedAt INTEGER NOT NULL,
          isDeleted INTEGER DEFAULT 0
        )
      ''');
    }

    debugPrint('DatabaseHelper: onUpgrade v$oldVersion→v$newVersion done (data preserved)');
  }

  /// Create transactions table
  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        userId TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        paymentMethodId TEXT NOT NULL,
        paymentMethodName TEXT NOT NULL,
        nominal INTEGER NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT,
        categoryId TEXT,
        categoryName TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create bills table
  Future<void> _createBillsTable(Database db) async {
    await db.execute('''
      CREATE TABLE bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        nominal INTEGER NOT NULL,
        paidAmount INTEGER DEFAULT 0,
        dueDate INTEGER NOT NULL,
        status TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'HUTANG',
        category TEXT,
        categoryId TEXT,
        categoryName TEXT,
        notes TEXT,
        paymentMethodId TEXT,
        paymentMethodName TEXT,
        transferFee INTEGER NOT NULL DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create custody table
  Future<void> _createCustodyTable(Database db) async {
    await db.execute('''
      CREATE TABLE custody(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        userId TEXT NOT NULL,
        depositorName TEXT NOT NULL,
        description TEXT,
        totalNominal INTEGER NOT NULL,
        type TEXT NOT NULL,
        currentBalance INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create custody_movements table
  Future<void> _createCustodyMovementsTable(Database db) async {
    await db.execute('''
      CREATE TABLE custody_movements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        custodyId INTEGER NOT NULL,
        custodyFirebaseDocId TEXT,
        movementType TEXT NOT NULL,
        nominal INTEGER NOT NULL,
        transferFee INTEGER NOT NULL DEFAULT 0,
        date INTEGER NOT NULL,
        description TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        isDeleted INTEGER DEFAULT 0,
        FOREIGN KEY (custodyId) REFERENCES custody(id) ON DELETE CASCADE
      )
    ''');
  }

  /// Create payment_methods table
  Future<void> _createPaymentMethodsTable(Database db) async {
    await db.execute('''
      CREATE TABLE payment_methods(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseDocId TEXT UNIQUE,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        bankName TEXT,
        accountNumber TEXT,
        isActive INTEGER DEFAULT 1,
        orderIndex INTEGER DEFAULT 0,
        currentBalance INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER
      )
    ''');
  }

  /// Create pending_operations table (untuk queue sync)
  Future<void> _createPendingOperationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE pending_operations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        tableName TEXT NOT NULL,
        recordId INTEGER NOT NULL,
        firebaseDocId TEXT,
        data TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        retryCount INTEGER DEFAULT 0,
        status TEXT DEFAULT 'PENDING',
        error TEXT
      )
    ''');
  }

  /// Create savings_plans table
  Future<void> _createSavingsPlansTable(Database db) async {
    await db.execute('''
      CREATE TABLE savings_plans(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        targetAmount INTEGER NOT NULL,
        savedAmount INTEGER DEFAULT 0,
        monthlyTarget INTEGER DEFAULT 0,
        targetDate INTEGER,
        isActive INTEGER DEFAULT 1,
        firebaseDocId TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create savings_allocations table
  Future<void> _createSavingsAllocationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE savings_allocations(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        savingsPlanId TEXT NOT NULL,
        amount INTEGER NOT NULL,
        notes TEXT,
        date INTEGER NOT NULL,
        fromPaymentMethodId TEXT NOT NULL DEFAULT '',
        fromPaymentMethodName TEXT NOT NULL DEFAULT '',
        toPaymentMethodId TEXT,
        toPaymentMethodName TEXT,
        transferFee INTEGER NOT NULL DEFAULT 0,
        firebaseDocId TEXT,
        isSynced INTEGER DEFAULT 0,
        localCreatedAt INTEGER NOT NULL,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create monthly_budgets table
  Future<void> _createMonthlyBudgetsTable(Database db) async {
    await db.execute('''
      CREATE TABLE monthly_budgets(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        yearMonth TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        categoryIcon TEXT NOT NULL,
        budgetAmount INTEGER NOT NULL,
        notes TEXT,
        firebaseDocId TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create spending_limits table
  Future<void> _createSpendingLimitsTable(Database db) async {
    await db.execute('''
      CREATE TABLE spending_limits(
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        categoryId TEXT,
        categoryName TEXT,
        categoryIcon TEXT,
        dailyLimit INTEGER NOT NULL,
        warningThreshold REAL DEFAULT 0.8,
        isActive INTEGER DEFAULT 1,
        firebaseDocId TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create categories table
  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE categories(
        id TEXT PRIMARY KEY,
        firebaseDocId TEXT,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        isPreset INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
        updatedAt INTEGER,
        isDeleted INTEGER DEFAULT 0
      )
    ''');
  }

  /// Create sync_log table (untuk audit trail)
  Future<void> _createSyncLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE sync_log(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        entityType TEXT NOT NULL,
        entityId INTEGER,
        firebaseDocId TEXT,
        status TEXT NOT NULL,
        error TEXT,
        localCreatedAt INTEGER NOT NULL,
        syncedAt INTEGER
      )
    ''');
  }

  /// Create indexes untuk performance
  Future<void> _createIndexes(Database db) async {
    // Transactions indexes
    await db.execute(
        'CREATE INDEX idx_transactions_isSynced ON transactions(isSynced)');
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute(
        'CREATE INDEX idx_transactions_category ON transactions(category)');
    await db.execute(
        'CREATE INDEX idx_transactions_paymentMethodId ON transactions(paymentMethodId)');
    await db.execute(
        'CREATE INDEX idx_transactions_userId ON transactions(userId)');

    // Bills indexes
    await db.execute('CREATE INDEX idx_bills_isSynced ON bills(isSynced)');
    await db.execute('CREATE INDEX idx_bills_dueDate ON bills(dueDate)');
    await db.execute('CREATE INDEX idx_bills_status ON bills(status)');
    await db.execute('CREATE INDEX idx_bills_userId ON bills(userId)');

    // Custody indexes
    await db.execute('CREATE INDEX idx_custody_isSynced ON custody(isSynced)');
    await db.execute('CREATE INDEX idx_custody_userId ON custody(userId)');

    // Custody movements indexes
    await db.execute(
        'CREATE INDEX idx_custody_movements_custodyId ON custody_movements(custodyId)');
    await db.execute(
        'CREATE INDEX idx_custody_movements_date ON custody_movements(date)');

    // Payment methods indexes
    await db.execute(
        'CREATE INDEX idx_payment_methods_userId ON payment_methods(userId)');
    await db.execute(
        'CREATE INDEX idx_payment_methods_isActive ON payment_methods(isActive)');

    // Pending operations indexes
    await db.execute(
        'CREATE INDEX idx_pending_operations_status ON pending_operations(status)');
    await db.execute(
        'CREATE INDEX idx_pending_operations_timestamp ON pending_operations(timestamp)');

    // Categories indexes
    await db.execute(
        'CREATE INDEX idx_categories_userId ON categories(userId)');
    await db.execute(
        'CREATE INDEX idx_categories_isPreset ON categories(isPreset)');
    await db.execute(
        'CREATE INDEX idx_categories_isDeleted ON categories(isDeleted)');

    // Spending limits indexes
    await db.execute(
        'CREATE INDEX idx_spending_limits_userId ON spending_limits(userId)');
    await db.execute(
        'CREATE INDEX idx_spending_limits_categoryId ON spending_limits(categoryId)');
    await db.execute(
        'CREATE INDEX idx_spending_limits_isActive ON spending_limits(isActive)');

    // Monthly budgets indexes
    await db.execute(
        'CREATE INDEX idx_monthly_budgets_userId ON monthly_budgets(userId)');
    await db.execute(
        'CREATE INDEX idx_monthly_budgets_yearMonth ON monthly_budgets(yearMonth)');
    await db.execute(
        'CREATE INDEX idx_monthly_budgets_categoryId ON monthly_budgets(categoryId)');

    // Savings plans indexes
    await db.execute(
        'CREATE INDEX idx_savings_plans_userId ON savings_plans(userId)');
    await db.execute(
        'CREATE INDEX idx_savings_allocations_planId ON savings_allocations(savingsPlanId)');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (for testing/reset)
  Future<void> deleteDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'financial_app.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  /// Get database path (for debugging)
  Future<String> getDatabasePath() async {
    final databasePath = await getDatabasesPath();
    return join(databasePath, 'financial_app.db');
  }

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    final path = await getDatabasePath();
    final file = await databaseFactory.databaseExists(path);
    if (!file) return 0;

    // Note: Actual file size would require dart:io
    // This is a placeholder
    return 0;
  }

  /// Vacuum database (optimize storage)
  Future<void> vacuum() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  /// Get all table names
  Future<List<String>> getTableNames() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// Get table row count
  Future<int> getTableRowCount(String tableName) async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get database info (for debugging)
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final tables = await getTableNames();
    final info = <String, dynamic>{
      'path': await getDatabasePath(),
      'version': (await database).getVersion(),
      'tables': <String, int>{},
    };

    for (final table in tables) {
      if (!table.startsWith('sqlite_')) {
        info['tables'][table] = await getTableRowCount(table);
      }
    }

    return info;
  }
}

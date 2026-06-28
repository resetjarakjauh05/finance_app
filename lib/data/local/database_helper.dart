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
      version: 6,
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

        // Ensure custody_movements table has custodyFirebaseDocId
        final movCols = await db.rawQuery('PRAGMA table_info(custody_movements)');
        final movColNames = movCols.map((c) => c['name'] as String).toSet();
        if (!movColNames.contains('custodyFirebaseDocId')) {
          await db.execute(
            "ALTER TABLE custody_movements ADD COLUMN custodyFirebaseDocId TEXT",
          );
          debugPrint('DB onOpen: added custody_movements.custodyFirebaseDocId');
        }
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
    await _createIndexes(db);
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop all tables and recreate — safest approach for development
    await db.execute('DROP TABLE IF EXISTS transactions');
    await db.execute('DROP TABLE IF EXISTS bills');
    await db.execute('DROP TABLE IF EXISTS custody');
    await db.execute('DROP TABLE IF EXISTS custody_movements');
    await db.execute('DROP TABLE IF EXISTS payment_methods');
    await db.execute('DROP TABLE IF EXISTS pending_operations');
    await db.execute('DROP TABLE IF EXISTS sync_log');
    await db.execute('DROP TABLE IF EXISTS categories');
    await _onCreate(db, newVersion);
    debugPrint('DatabaseHelper: onUpgrade v$oldVersion→v$newVersion done');
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
        notes TEXT,
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
        date INTEGER NOT NULL,
        description TEXT,
        isSynced INTEGER DEFAULT 0,
        syncedAt INTEGER,
        localCreatedAt INTEGER NOT NULL,
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

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:financial_app/data/local/database_helper.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper();
    });

    tearDown(() async {
      await dbHelper.deleteDatabase();
    });

    test('Database should initialize successfully', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('Database should have all required tables', () async {
      final tables = await dbHelper.getTableNames();
      
      expect(tables.contains('transactions'), true);
      expect(tables.contains('bills'), true);
      expect(tables.contains('custody'), true);
      expect(tables.contains('custody_movements'), true);
      expect(tables.contains('payment_methods'), true);
      expect(tables.contains('pending_operations'), true);
      expect(tables.contains('sync_log'), true);
    });

    test('Tables should be empty initially', () async {
      final transactionsCount = await dbHelper.getTableRowCount('transactions');
      final billsCount = await dbHelper.getTableRowCount('bills');
      final custodyCount = await dbHelper.getTableRowCount('custody');
      
      expect(transactionsCount, 0);
      expect(billsCount, 0);
      expect(custodyCount, 0);
    });

    test('Database info should be retrievable', () async {
      final info = await dbHelper.getDatabaseInfo();
      
      expect(info['path'], isNotNull);
      expect(info['tables'], isNotNull);
      expect(info['tables'] is Map, true);
    });
  });
}

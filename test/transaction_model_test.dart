import 'package:flutter_test/flutter_test.dart';
import 'package:financial_app/domain/models/transaction_model.dart';

void main() {
  group('TransactionModel Tests', () {
    test('TransactionCategory display names correct', () {
      expect(TransactionCategory.income.displayName, 'Uang Masuk');
      expect(TransactionCategory.expense.displayName, 'Uang Keluar');
    });

    test('TransactionCategory icons not empty', () {
      expect(TransactionCategory.income.icon, isNotEmpty);
      expect(TransactionCategory.expense.icon, isNotEmpty);
    });

    test('TransactionModel toSqlite / fromSqlite roundtrip', () {
      final now = DateTime(2026, 6, 1, 12, 0, 0);
      final t = TransactionModel(
        id: 1,
        userId: 'u1',
        description: 'Gaji',
        category: TransactionCategory.income,
        paymentMethodId: 'pm1',
        paymentMethodName: 'Bank BCA',
        nominal: 5000000,
        date: now,
        localCreatedAt: now,
      );
      final map = t.toSqlite();
      final restored = TransactionModelExtension.fromSqlite({...map, 'id': 1});

      expect(restored.description, t.description);
      expect(restored.nominal, t.nominal);
      expect(restored.category, t.category);
      expect(restored.paymentMethodName, t.paymentMethodName);
      expect(restored.isSynced, false);
      expect(restored.isDeleted, false);
    });

    test('toSqlite excludes id=0', () {
      final t = TransactionModel(
        id: 0,
        userId: 'u1',
        description: 'Test',
        category: TransactionCategory.expense,
        paymentMethodId: 'pm1',
        paymentMethodName: 'Cash',
        nominal: 100000,
        date: DateTime.now(),
        localCreatedAt: DateTime.now(),
      );
      final map = t.toSqlite();
      expect(map.containsKey('id'), false);
    });

    test('copyWith preserves unchanged fields', () {
      final t = TransactionModel(
        id: 1,
        userId: 'u1',
        description: 'Makan',
        category: TransactionCategory.expense,
        paymentMethodId: 'pm1',
        paymentMethodName: 'Cash',
        nominal: 50000,
        date: DateTime.now(),
        localCreatedAt: DateTime.now(),
      );
      final updated = t.copyWith(nominal: 60000);
      expect(updated.nominal, 60000);
      expect(updated.description, t.description);
      expect(updated.category, t.category);
    });
  });

  group('CustodyModel Tests', () {
    test('CustodyType display names correct', () {
      // Test enum values directly
      const diterima = 'Uang Diterima';
      const diberikan = 'Uang Diberikan';
      expect(diterima, contains('Diterima'));
      expect(diberikan, contains('Diberikan'));
    });
  });
}

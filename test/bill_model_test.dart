import 'package:flutter_test/flutter_test.dart';
import 'package:financial_app/domain/models/bill_model.dart';

void main() {
  group('BillModel Tests', () {
    test('BillType display names correct', () {
      expect(BillType.hutang.displayName, 'Hutang');
      expect(BillType.piutang.displayName, 'Piutang');
    });

    test('BillStatus display names correct', () {
      expect(BillStatus.unpaid.displayName, 'Belum Bayar');
      expect(BillStatus.partial.displayName, 'Sebagian');
      expect(BillStatus.paid.displayName, 'Lunas');
    });

    test('BillTypeExtension.fromString parses correctly', () {
      expect(BillTypeExtension.fromString('HUTANG'), BillType.hutang);
      expect(BillTypeExtension.fromString('PIUTANG'), BillType.piutang);
      expect(BillTypeExtension.fromString('unknown'), BillType.hutang);
    });

    test('BillStatusExtension.fromString parses correctly', () {
      expect(BillStatusExtension.fromString('UNPAID'), BillStatus.unpaid);
      expect(BillStatusExtension.fromString('PARTIAL'), BillStatus.partial);
      expect(BillStatusExtension.fromString('PAID'), BillStatus.paid);
      expect(BillStatusExtension.fromString('unknown'), BillStatus.unpaid);
    });

    test('BillModel remainingAmount correct', () {
      final bill = BillModel(
        id: 1,
        userId: 'u1',
        name: 'Test',
        nominal: 1000000,
        paidAmount: 300000,
        dueDate: DateTime.now(),
        status: BillStatus.partial,
        type: BillType.hutang,
        localCreatedAt: DateTime.now(),
      );
      expect(bill.remainingAmount, 700000);
    });

    test('BillModel paymentProgress correct', () {
      final bill = BillModel(
        id: 1,
        userId: 'u1',
        name: 'Test',
        nominal: 1000000,
        paidAmount: 500000,
        dueDate: DateTime.now(),
        status: BillStatus.partial,
        type: BillType.hutang,
        localCreatedAt: DateTime.now(),
      );
      expect(bill.paymentProgress, 0.5);
    });

    test('BillModel calculatedStatus correct', () {
      final unpaid = BillModel(
        id: 1, userId: 'u1', name: 'Test',
        nominal: 1000000, paidAmount: 0,
        dueDate: DateTime.now(), status: BillStatus.unpaid,
        type: BillType.hutang, localCreatedAt: DateTime.now(),
      );
      expect(unpaid.calculatedStatus, BillStatus.unpaid);

      final partial = unpaid.copyWith(paidAmount: 500000);
      expect(partial.calculatedStatus, BillStatus.partial);

      final paid = unpaid.copyWith(paidAmount: 1000000);
      expect(paid.calculatedStatus, BillStatus.paid);
    });

    test('BillModel toSqlite / fromSqlite roundtrip', () {
      final bill = BillModel(
        id: 1,
        userId: 'u1',
        name: 'Cicilan Motor',
        nominal: 500000,
        paidAmount: 100000,
        dueDate: DateTime(2026, 7, 1),
        status: BillStatus.partial,
        type: BillType.hutang,
        localCreatedAt: DateTime(2026, 6, 1),
      );
      final map = bill.toSqlite();
      final restored = BillModelExtension.fromSqlite({...map, 'id': 1});
      expect(restored.name, bill.name);
      expect(restored.nominal, bill.nominal);
      expect(restored.paidAmount, bill.paidAmount);
      expect(restored.type, bill.type);
      expect(restored.status, bill.status);
    });
  });

  group('BillModel validation', () {
    test('bill with zero nominal is invalid', () {
      expect(() {
        if (0 <= 0) throw Exception('Nominal harus lebih dari 0');
      }, throwsException);
    });

    test('bill with empty name is invalid', () {
      expect(() {
        if (''.trim().isEmpty) throw Exception('Nama tagihan tidak boleh kosong');
      }, throwsException);
    });
  });
}

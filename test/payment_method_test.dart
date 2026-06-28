import 'package:flutter_test/flutter_test.dart';
import 'package:financial_app/domain/models/payment_method_model.dart';

void main() {
  group('PaymentMethodModel Tests', () {
    test('PaymentMethodType should have correct display names', () {
      expect(PaymentMethodType.cash.displayName, 'Tunai');
      expect(PaymentMethodType.bank.displayName, 'Bank');
      expect(PaymentMethodType.wallet.displayName, 'Dompet Digital');
      expect(PaymentMethodType.digital.displayName, 'Digital');
    });

    test('PaymentMethodType should have icons', () {
      expect(PaymentMethodType.cash.icon, isNotEmpty);
      expect(PaymentMethodType.bank.icon, isNotEmpty);
      expect(PaymentMethodType.wallet.icon, isNotEmpty);
      expect(PaymentMethodType.digital.icon, isNotEmpty);
    });

    test('PaymentMethodModel should create valid instance', () {
      final method = PaymentMethodModel(
        id: 'test-id',
        userId: 'user-123',
        name: 'Bank BCA',
        type: PaymentMethodType.bank,
        bankName: 'BCA',
        isActive: true,
        order: 0,
      );

      expect(method.id, 'test-id');
      expect(method.userId, 'user-123');
      expect(method.name, 'Bank BCA');
      expect(method.type, PaymentMethodType.bank);
      expect(method.bankName, 'BCA');
      expect(method.isActive, true);
      expect(method.order, 0);
    });

    test('PaymentMethodModel default values should work', () {
      final method = PaymentMethodModel(
        id: 'test-id',
        userId: 'user-123',
        name: 'Tunai',
        type: PaymentMethodType.cash,
      );

      expect(method.isActive, true); // default
      expect(method.order, 0); // default
      expect(method.bankName, null);
      expect(method.accountNumber, null);
    });
  });
}

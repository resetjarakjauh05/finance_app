import 'package:flutter/services.dart';

/// Formatter yg menampilkan angka dengan titik ribuan saat user mengetik.
/// Contoh: user ketik "1000000" → tampil "1.000.000"
/// Saat save, strip titik → int.parse(controller.text.replaceAll('.', ''))
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final _digitOnly = RegExp(r'[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip semua non-digit
    final digits = newValue.text.replaceAll(_digitOnly, '');

    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Format dengan titik ribuan
    final formatted = formatWithDots(digits);

    // Posisi cursor di akhir
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatWithDots(String digits) {
    final buffer = StringBuffer();
    final length = digits.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Helper: parse nilai dari controller yg sudah diformat
  static int parseValue(String formattedText) {
    final digits = formattedText.replaceAll('.', '');
    return int.tryParse(digits) ?? 0;
  }
}

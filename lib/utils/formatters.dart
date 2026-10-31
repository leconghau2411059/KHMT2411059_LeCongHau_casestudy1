import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 1500000 -> "1.500.000"
String formatMoney(int value) {
  final s = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// 1500000 -> "1.500.000 đ"
String formatCurrency(int value) => '${formatMoney(value)} đ';

/// 12/04/2025
String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

/// Tự động thêm dấu chấm ngăn cách hàng nghìn khi nhập số tiền.
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final text = formatMoney(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

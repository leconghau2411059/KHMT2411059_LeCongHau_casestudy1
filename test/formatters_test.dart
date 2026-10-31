import 'package:flutter_test/flutter_test.dart';

import 'package:untitled2/models/transaction_model.dart';
import 'package:untitled2/utils/formatters.dart';

void main() {
  group('formatMoney', () {
    test('ngăn cách hàng nghìn bằng dấu chấm', () {
      expect(formatMoney(0), '0');
      expect(formatMoney(500), '500');
      expect(formatMoney(5000), '5.000');
      expect(formatMoney(8000000), '8.000.000');
      expect(formatMoney(1234567), '1.234.567');
    });

    test('formatCurrency thêm đơn vị đ', () {
      expect(formatCurrency(100000), '100.000 đ');
    });
  });

  group('TransactionModel', () {
    final tx = TransactionModel(
      id: 1,
      isExpense: true,
      category: 'Ăn uống',
      amount: 50000,
      date: DateTime(2024, 9, 3),
      note: 'Ăn trưa',
    );

    test('toMap và fromMap giữ nguyên dữ liệu', () {
      final copy = TransactionModel.fromMap(tx.toMap());
      expect(copy.id, 1);
      expect(copy.isExpense, true);
      expect(copy.category, 'Ăn uống');
      expect(copy.amount, 50000);
      expect(copy.date, DateTime(2024, 9, 3));
      expect(copy.note, 'Ăn trưa');
    });

    test('tiêu đề dùng danh mục khi ghi chú trống', () {
      final noNote = TransactionModel(
        isExpense: false,
        category: 'Thưởng',
        amount: 1,
        date: DateTime(2024, 1, 1),
      );
      expect(noNote.title, 'Thưởng');
      expect(tx.title, 'Ăn trưa');
    });

    test('signedAmount: chi tiêu âm, thu nhập dương', () {
      expect(tx.signedAmount, -50000);
      expect(
        TransactionModel(
          isExpense: false,
          category: 'Thu nhập',
          amount: 70,
          date: DateTime(2024, 1, 1),
        ).signedAmount,
        70,
      );
    });
  });
}

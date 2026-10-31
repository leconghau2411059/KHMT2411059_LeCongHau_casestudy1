import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import 'transaction_form_screen.dart';

/// Màn hình tạm của buổi 3 để mở thử 2 màn hình Thêm / Sửa giao dịch.
/// Sang buổi 4 sẽ được thay bằng màn hình Dashboard.
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sample = TransactionModel(
      isExpense: true,
      category: 'Ăn uống',
      amount: 100000,
      date: DateTime(2025, 4, 12),
      note: 'Ăn trưa',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Xem thử màn hình')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TransactionFormScreen()),
              ),
              child: const Text('Thêm giao dịch'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionFormScreen(transaction: sample),
                ),
              ),
              child: const Text('Sửa giao dịch (dữ liệu mẫu)'),
            ),
          ],
        ),
      ),
    );
  }
}

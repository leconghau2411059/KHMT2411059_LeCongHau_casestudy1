import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/categories.dart';
import '../utils/formatters.dart';

/// Một dòng giao dịch trong danh sách (icon danh mục, tiêu đề, ngày, số tiền).
class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = Categories.find(transaction.category);
    final isExpense = transaction.isExpense;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: info.color,
              child: Icon(info.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.category}   ${formatDate(transaction.date)}',
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isExpense ? '-' : '+'}${formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isExpense ? AppColors.expenseText : AppColors.income,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

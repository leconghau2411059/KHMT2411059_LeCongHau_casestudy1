import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_form_screen.dart';

// Dữ liệu mẫu của buổi 4 (buổi 6 sẽ thay bằng dữ liệu đọc từ SQLite).
final List<TransactionModel> _sampleTransactions = [
  TransactionModel(
      isExpense: true,
      category: 'Ăn uống',
      amount: 50000,
      date: DateTime(2024, 9, 3),
      note: 'Ăn trưa'),
  TransactionModel(
      isExpense: true,
      category: 'Di chuyển',
      amount: 100000,
      date: DateTime(2024, 9, 3),
      note: 'Xăng xe'),
  TransactionModel(
      isExpense: false,
      category: 'Thu nhập',
      amount: 8000000,
      date: DateTime(2024, 9, 1),
      note: 'Lương tháng 9'),
  TransactionModel(
      isExpense: true,
      category: 'Mua sắm',
      amount: 300000,
      date: DateTime(2024, 8, 31),
      note: 'Mua sắm'),
  TransactionModel(
      isExpense: true,
      category: 'Giáo dục',
      amount: 500000,
      date: DateTime(2024, 8, 30),
      note: 'Học phí'),
];

/// Nội dung tab "Trang chủ": số dư, tổng thu/chi, giao dịch gần đây.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool hideBalance = false;
  List<TransactionModel> transactions = _sampleTransactions;

  int get totalIncome =>
      transactions.where((t) => !t.isExpense).fold(0, (s, t) => s + t.amount);

  int get totalExpense =>
      transactions.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

  int get balance => totalIncome - totalExpense;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        _buildBalanceCard(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'TỔNG THU NHẬP',
                amount: totalIncome,
                color: AppColors.income,
                background: const Color(0xFFEAF6EC),
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: 'TỔNG CHI TIÊU',
                amount: totalExpense,
                color: AppColors.expenseText,
                background: const Color(0xFFFCEAEA),
                icon: Icons.arrow_upward,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Giao dịch gần đây',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++) ...[
                if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
                TransactionTile(
                  transaction: transactions[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TransactionFormScreen(transaction: transactions[i]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A86F7), Color(0xFF1D61E7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'SỐ DƯ HIỆN TẠI',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              setState(() => hideBalance = !hideBalance),
                          child: Icon(
                            hideBalance
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hideBalance ? '••••••••' : formatCurrency(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white70, size: 64),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(width: 18, active: true),
              _dot(),
              _dot(),
              _dot(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot({double width = 6, bool active = false}) => Container(
        width: width,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white54,
          borderRadius: BorderRadius.circular(3),
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final Color background;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.background,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textGrey),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatCurrency(amount),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

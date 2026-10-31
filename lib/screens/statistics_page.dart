import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../utils/app_colors.dart';
import '../utils/categories.dart';
import '../utils/formatters.dart';

/// Tab "Thống kê": chi tiêu theo từng danh mục.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _db = DatabaseHelper.instance;
  List<({String category, int total})> rows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _db.changes.addListener(_load);
  }

  @override
  void dispose() {
    _db.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _db.getExpenseByCategory();
    if (!mounted) return;
    setState(() {
      rows = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rows.isEmpty) {
      return const Center(
        child: Text('Chưa có dữ liệu chi tiêu để thống kê',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }

    final total = rows.fold<int>(0, (s, r) => s + r.total);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        const Text('Chi tiêu theo danh mục',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text('Tổng chi tiêu: ${formatCurrency(total)}',
            style: const TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 16),
        for (final r in rows) _row(r.category, r.total, total),
      ],
    );
  }

  Widget _row(String category, int amount, int total) {
    final info = Categories.find(category);
    final percent = total == 0 ? 0.0 : amount / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: info.color,
                child: Icon(info.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(category,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(formatCurrency(amount),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    color: info.color,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 40,
                child: Text('${(percent * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

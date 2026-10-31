import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_form_screen.dart';

enum _Filter { all, expense, income }

/// Tab "Giao dịch": toàn bộ giao dịch, lọc theo loại, vuốt để xóa.
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _db = DatabaseHelper.instance;
  List<TransactionModel> all = [];
  bool loading = true;
  _Filter filter = _Filter.all;

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
    final data = await _db.getTransactions();
    if (!mounted) return;
    setState(() {
      all = data;
      loading = false;
    });
  }

  List<TransactionModel> get filtered {
    switch (filter) {
      case _Filter.expense:
        return all.where((t) => t.isExpense).toList();
      case _Filter.income:
        return all.where((t) => !t.isExpense).toList();
      case _Filter.all:
        return all;
    }
  }

  Future<bool> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa',
                style: TextStyle(color: AppColors.expenseText)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              _chip('Tất cả', _Filter.all),
              const SizedBox(width: 8),
              _chip('Chi tiêu', _Filter.expense),
              const SizedBox(width: 8),
              _chip('Thu nhập', _Filter.income),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('Không có giao dịch nào',
                      style: TextStyle(color: AppColors.textGrey)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final tx = items[i];
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(),
                      onDismissed: (_) {
                        // Gỡ khỏi danh sách ngay để Dismissible không bị treo.
                        setState(() => all.removeWhere((t) => t.id == tx.id));
                        _db.delete(tx.id!);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.expenseText,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child:
                            const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: TransactionTile(
                          transaction: tx,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TransactionFormScreen(transaction: tx),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, _Filter value) {
    return ChoiceChip(
      label: Text(label),
      selected: filter == value,
      onSelected: (_) => setState(() => filter = value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: filter == value ? Colors.white : AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
      showCheckmark: false,
    );
  }
}

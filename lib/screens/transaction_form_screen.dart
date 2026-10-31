import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../db/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/categories.dart';
import '../utils/formatters.dart';

/// Màn hình dùng chung cho "Thêm giao dịch" (transaction == null)
/// và "Sửa giao dịch" (truyền transaction cần sửa).
class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  bool get isEdit => transaction != null;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late bool isExpense;
  late String selectedCategory;
  late DateTime selectedDate;
  late final TextEditingController amountController;
  late final TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    isExpense = t?.isExpense ?? true;
    selectedCategory = t?.category ?? Categories.listFor(isExpense).first.name;
    selectedDate = t?.date ?? DateTime.now();
    amountController =
        TextEditingController(text: t == null ? '' : formatMoney(t.amount));
    noteController = TextEditingController(text: t?.note ?? '');
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _setType(bool expense) {
    if (expense == isExpense) return;
    setState(() {
      isExpense = expense;
      selectedCategory = Categories.listFor(expense).first.name;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  /// Kiểm tra dữ liệu và tạo đối tượng giao dịch; trả về null nếu không hợp lệ.
  TransactionModel? _buildTransaction() {
    final digits = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = digits.isEmpty ? 0 : int.parse(digits);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền lớn hơn 0')),
      );
      return null;
    }
    return TransactionModel(
      id: widget.transaction?.id,
      isExpense: isExpense,
      category: selectedCategory,
      amount: amount,
      date: selectedDate,
      note: noteController.text.trim(),
    );
  }

  Future<void> _save() async {
    final tx = _buildTransaction();
    if (tx == null) return;
    final db = DatabaseHelper.instance;
    if (widget.isEdit) {
      await db.update(tx);
    } else {
      await db.insert(tx);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEdit
            ? 'Đã cập nhật giao dịch'
            : 'Đã thêm giao dịch'),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final categories = Categories.listFor(isExpense);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Chi tiêu / Thu nhập
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _typeTab('Chi tiêu', true),
                  _typeTab('Thu nhập', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Danh mục
            _label('Danh mục'),
            InputDecorator(
              decoration: _decoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCategory,
                  items: categories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.name,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(c.icon, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(c.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedCategory = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Số tiền
            _label('Số tiền'),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
                ThousandsSeparatorFormatter(),
              ],
              decoration: _decoration(hint: 'Nhập số tiền', suffixText: 'đ'),
            ),
            const SizedBox(height: 20),

            // Ngày giao dịch
            _label('Ngày giao dịch'),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickDate,
              child: InputDecorator(
                decoration: _decoration(
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(formatDate(selectedDate)),
              ),
            ),
            const SizedBox(height: 20),

            // Ghi chú
            _label('Ghi chú'),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: _decoration(hint: 'Nhập ghi chú (tùy chọn)'),
            ),
            const SizedBox(height: 32),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeTab(String text, bool forExpense) {
    final selected = isExpense == forExpense;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setType(forExpense),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.expense : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      );

  InputDecoration _decoration(
      {String? hint, String? suffixText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}

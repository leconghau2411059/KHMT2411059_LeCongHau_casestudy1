class TransactionModel {
  final int? id;
  final bool isExpense; // true: chi tiêu, false: thu nhập
  final String category;
  final int amount; // luôn dương, dấu do isExpense quyết định
  final DateTime date;
  final String note;

  const TransactionModel({
    this.id,
    required this.isExpense,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });

  /// Tiêu đề hiển thị: ưu tiên ghi chú, nếu trống thì dùng tên danh mục.
  String get title => note.trim().isEmpty ? category : note.trim();

  /// Số tiền có dấu: chi tiêu âm, thu nhập dương.
  int get signedAmount => isExpense ? -amount : amount;
}

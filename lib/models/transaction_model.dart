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

  /// Chuyển sang dòng dữ liệu để lưu vào SQLite.
  Map<String, Object?> toMap() => {
        'id': id,
        'type': isExpense ? 'expense' : 'income',
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  /// Tạo đối tượng từ một dòng đọc ra từ SQLite.
  factory TransactionModel.fromMap(Map<String, Object?> map) {
    return TransactionModel(
      id: map['id'] as int?,
      isExpense: map['type'] == 'expense',
      category: map['category'] as String,
      amount: map['amount'] as int,
      date: DateTime.parse(map['date'] as String),
      note: (map['note'] as String?) ?? '',
    );
  }

  /// Tiêu đề hiển thị: ưu tiên ghi chú, nếu trống thì dùng tên danh mục.
  String get title => note.trim().isEmpty ? category : note.trim();

  /// Số tiền có dấu: chi tiêu âm, thu nhập dương.
  int get signedAmount => isExpense ? -amount : amount;
}

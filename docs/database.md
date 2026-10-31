# Thiết kế cơ sở dữ liệu (SQLite)

File database: `expense_manager.db` (tạo tự động trong lần chạy đầu tiên).

## Bảng `transactions`

| Cột        | Kiểu    | Ràng buộc                                   | Ý nghĩa                                   |
|------------|---------|---------------------------------------------|-------------------------------------------|
| `id`       | INTEGER | PRIMARY KEY AUTOINCREMENT                   | Mã giao dịch                              |
| `type`     | TEXT    | NOT NULL, chỉ nhận `expense` / `income`     | Loại: chi tiêu hoặc thu nhập              |
| `category` | TEXT    | NOT NULL                                    | Tên danh mục (Ăn uống, Di chuyển, ...)    |
| `amount`   | INTEGER | NOT NULL, `amount > 0`                      | Số tiền (VND), luôn dương                 |
| `date`     | TEXT    | NOT NULL                                    | Ngày giao dịch, định dạng ISO 8601        |
| `note`     | TEXT    | NOT NULL, mặc định `''`                     | Ghi chú (dùng làm tiêu đề khi hiển thị)   |

Index: `idx_transactions_date` trên cột `date` để sắp xếp / lọc theo ngày nhanh hơn.

## Quy ước

- Số tiền lưu dạng số nguyên dương; dấu âm/dương trên giao diện được suy ra từ `type`.
- `date` lưu chuỗi ISO 8601 nên so sánh chuỗi cũng chính là so sánh thời gian.
- Danh mục lưu theo tên; icon và màu của danh mục được định nghĩa trong `lib/utils/categories.dart`.

## Các thao tác (`lib/db/database_helper.dart`)

| Hàm                  | Mô tả                                     |
|----------------------|-------------------------------------------|
| `insert(tx)`         | Thêm giao dịch                            |
| `update(tx)`         | Sửa giao dịch theo `id`                   |
| `delete(id)`         | Xóa giao dịch                             |
| `getTransactions()`  | Lấy danh sách, mới nhất trước             |

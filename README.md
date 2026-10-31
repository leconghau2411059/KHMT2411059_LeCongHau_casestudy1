# Expense Manager – Case Study 1

- **MSSV:** KHMT2411059
- **Họ tên:** Lê Công Hậu
- **Môn học:** Lập trình thiết bị di động (Flutter)

Ứng dụng quản lý thu chi cá nhân, viết bằng Flutter, lưu dữ liệu cục bộ bằng SQLite.

## Chức năng

- Màn hình chào (Welcome) → vào ứng dụng.
- **Trang chủ (Dashboard):** số dư hiện tại (ẩn/hiện), tổng thu nhập, tổng chi tiêu, 5 giao dịch gần đây.
- **Thêm / Sửa giao dịch:** chọn Chi tiêu / Thu nhập, danh mục, số tiền (tự thêm dấu chấm), ngày, ghi chú. Có thể xóa từ màn hình sửa.
- **Giao dịch:** toàn bộ giao dịch, lọc theo loại, vuốt sang trái để xóa.
- **Thống kê:** chi tiêu theo từng danh mục.

## Công nghệ

Flutter · `sqflite` + `path` (SQLite) · `intl` (định dạng ngày).
Thiết kế database xem tại [`docs/database.md`](docs/database.md).

## Cấu trúc thư mục `lib/`

```
lib/
├── main.dart
├── db/database_helper.dart        # SQLite: tạo bảng, CRUD, truy vấn tổng hợp
├── models/transaction_model.dart
├── screens/                       # welcome, home_shell, dashboard, transactions,
│                                  # statistics, transaction_form (thêm + sửa)
├── widgets/transaction_tile.dart
└── utils/                         # màu, danh mục, định dạng tiền / ngày
```

## Chạy ứng dụng

```bash
flutter pub get
flutter run          # chạy trên máy ảo / thiết bị Android
flutter test         # chạy unit test
```

> `sqflite` hỗ trợ Android và iOS; hãy chạy trên máy ảo Android.

## Các nhánh theo buổi

| Nhánh   | Nội dung                                              |
|---------|-------------------------------------------------------|
| `buoi1` | Khởi tạo project Flutter, đưa lên repo                |
| `buoi2` | Màn hình Welcome                                      |
| `buoi3` | Màn hình Thêm giao dịch và Sửa giao dịch              |
| `buoi4` | Màn hình Dashboard                                    |
| `buoi5` | Thiết kế và xây dựng database SQLite                  |
| `buoi6` | Hoàn thiện thêm, sửa và load giao dịch lên Dashboard  |
| `buoi7` | Tổng thu/chi bằng SQL, xóa giao dịch                  |
| `buoi8` | Tab Giao dịch, tab Thống kê, README, unit test        |

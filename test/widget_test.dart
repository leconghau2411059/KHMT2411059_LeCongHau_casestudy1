import 'package:flutter_test/flutter_test.dart';

import 'package:untitled2/main.dart';

void main() {
  testWidgets('Màn hình chào hiển thị tên ứng dụng', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Expense Manager'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}

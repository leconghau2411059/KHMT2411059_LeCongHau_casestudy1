import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'dashboard_page.dart';
import 'statistics_page.dart';
import 'transactions_page.dart';
import 'transaction_form_screen.dart';

/// Khung chính của ứng dụng: AppBar, thanh điều hướng dưới và nút thêm (+).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: const Text(
          'Quản lý thu chi',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          DashboardPage(onSeeAll: () => setState(() => currentIndex = 1)),
          const TransactionsPage(),
          const StatisticsPage(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDark,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: 'Giao dịch'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline), label: 'Thống kê'),
        ],
      ),
    );
  }
}

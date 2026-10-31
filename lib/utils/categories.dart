import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryInfo(this.name, this.icon, this.color);
}

class Categories {
  static const expense = <CategoryInfo>[
    CategoryInfo('Ăn uống', Icons.restaurant, Color(0xFFF97316)),
    CategoryInfo('Di chuyển', Icons.directions_car, Color(0xFF2196F3)),
    CategoryInfo('Mua sắm', Icons.shopping_cart, Color(0xFFA855F7)),
    CategoryInfo('Giáo dục', Icons.school, Color(0xFF0D9488)),
    CategoryInfo('Giải trí', Icons.sports_esports, Color(0xFFEC4899)),
    CategoryInfo('Khác', Icons.more_horiz, Color(0xFF64748B)),
  ];

  static const income = <CategoryInfo>[
    CategoryInfo('Thu nhập', Icons.attach_money, Color(0xFF2E9E3E)),
    CategoryInfo('Thưởng', Icons.card_giftcard, Color(0xFFF59E0B)),
    CategoryInfo('Thu nhập khác', Icons.add_circle_outline, Color(0xFF14B8A6)),
  ];

  static List<CategoryInfo> listFor(bool isExpense) =>
      isExpense ? expense : income;

  static CategoryInfo find(String name) {
    for (final c in [...expense, ...income]) {
      if (c.name == name) return c;
    }
    return expense.last;
  }
}

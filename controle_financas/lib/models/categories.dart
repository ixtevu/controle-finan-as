import 'package:flutter/material.dart';

import 'transaction.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const CategoryInfo(this.name, this.icon, this.color, this.type);
}

const List<CategoryInfo> expenseCategories = [
  CategoryInfo('Alimentação', Icons.restaurant, Color(0xFFEF6C00),
      TransactionType.expense),
  CategoryInfo('Transporte', Icons.directions_bus, Color(0xFF1976D2),
      TransactionType.expense),
  CategoryInfo(
      'Moradia', Icons.home, Color(0xFF6D4C41), TransactionType.expense),
  CategoryInfo(
      'Saúde', Icons.favorite, Color(0xFFD32F2F), TransactionType.expense),
  CategoryInfo(
      'Educação', Icons.school, Color(0xFF7B1FA2), TransactionType.expense),
  CategoryInfo('Lazer', Icons.sports_esports, Color(0xFF00897B),
      TransactionType.expense),
  CategoryInfo('Compras', Icons.shopping_bag, Color(0xFFC2185B),
      TransactionType.expense),
  CategoryInfo(
      'Contas', Icons.receipt_long, Color(0xFF455A64), TransactionType.expense),
  CategoryInfo(
      'Outros', Icons.category, Color(0xFF757575), TransactionType.expense),
];

const List<CategoryInfo> incomeCategories = [
  CategoryInfo(
      'Salário', Icons.payments, Color(0xFF2E7D32), TransactionType.income),
  CategoryInfo(
      'Freelance', Icons.work, Color(0xFF558B2F), TransactionType.income),
  CategoryInfo('Investimentos', Icons.trending_up, Color(0xFF00695C),
      TransactionType.income),
  CategoryInfo('Outras receitas', Icons.add_circle, Color(0xFF9E9D24),
      TransactionType.income),
];

List<CategoryInfo> categoriesFor(TransactionType type) =>
    type == TransactionType.income ? incomeCategories : expenseCategories;

CategoryInfo categoryByName(String name) {
  for (final c in [...expenseCategories, ...incomeCategories]) {
    if (c.name == name) return c;
  }
  return expenseCategories.last;
}

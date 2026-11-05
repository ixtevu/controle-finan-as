import 'package:intl/intl.dart';

final NumberFormat _money = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

String formatMoney(int cents) => _money.format(cents / 100);

String formatCentsForInput(int cents) =>
    (cents / 100).toStringAsFixed(2).replaceAll('.', ',');

/// Converte textos como "1.234,56", "12,5" ou "12.50" em centavos.
int? parseCents(String input) {
  var s = input.trim().replaceAll(' ', '');
  if (s.isEmpty) return null;
  if (s.contains(',')) {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  }
  final value = double.tryParse(s);
  if (value == null) return null;
  return (value * 100).round();
}

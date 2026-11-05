import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../models/transaction.dart';

class FinanceProvider extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  List<FinanceTransaction> _items = [];
  bool _loading = true;
  String? _error;

  DateTime get month => _month;
  List<FinanceTransaction> get items => _items;
  bool get loading => _loading;

  
  String? get error => _error;

  int get incomeCents =>
      _items.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.cents);

  int get expenseCents =>
      _items.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.cents);

  int get balanceCents => incomeCents - expenseCents;

  
  List<MapEntry<String, int>> get expenseByCategory {
    final map = <String, int>{};
    for (final t in _items.where((t) => !t.isIncome)) {
      map[t.category] = (map[t.category] ?? 0) + t.cents;
    }
    final list = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final end = DateTime(_month.year, _month.month + 1);
      _items = await _db.byRange(_month, end);
    } catch (e, st) {
      
      debugPrint('Erro ao carregar lançamentos: $e\n$st');
      _items = [];
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> changeMonth(int delta) async {
    _month = DateTime(_month.year, _month.month + delta);
    await load();
  }

  Future<void> add(FinanceTransaction t) async {
    await _db.insert(t);
    _showMonthOf(t.date);
    await load();
  }

  Future<void> update(FinanceTransaction t) async {
    await _db.update(t);
    _showMonthOf(t.date);
    await load();
  }

  void _showMonthOf(DateTime date) {
    _month = DateTime(date.year, date.month);
  }

  Future<void> remove(int id) async {
    
    _items = _items.where((t) => t.id != id).toList();
    notifyListeners();
    await _db.delete(id);
  }
}

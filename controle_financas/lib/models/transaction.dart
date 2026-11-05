enum TransactionType { income, expense }


class FinanceTransaction {
  final int? id;
  final String description;
  final int cents;
  final DateTime date;
  final TransactionType type;
  final String category;

  const FinanceTransaction({
    this.id,
    required this.description,
    required this.cents,
    required this.date,
    required this.type,
    required this.category,
  });

  bool get isIncome => type == TransactionType.income;

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'description': description,
        'amount_cents': cents,
        'date': date.millisecondsSinceEpoch,
        'type': type.name,
        'category': category,
      };

  factory FinanceTransaction.fromMap(Map<String, Object?> m) {
    return FinanceTransaction(
      id: m['id'] as int?,
      description: m['description'] as String,
      cents: m['amount_cents'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
      type: TransactionType.values.byName(m['type'] as String),
      category: m['category'] as String,
    );
  }
}

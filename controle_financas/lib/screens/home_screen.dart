import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/categories.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/format.dart';
import 'transaction_form_screen.dart';

final Color _green = Colors.green.shade700;
final Color _red = Colors.red.shade700;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openForm(BuildContext context, [FinanceTransaction? t]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TransactionFormScreen(existing: t)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fin = context.watch<FinanceProvider>();
    final monthLabel = toBeginningOfSentenceCase(
      DateFormat('MMMM yyyy', 'pt_BR').format(fin.month),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Finanças'), centerTitle: true),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => fin.changeMonth(-1),
              ),
              SizedBox(
                width: 180,
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => fin.changeMonth(1),
              ),
            ],
          ),
          Expanded(
            child: fin.loading
                ? const Center(child: CircularProgressIndicator())
                : fin.error != null
                ? _LoadError(message: fin.error!, onRetry: fin.load)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    children: [
                      _SummaryCard(
                        balance: fin.balanceCents,
                        income: fin.incomeCents,
                        expense: fin.expenseCents,
                      ),
                      if (fin.expenseCents > 0)
                        _ExpenseChart(data: fin.expenseByCategory),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                        child: Text(
                          'Lançamentos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (fin.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'Nenhum lançamento neste mês.\nToque em "Novo" para começar.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ...fin.items.map(
                          (t) => _TransactionTile(
                            t,
                            onTap: () => _openForm(context, t),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Não foi possível carregar os lançamentos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int balance, income, expense;
  const _SummaryCard({
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Saldo do mês', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              formatMoney(balance),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: balance >= 0 ? _green : _red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _Stat('Receitas', income, Icons.arrow_upward, _green)),
                Expanded(child: _Stat('Despesas', expense, Icons.arrow_downward, _red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int cents;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.cents, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              formatMoney(cents),
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpenseChart extends StatelessWidget {
  final List<MapEntry<String, int>> data;
  const _ExpenseChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Despesas por categoria',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  sections: [
                    for (final e in data)
                      PieChartSectionData(
                        value: e.value / 100,
                        color: categoryByName(e.key).color,
                        title: '',
                        radius: 50,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (final e in data)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: categoryByName(e.key).color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.key)),
                    Text(formatMoney(e.value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final FinanceTransaction t;
  final VoidCallback onTap;
  const _TransactionTile(this.t, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = categoryByName(t.category);
    final color = t.isIncome ? _green : _red;

    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        final provider = context.read<FinanceProvider>();
        final messenger = ScaffoldMessenger.of(context);
        provider.remove(t.id!);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Lançamento excluído'),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () => provider.add(t),
            ),
          ),
        );
      },
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: cat.color.withOpacity(0.15),
          child: Icon(cat.icon, color: cat.color),
        ),
        title: Text(t.description),
        subtitle: Text('${t.category} • ${DateFormat('dd/MM').format(t.date)}'),
        trailing: Text(
          '${t.isIncome ? '+' : '-'} ${formatMoney(t.cents)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

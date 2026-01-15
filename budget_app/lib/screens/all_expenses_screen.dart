import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/currency.dart';
import '../services/storage_service.dart';
import 'add_expense_screen.dart';

class AllExpensesScreen extends StatefulWidget {
  final List<Expense> expenses;
  final int balance;
  final Currency currency;

  const AllExpensesScreen({
    super.key,
    required this.expenses,
    required this.balance,
    required this.currency,
  });

  @override
  State<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends State<AllExpensesScreen> {
  late List<Expense> _expenses;
  late int _balance;
  late Currency _currency;

  static const Map<String, IconData> _icons = {
    'Еда': Icons.local_cafe,
    'Транспорт': Icons.directions_car,
    'Дом': Icons.home,
    'Развлечения': Icons.videogame_asset,
    'Здоровье': Icons.favorite,
  };

  static const Map<String, Color> _colors = {
    'Еда': Colors.orange,
    'Транспорт': Colors.purple,
    'Дом': Colors.blueGrey,
    'Развлечения': Colors.deepPurple,
    'Здоровье': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _expenses = List.of(widget.expenses);
    _balance = widget.balance;
    _currency = widget.currency;
  }

  String _format(int v) {
    return v.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ' ',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Все расходы'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _expenses.isEmpty
          ? const Center(
              child: Text(
                'Расходов пока нет',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _expenses.length,
              itemBuilder: (_, i) {
                final e = _expenses[i];
                final icon = _icons[e.category] ?? Icons.attach_money;
                final color = _colors[e.category] ?? Colors.grey;

                return Dismissible(
                  key: ValueKey(
                      '${e.title}_${e.amount}_${e.date.millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    setState(() {
                      _balance += e.amount;
                      _expenses.removeAt(i);
                    });
                Navigator.pop(context, {
                  'expenses': _expenses,
                  'balance': _balance,
                });
                  },
                  child: GestureDetector(
                    onTap: () async {
                      final updated = await Navigator.push<Expense>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddExpenseScreen(
                            balance: _balance + e.amount,
                            currency: _currency,
                            expense: e,
                          ),
                        ),
                      );

                      if (updated != null) {
                        setState(() {
                          _balance += e.amount;
                          _balance -= updated.amount;
                          _expenses[i] = updated;
                        });
                    Navigator.pop(context, {
                      'expenses': _expenses,
                      'balance': _balance,
                    });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(icon, color: color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${e.category} • ${e.date.day}.${e.date.month}.${e.date.year}',
                                  style:
                                      const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-${_format(e.amount)} ${_currency.symbol}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
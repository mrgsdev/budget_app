import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/currency.dart';
import 'add_expense_screen.dart';
import 'budget_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _balance = 45000;
  Currency _currency = Currency.rub;
  final List<Expense> _expenses = [];

  // ================= CATEGORY META =================

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

  // ================= DATE =================

  int _remainingDays() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day + 1;
  }

  int get _spentToday {
    final today = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .fold(0, (sum, e) => sum + e.amount);
  }

  int _dailyLimit() {
    final days = _remainingDays();
    if (days == 0) return 0;
    return (_balance / days).floor();
  }

  int _availableToday() => _dailyLimit() - _spentToday;

  double _progress() {
    final limit = _dailyLimit();
    if (limit == 0) return 0;
    return _spentToday / limit;
  }

  // ================= NAVIGATION =================

  Future<void> _openAddExpense() async {
    final expense = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          balance: _balance,
          currency: _currency,
        ),
      ),
    );

    if (expense != null) {
      setState(() {
        _expenses.insert(0, expense);
        _balance -= expense.amount;
      });
    }
  }

  Future<void> _openBudgetSetup() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetSetupScreen(
          initialValue: _balance,
          initialCurrency: _currency,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _balance = result['amount'];
        _currency = result['currency'];
      });
    }
  }

  // ================= FORMAT =================

  String _format(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ' ',
        );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const _Header(),
            const SizedBox(height: 16),

            _DailyBudgetCard(
              available: _availableToday(),
              spent: _spentToday,
              limit: _dailyLimit(),
              progress: _progress(),
              currency: _currency,
              format: _format,
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _openBudgetSetup,
                      child: _InfoCard(
                        title: 'Остаток',
                        value: '${_format(_balance)} ${_currency.symbol}',
                        subtitle: '+12% к прошлому',
                        icon: Icons.account_balance_wallet,
                        subtitleColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      title: 'Осталось дней',
                      value: '${_remainingDays()} дней',
                      subtitle: '',
                      icon: Icons.calendar_today,
                      subtitleColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const _ExpensesHeader(),

            Expanded(
              child: _expenses.isEmpty
                  ? const Center(
                      child: Text(
                        'Расходы появятся здесь',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _expenses.length,
                      itemBuilder: (_, i) {
                        final e = _expenses[i];
                        final icon =
                            _icons[e.category] ?? Icons.attach_money;
                        final color =
                            _colors[e.category] ?? Colors.grey;

                        return _ExpenseItem(
                          title: e.title,
                          subtitle: '${e.category} • сегодня',
                          amount:
                              '-${_format(e.amount)} ${_currency.symbol}',
                          icon: icon,
                          color: color,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD6C19A),
        onPressed: _openAddExpense,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ================= HEADER =================

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFEDE6D8),
            child: Icon(Icons.person, color: Colors.black54),
          ),
          SizedBox(width: 12),
          Text(
            'Добрый вечер, Александр',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ================= DAILY CARD =================

class _DailyBudgetCard extends StatelessWidget {
  final int available;
  final int spent;
  final int limit;
  final double progress;
  final Currency currency;
  final String Function(int) format;

  const _DailyBudgetCard({
    required this.available,
    required this.spent,
    required this.limit,
    required this.progress,
    required this.currency,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E2E23), Color(0xFF0F1A14)],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'ДОСТУПНО СЕГОДНЯ',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 8),
            Text(
              '${format(available)} ${currency.symbol}',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD6C19A),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Потрачено: ${format(spent)} ${currency.symbol}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  'Лимит: ${format(limit)} ${currency.symbol}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xFFD6C19A),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Вы в пределах дневного бюджета ✨',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= EXPENSES =================

class _ExpensesHeader extends StatelessWidget {
  const _ExpensesHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Сегодня',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Spacer(),
          Text(
            'Показать все',
            style: TextStyle(color: Color(0xFFD6C19A)),
          ),
        ],
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color color;

  const _ExpenseItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style:
                const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ================= INFO CARD =================

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color subtitleColor;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: TextStyle(color: subtitleColor)),
        ],
      ),
    );
  }
}

// ================= BOTTOM NAV =================

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: const Color(0xFFD6C19A),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Главная'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), label: 'Отчёты'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance), label: 'Счета'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: 'Настройки'),
      ],
    );
  }
}
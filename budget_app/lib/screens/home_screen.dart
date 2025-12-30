import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'budget_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _balance = 45000;
  int _spentToday = 0;
  Currency _currency = Currency.rub;

  // ---------- DATE & BUDGET LOGIC ----------

  int _remainingDays() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return lastDay.day - now.day + 1;
  }

  int _dailyLimit() {
    final days = _remainingDays();
    if (days <= 0) return 0;
    return (_balance / days).floor();
  }

  int _availableToday() {
    return _dailyLimit() - _spentToday;
  }

  double _progress() {
    if (_dailyLimit() == 0) return 0;
    return _spentToday / _dailyLimit();
  }

  // ---------- NAVIGATION ----------

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

  // ---------- FORMAT ----------

  String _format(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final indexFromEnd = s.length - i - 1;
      if (indexFromEnd % 3 == 0 && indexFromEnd != 0) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _Header(),
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
            _InfoCards(
              balance: _format(_balance),
              currency: _currency,
              remainingDays: _remainingDays(),
              onTapBalance: _openBudgetSetup,
            ),
            const SizedBox(height: 24),
            _ExpensesHeader(),
            const SizedBox(height: 8),
            const Expanded(child: _ExpensesList()),
          ],
        ),
      ),
      floatingActionButton: const _AddButton(),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

//
// ---------------- HEADER ----------------
//

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFEDE6D8),
            child: const Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Добрый вечер,', style: TextStyle(color: Colors.grey)),
              Text(
                'Александр',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.notifications_none, size: 28),
        ],
      ),
    );
  }
}

//
// ---------------- DAILY BUDGET CARD ----------------
//

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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E2E23),
              Color(0xFF0F1A14),
            ],
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
            const SizedBox(height: 16),
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

//
// ---------------- INFO CARDS ----------------
//

class _InfoCards extends StatelessWidget {
  final String balance;
  final Currency currency;
  final int remainingDays;
  final VoidCallback onTapBalance;

  const _InfoCards({
    required this.balance,
    required this.currency,
    required this.remainingDays,
    required this.onTapBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTapBalance,
              child: _InfoCard(
                title: 'Остаток',
                value: '$balance ${currency.symbol}',
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
              value: '$remainingDays дней',
              subtitle: '',
              icon: Icons.calendar_today,
              subtitleColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (subtitle.isNotEmpty)
            Text(subtitle, style: TextStyle(color: subtitleColor)),
        ],
      ),
    );
  }
}

//
// ---------------- EXPENSES ----------------
//

class _ExpensesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Сегодня',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ExpensesList extends StatelessWidget {
  const _ExpensesList();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Расходы появятся здесь',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

//
// ---------------- FAB ----------------
//

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFFD6C19A),
      onPressed: () {},
      child: const Icon(Icons.add, color: Colors.black),
    );
  }
}

//
// ---------------- BOTTOM NAV ----------------
//

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
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Отчёты'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance), label: 'Счета'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), label: 'Настройки'),
      ],
    );
  }
}
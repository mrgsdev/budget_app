import 'package:flutter/material.dart';
import 'budget_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _balance = 45000;

  // ----------- LOGIC -----------

  /// Осталось дней в текущем месяце (включая сегодня)
  int _remainingDays() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.day - now.day + 1;
  }

  Future<void> _openBudgetSetup() async {
    final result = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => BudgetSetupScreen(
          initialValue: _balance,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _balance = result;
      });
    }
  }

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

  // ----------- UI -----------

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
            _DailyBudgetCard(),
            const SizedBox(height: 16),
            _InfoCards(
              balance: _format(_balance),
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
          Stack(
            children: const [
              Icon(Icons.notifications_none, size: 28),
              Positioned(
                right: 2,
                top: 2,
                child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
              )
            ],
          )
        ],
      ),
    );
  }
}

//
// ---------------- DAILY CARD ----------------
//

class _DailyBudgetCard extends StatelessWidget {
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
          children: const [
            Text(
              'ДОСТУПНО СЕГОДНЯ',
              style: TextStyle(color: Colors.white54),
            ),
            SizedBox(height: 8),
            Text(
              '2 500 ₽',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD6C19A),
              ),
            ),
            SizedBox(height: 12),
            Text(
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
  final int remainingDays;
  final VoidCallback onTapBalance;

  const _InfoCards({
    required this.balance,
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
                value: '$balance ₽',
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

//
// ---------------- EXPENSES ----------------
//

class _ExpensesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
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

class _ExpensesList extends StatelessWidget {
  const _ExpensesList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _ExpenseItem(
          title: 'Кофе и круассан',
          subtitle: 'Еда • 10:42',
          amount: '-350 ₽',
          icon: Icons.local_cafe,
          iconColor: Colors.orange,
        ),
        _ExpenseItem(
          title: 'Такси до работы',
          subtitle: 'Транспорт • 09:15',
          amount: '-420 ₽',
          icon: Icons.directions_car,
          iconColor: Colors.purple,
        ),
        _ExpenseItem(
          title: 'Продукты',
          subtitle: 'Супермаркет • Вчера',
          amount: '-1 250 ₽',
          icon: Icons.shopping_bag,
          iconColor: Colors.blue,
        ),
      ],
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const _ExpenseItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withOpacity(0.15),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
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
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/currency.dart';
import '../services/storage_service.dart';
import 'add_expense_screen.dart';
import 'budget_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<Expense> expenses;
  final VoidCallback onExpensesChanged;
  
  const HomeScreen({
    super.key,
    required this.expenses,
    required this.onExpensesChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _balance;
  late Currency _currency;
  final List<Expense> _expenses = [];
  final StorageService _storageService = StorageService();
  bool _isLoading = true;

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

  // ================= INITIALIZATION =================

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем данные при обновлении виджета только если изменились расходы
    if (oldWidget.expenses.length != widget.expenses.length && !_isLoading) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    // Загружаем данные из хранилища
    _balance = _storageService.loadBalance();
    _currency = _storageService.loadCurrency();
    _expenses.clear();
    _expenses.addAll(_storageService.loadExpenses());
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveExpenses() async {
    await _storageService.saveExpenses(_expenses);
  }

  Future<void> _saveBalance() async {
    await _storageService.saveBalance(_balance);
  }

  Future<void> _saveCurrency() async {
    await _storageService.saveCurrency(_currency);
  }

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
      await _saveExpenses();
      await _saveBalance();
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
      await _saveBalance();
      await _saveCurrency();
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

return Dismissible(
  key: ValueKey('${e.title}_${e.amount}_${e.date.millisecondsSinceEpoch}_$i'),
  direction: DismissDirection.endToStart,
  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    color: Colors.red,
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (_) async {
    setState(() {
      _balance += e.amount;   // вернуть деньги
      _expenses.removeAt(i);
    });
    await _saveExpenses();
    await _saveBalance();
  },

  // 👇 ВАЖНО: GestureDetector
  child: GestureDetector(
    onTap: () async {
      final updated = await Navigator.push<Expense>(
        context,
        MaterialPageRoute(
          builder: (_) => AddExpenseScreen(
            balance: _balance + e.amount, // вернуть старую сумму
            currency: _currency,
            expense: e,                  // редактируем текущий
          ),
        ),
      );

      if (updated != null) {
        setState(() {
          _balance += e.amount;         // вернуть старое
          _balance -= updated.amount;   // вычесть новое
          _expenses[i] = updated;       // заменить расход
        });
        await _saveExpenses();
        await _saveBalance();
      }
    },

    child: _ExpenseItem(
      title: e.title,
      subtitle: '${e.category} • сегодня',
      amount: '-${_format(e.amount)} ${_currency.symbol}',
      icon: icon,
      color: color,
    ),
  ),
);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab', 
        backgroundColor: const Color(0xFFD6C19A),
        onPressed: _openAddExpense,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      
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


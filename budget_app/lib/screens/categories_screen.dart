import 'package:flutter/material.dart';
import '../data/categories_data.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/currency.dart';
import '../services/storage_service.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Expense> expenses;

  const CategoriesScreen({super.key, required this.expenses});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final StorageService _storageService = StorageService();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void didUpdateWidget(CategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем расходы при обновлении виджета
    _loadExpenses();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Загрузить расходы из хранилища
  void _loadExpenses() {
    _expenses = _storageService.loadExpenses();
  }

  // Получить баланс и валюту
  int get _totalBudget {
    return _storageService.loadBalance();
  }

  Currency get _currency {
    return _storageService.loadCurrency();
  }

  // Рассчитать потраченную сумму
  int get _totalSpent {
    // Используем загруженные расходы из хранилища (всегда актуальные)
    return _expenses.fold(0, (sum, e) => sum + e.amount);
  }

  // Получить потраченную сумму по категории
  int _getSpentForCategory(String categoryName) {
    // Используем загруженные расходы из хранилища (всегда актуальные)
    return _expenses
        .where((e) => e.category == categoryName)
        .fold(0, (sum, e) => sum + e.amount);
  }

  // Получить бюджет категории
  int _getCategoryBudget(String categoryName) {
    return _storageService.getCategoryBudget(categoryName);
  }

  // Форматирование чисел
  String _format(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ' ',
        );
  }


  // Рассчитать процент использования бюджета
  double _getBudgetPercentage(String categoryName) {
    final budget = _getCategoryBudget(categoryName);
    if (budget == 0) return 0;
    final spent = _getSpentForCategory(categoryName);
    return (spent / budget * 100).clamp(0, 100);
  }

  // Получить цвет прогресс-бара в зависимости от процента
  Color _getProgressColor(double percentage) {
    if (percentage >= 90) return Colors.yellow.shade600;
    if (percentage >= 75) return Colors.orange;
    return const Color(0xFFD6C19A);
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoriesData.categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Категории расходов',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Stats Overview
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.account_balance_wallet,
                      title: 'Всего',
                      value: '${_format(_totalBudget)} ${_currency.symbol}',
                      iconColor: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pie_chart,
                      title: 'Потрачено',
                      value: '${_format(_totalSpent)} ${_currency.symbol}',
                      iconColor: const Color(0xFFD6C19A),
                    ),
                  ),
                ],
              ),
            ),

            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ВАШИ КАТЕГОРИИ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Categories List
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        'Нет категорий',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final originalIndex = CategoriesData.categories.indexOf(category);
                        final isProtected = originalIndex < 4; // Первые 4 категории защищены
                        final spent = _getSpentForCategory(category.name);
                        final budget = _getCategoryBudget(category.name);
                        final percentage = budget > 0
                            ? _getBudgetPercentage(category.name)
                            : 0.0;

                        return Dismissible(
                          key: ValueKey(category.name),
                          // 🚫 запрещаем свайп для первых 4 категорий
                          direction: isProtected
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            if (isProtected) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Эту категорию нельзя удалить'),
                                ),
                              );
                              return false;
                            }

                            final used = _expenses.any((e) => e.category == category.name);

                            if (used) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Категория используется в расходах'),
                                ),
                              );
                              return false;
                            }

                            return true;
                          },
                          onDismissed: (_) async {
                            await CategoriesData.remove(originalIndex);
                            setState(() {});
                          },
                          child: _CategoryCard(
                            category: category,
                            spent: spent,
                            budget: budget,
                            percentage: percentage,
                            currency: _currency,
                            format: _format,
                            progressColor: _getProgressColor(percentage),
                            isProtected: isProtected,
                            onTap: isProtected
                                ? null
                                : () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddCategoryScreen(
                                          category: category,
                                          index: originalIndex,
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                          ),
                        );
                      },
                    ),
            ),

            // Add Category Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF7F7F6).withOpacity(0),
                    const Color(0xFFF7F7F6),
                  ],
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // 🔒 Проверка: максимум 8 категорий
                      if (CategoriesData.categories.length >= 8) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Можно создать не более 8 категорий'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddCategoryScreen(),
                        ),
                      );
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6C19A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Добавить категорию',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Category Card Widget
class _CategoryCard extends StatelessWidget {
  final Category category;
  final int spent;
  final int budget;
  final double percentage;
  final Currency currency;
  final String Function(int) format;
  final Color progressColor;
  final bool isProtected;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.category,
    required this.spent,
    required this.budget,
    required this.percentage,
    required this.currency,
    required this.format,
    required this.progressColor,
    required this.isProtected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasBudget = budget > 0;
    final percentageText = percentage.toStringAsFixed(0);
    final isWarning = percentage >= 90;

    // Формируем текст о потраченных деньгах
    final spentText = hasBudget
        ? 'Потрачено: ${format(spent)} ${currency.symbol} / ${format(budget)} ${currency.symbol}'
        : 'Потрачено: ${format(spent)} ${currency.symbol}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 24),
                ),
                const SizedBox(width: 16),
                // Category Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spentText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Percentage (только если есть бюджет) или иконка защиты
                if (hasBudget)
                  Text(
                    '$percentageText%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isWarning
                          ? Colors.yellow.shade600
                          : Colors.black,
                    ),
                  )
                else if (isProtected)
                  Icon(Icons.lock, size: 18, color: Colors.grey.shade400),
              ],
            ),
            // Progress Bar (только если есть бюджет)
            if (hasBudget) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

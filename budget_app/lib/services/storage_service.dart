import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import '../models/currency.dart';
import '../models/expense.dart';
import '../models/category_model.dart';
import '../models/category.dart';

class StorageService {
  static const String _expensesBoxName = 'expenses';
  static const String _settingsBoxName = 'settings';
  static const String _categoriesBoxName = 'categories';
  static const String _balanceKey = 'balance';
  static const String _currencyKey = 'currency';

  // Получить box для расходов
  Box<ExpenseModel> get _expensesBox => Hive.box<ExpenseModel>(_expensesBoxName);
  
  // Получить box для настроек
  Box get _settingsBox => Hive.box(_settingsBoxName);

  // Получить box для категорий
  Box<CategoryModel> get _categoriesBox => Hive.box<CategoryModel>(_categoriesBoxName);

  // ================= EXPENSES =================

  /// Сохранить список расходов
  Future<void> saveExpenses(List<Expense> expenses) async {
    final expenseModels = expenses.map((e) => _expenseToModel(e)).toList();
    await _expensesBox.clear();
    await _expensesBox.addAll(expenseModels);
  }

  /// Загрузить список расходов
  List<Expense> loadExpenses() {
    return _expensesBox.values.map((model) => _modelToExpense(model)).toList();
  }

  /// Добавить один расход
  Future<void> addExpense(Expense expense) async {
    await _expensesBox.add(_expenseToModel(expense));
  }

  /// Удалить расход по индексу
  Future<void> deleteExpense(int index) async {
    await _expensesBox.deleteAt(index);
  }

  /// Обновить расход по индексу
  Future<void> updateExpense(int index, Expense expense) async {
    await _expensesBox.putAt(index, _expenseToModel(expense));
  }

  // ================= BALANCE =================

  /// Сохранить баланс
  Future<void> saveBalance(int balance) async {
    await _settingsBox.put(_balanceKey, balance);
  }

  /// Загрузить баланс (по умолчанию 45000)
  int loadBalance() {
    return _settingsBox.get(_balanceKey, defaultValue: 45000);
  }

  // ================= CURRENCY =================

  /// Сохранить валюту
  Future<void> saveCurrency(Currency currency) async {
    await _settingsBox.put(_currencyKey, currency.index);
  }

  /// Загрузить валюту (по умолчанию rub)
  Currency loadCurrency() {
    final index = _settingsBox.get(_currencyKey, defaultValue: Currency.rub.index);
    return Currency.values[index];
  }

  // ================= CONVERSION =================

  ExpenseModel _expenseToModel(Expense expense) {
    return ExpenseModel(
      title: expense.title,
      category: expense.category,
      amount: expense.amount,
      date: expense.date,
    );
  }

  Expense _modelToExpense(ExpenseModel model) {
    return Expense(
      title: model.title,
      category: model.category,
      amount: model.amount,
      date: model.date,
    );
  }

  // ================= CATEGORIES =================

  /// Сохранить список категорий
  Future<void> saveCategories(List<Category> categories) async {
    final categoryModels = categories.map((c) => CategoryModel.fromCategory(c)).toList();
    await _categoriesBox.clear();
    await _categoriesBox.addAll(categoryModels);
  }

  /// Загрузить список категорий
  List<Category> loadCategories() {
    final models = _categoriesBox.values.toList();
    if (models.isEmpty) {
      return []; // Вернуть пустой список, если нет сохраненных категорий
    }
    return models.map((model) => model.toCategory()).toList();
  }

  /// Проверить, есть ли сохраненные категории
  bool hasSavedCategories() {
    return _categoriesBox.isNotEmpty;
  }
}


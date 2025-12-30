import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/expense_model.dart';
import 'models/currency.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // ✅ Регистрируем адаптеры
  Hive.registerAdapter(ExpenseModelAdapter());
  Hive.registerAdapter(CurrencyAdapter());

  // ✅ Открываем box'ы
  await Hive.openBox<ExpenseModel>('expenses');
  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}
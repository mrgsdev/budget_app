import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';
import 'screens/budget_setup_screen.dart';
import 'screens/main_screen.dart';
import 'models/currency.dart';

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  final StorageService _storage = StorageService();
  bool? _onboardingDone;
  int? _budget;
  Currency? _currency;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _onboardingDone = _storage.isOnboardingCompleted();
    _budget = _storage.loadBalance();
    _currency = _storage.loadCurrency();
    setState(() => _loading = false);
  }

  // Возврат к BudgetSetupScreen, если бюджет сброшен
  void _resetBudget() async {
    _budget = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Material(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 1. Onboarding
    if (!_onboardingDone!) {
      return OnboardingScreen(onFinish: () async {
        await _storage.setOnboardingCompleted(true);
        setState(() => _onboardingDone = true);
      });
    }

    // 2. Setup бюджет
    if (_budget == null || _budget == 0) {
      return BudgetSetupScreen(
        initialValue: 0,
        initialCurrency: _currency ?? Currency.rub,
        // После успешной установки бюджета — реинициализация
        key: const ValueKey('budget_setup'),
      );
    }

    // 3. Основной MainScreen
    return MainScreen(
      key: const ValueKey('main_screen'),
    );
  }
}


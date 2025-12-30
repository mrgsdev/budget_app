import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/currency.dart';

class BudgetSetupScreen extends StatefulWidget {
  final int initialValue;
  final Currency initialCurrency;

  const BudgetSetupScreen({
    super.key,
    required this.initialValue,
    required this.initialCurrency,
  });

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  static const int _maxBudget = 100000000;

  late Currency _currency;
  late String _rawAmount;

  final NumberFormat _formatter = NumberFormat('#,###', 'ru_RU');

  @override
  void initState() {
    super.initState();
    _rawAmount = widget.initialValue.toString();
    _currency = widget.initialCurrency;
  }

  // ---------- LOGIC ----------

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        _rawAmount =
            _rawAmount.length > 1 ? _rawAmount.substring(0, _rawAmount.length - 1) : '0';
        return;
      }

      final nextRaw = _rawAmount == '0' ? key : _rawAmount + key;
      final nextValue = int.tryParse(nextRaw);
      if (nextValue == null || nextValue > _maxBudget) return;

      _rawAmount = nextRaw;
    });
  }

  String get _formattedAmount =>
      _formatter.format(int.parse(_rawAmount)).replaceAll(',', ' ');

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Настройка бюджета',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _currencySwitcher(),
          const SizedBox(height: 48),
          const Text(
            'ОБЩИЙ ЛИМИТ',
            style: TextStyle(color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FittedBox(
              child: Text(
                _formattedAmount,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, {
                  'amount': int.parse(_rawAmount),
                  'currency': _currency,
                });
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C19A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Сохранить',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _keyboard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------- CURRENCY ----------

  Widget _currencySwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: Currency.values.map((c) {
          final selected = _currency == c;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currency = c),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFD6C19A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    c.symbol,
                    style: TextStyle(
                      fontSize: 16,
                      color: selected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------- KEYBOARD ----------

  Widget _keyboard() {
    Widget key(String text, {IconData? icon}) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _onKeyTap(text),
        child: Container(
          width: 88,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon)
                : Text(text, style: const TextStyle(fontSize: 22)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (var row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: row.map((e) => key(e)).toList(),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 88),
              key('0'),
              key('⌫', icon: Icons.backspace_outlined),
            ],
          ),
        ],
      ),
    );
  }
}
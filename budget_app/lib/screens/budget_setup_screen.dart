import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Currency { rub, usd, eur }

class BudgetSetupScreen extends StatefulWidget {
  final int initialValue;

  const BudgetSetupScreen({
    super.key,
    required this.initialValue,
  });

  @override
  State<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends State<BudgetSetupScreen> {
  Currency _currency = Currency.rub;

  late String _rawAmount;
  final NumberFormat _formatter = NumberFormat('#,###', 'ru_RU');

  @override
  void initState() {
    super.initState();
    _rawAmount = widget.initialValue.toString();
  }

  // ---------- LOGIC ----------

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        _rawAmount =
            _rawAmount.length > 1 ? _rawAmount.substring(0, _rawAmount.length - 1) : '0';
      } else {
        if (_rawAmount == '0') {
          _rawAmount = key;
        } else {
          _rawAmount += key;
        }
      }
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
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formattedAmount,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context, int.parse(_rawAmount));
              },
              child: Container(
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C19A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Сохранить',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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

  // ---------- CURRENCY SWITCHER ----------

  Widget _currencySwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _currencyItem('₽', Currency.rub),
          _currencyItem('\$', Currency.usd),
          _currencyItem('€', Currency.eur),
        ],
      ),
    );
  }

  Widget _currencyItem(String text, Currency value) {
    final selected = _currency == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currency = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD6C19A) : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- KEYBOARD ----------

  Widget _keyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _keyboardRow(['1', '2', '3']),
          _keyboardRow(['4', '5', '6']),
          _keyboardRow(['7', '8', '9']),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 88),
              _key('0'),
              _key('⌫', icon: Icons.backspace_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyboardRow(List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((k) => _key(k)).toList(),
      ),
    );
  }

  Widget _key(String text, {IconData? icon}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _onKeyTap(text),
      child: Container(
        width: 88,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 22)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
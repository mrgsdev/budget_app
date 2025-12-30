import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/currency.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final int balance;
  final Currency currency;
  final Expense? expense;
  const AddExpenseScreen({
    super.key,
    required this.balance,
    required this.currency,
    this.expense
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _controller = TextEditingController();
  final NumberFormat _formatter = NumberFormat('#,###', 'ru_RU');

  int _amount = 0;
  String _category = 'Еда';

  final List<_CategoryItem> _categories = const [
    _CategoryItem('Еда', Icons.local_cafe),
    _CategoryItem('Транспорт', Icons.directions_car),
    _CategoryItem('Дом', Icons.home),
    _CategoryItem('Развлечения', Icons.videogame_asset),
    _CategoryItem('Здоровье', Icons.favorite),
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   _controller.text = '0';
  // }

@override
void initState() {
  super.initState();

  if (widget.expense != null) {
    _amount = widget.expense!.amount;
    _category = widget.expense!.category;
    _controller.text = _formatter.format(_amount);
  }
}
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final parsed = int.tryParse(digits) ?? 0;
    final limited = parsed > widget.balance ? widget.balance : parsed;

    setState(() => _amount = limited);

    final formatted =
        _formatter.format(limited).replaceAll(',', ' ');

    if (_controller.text != formatted) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _save() {
    if (_amount == 0) return;

Navigator.pop(
  context,
  Expense(
    title: _category,
    category: _category,
    amount: _amount,
    date: widget.expense?.date ?? DateTime.now(),
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Добавить расход',
              style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(border: InputBorder.none),
                      onChanged: _onChanged,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Баланс: ${widget.balance} ${widget.currency.symbol}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemBuilder: (_, i) {
                  final item = _categories[i];
                  final selected = item.title == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = item.title),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFD6C19A)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: selected
                                ? const Color(0xFFD6C19A)
                                : Colors.grey.shade200,
                            child: Icon(item.icon),
                          ),
                          const SizedBox(height: 8),
                          Text(item.title),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6C19A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Сохранить',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;

  const _CategoryItem(this.title, this.icon);
}
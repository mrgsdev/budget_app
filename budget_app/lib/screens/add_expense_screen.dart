import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../models/currency.dart';
import '../data/categories_data.dart';
import '../models/category.dart';

class AddExpenseScreen extends StatefulWidget {
  final int balance;
  final Currency currency;
  final Expense? expense; // для редактирования

  const AddExpenseScreen({
    super.key,
    required this.balance,
    required this.currency,
    this.expense,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late TextEditingController _amountController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.expense != null
          ? widget.expense!.amount.toString()
          : '',
    );

    _selectedCategory = widget.expense?.category ??
        CategoriesData.categories.first.name;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    int amount = int.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) return;

    // 🔒 финальная защита
    if (amount > widget.balance) {
      amount = widget.balance;
    }

    Navigator.pop(
      context,
      Expense(
        title: _selectedCategory,
        category: _selectedCategory,
        amount: amount,
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoriesData.categories;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Добавить расход',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== AMOUNT =====
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,

                        // 🔒 Ограничение по балансу прямо при вводе
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) {
                            final value =
                                int.tryParse(newValue.text);
                            if (value != null &&
                                value > widget.balance) {
                              final text =
                                  widget.balance.toString();
                              return TextEditingValue(
                                text: text,
                                selection:
                                    TextSelection.collapsed(
                                  offset: text.length,
                                ),
                              );
                            }
                            return newValue;
                          },
                        ),
                      ],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'Баланс: ${widget.balance} ${widget.currency.symbol}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 24),

                // ===== CATEGORY =====
                const Text(
                  'Категория',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemBuilder: (_, i) {
                    final Category c = categories[i];
                    final selected =
                        c.name == _selectedCategory;

                    return GestureDetector(
                      onTap: () => setState(
                        () => _selectedCategory = c.name,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFD6C19A)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  c.color.withOpacity(0.15),
                              child:
                                  Icon(c.icon, color: c.color),
                            ),
                            const SizedBox(height: 8),
                            Text(c.name),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ===== SAVE BUTTON =====
                GestureDetector(
                  onTap: _save,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6C19A),
                      borderRadius:
                          BorderRadius.circular(18),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
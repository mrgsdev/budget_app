import 'package:flutter/material.dart';
import '../data/categories_data.dart';
import '../models/expense.dart';
import 'add_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Expense> expenses;

  const CategoriesScreen({super.key, required this.expenses});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final categories = CategoriesData.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final c = categories[i];

          final isProtected = i < 4;

          return Dismissible(
            key: ValueKey(c.name),

            // 🚫 запрещаем свайп для первых 4 категорий
            direction: isProtected
                ? DismissDirection.none
                : DismissDirection.endToStart,

            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            confirmDismiss: (_) async {
              if (isProtected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Эту категорию нельзя удалить')),
                );
                return false;
              }

              final used = widget.expenses.any((e) => e.category == c.name);

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

            onDismissed: (_) {
              setState(() {
                CategoriesData.remove(i);
              });
            },

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: c.color.withOpacity(0.2),
                child: Icon(c.icon, color: c.color),
              ),
              title: Text(c.name),

              // ✏️ иконка редактирования только для пользовательских
              trailing: isProtected
                  ? const Icon(Icons.lock, size: 18, color: Colors.grey)
                  : const Icon(Icons.edit),

              onTap: isProtected
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddCategoryScreen(category: c, index: i),
                        ),
                      );
                      setState(() {});
                    },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
          );
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

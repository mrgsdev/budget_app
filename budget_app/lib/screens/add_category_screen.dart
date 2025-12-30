import 'package:flutter/material.dart';
import '../models/category.dart';
import '../data/categories_data.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  final int? index;

  const AddCategoryScreen({super.key, this.category, this.index});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxCategories = 8;
  late IconData _selectedIcon;
  late Color _selectedColor;

  final List<IconData> _icons = const [
    Icons.local_cafe,
    Icons.fastfood,
    Icons.shopping_bag,
    Icons.directions_car,
    Icons.home,
    Icons.movie,
    Icons.videogame_asset,
    Icons.favorite,
    Icons.sports_soccer,
    Icons.flight,
    Icons.school,
    Icons.pets,
  ];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.category?.name ?? '';
    _selectedIcon = widget.category?.icon ?? Icons.category;
    _selectedColor = widget.category?.color ?? Colors.blue;
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    // 🔒 Ограничение: максимум 8 категорий
    final isNew = widget.category == null;
    if (isNew && CategoriesData.categories.length >= _maxCategories) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Можно создать не более 8 категорий'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🔍 Проверка на дубликат имени
    final exists = CategoriesData.categories.any(
      (c) =>
          c.name.toLowerCase() == name.toLowerCase() &&
          c != widget.category,
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Такая категория уже существует'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final category = Category(
      name: name,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    if (widget.index != null) {
      await CategoriesData.update(widget.index!, category);
    } else {
      await CategoriesData.add(category);
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.category == null
                ? 'Новая категория'
                : 'Редактировать категорию',
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Название'),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Иконка'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _icons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final icon = _icons[i];
                  final selected = icon == _selectedIcon;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
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
                      child: Icon(
                        icon,
                        color: selected
                            ? const Color(0xFFD6C19A)
                            : Colors.black54,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              GestureDetector(
                onTap: _save,
                child: Container(
                  height: 56,
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoriesData {
  static final List<Category> categories = [
    Category(name: 'Еда', icon: Icons.local_cafe, color: Colors.orange),
    Category(name: 'Транспорт',icon: Icons.directions_car,color: Colors.purple),
    Category(name: 'Дом', icon: Icons.home, color: Colors.blueGrey),
    Category(name: 'Здоровье', icon: Icons.health_and_safety_sharp, color: Colors.blueGrey),
  ];

  static void add(Category c) => categories.add(c);

  static void update(int index, Category c) {
    categories[index] = c;
  }

  static void remove(int index) {
    categories.removeAt(index);
  }
}

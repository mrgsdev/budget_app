import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoriesData {
  static final List<Category> categories = [];
  static final StorageService _storageService = StorageService();
  static bool _isInitialized = false;

  // Стандартные категории по умолчанию
  static final List<Category> _defaultCategories = [
    Category(name: 'Еда', icon: Icons.local_cafe, color: Colors.orange),
    Category(name: 'Транспорт', icon: Icons.directions_car, color: Colors.purple),
    Category(name: 'Дом', icon: Icons.home, color: Colors.blueGrey),
    Category(name: 'Здоровье', icon: Icons.health_and_safety_sharp, color: Colors.blueGrey),
  ];

  /// Инициализация категорий (загрузка из хранилища или использование дефолтных)
  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (_storageService.hasSavedCategories()) {
      // Загружаем сохраненные категории
      categories.clear();
      categories.addAll(_storageService.loadCategories());
    } else {
      // Используем дефолтные категории
      categories.clear();
      categories.addAll(_defaultCategories);
      // Сохраняем дефолтные категории
      await _storageService.saveCategories(categories);
    }

    _isInitialized = true;
  }

  static Future<void> add(Category c) async {
    categories.add(c);
    await _storageService.saveCategories(categories);
  }

  static Future<void> update(int index, Category c) async {
    categories[index] = c;
    await _storageService.saveCategories(categories);
  }

  static Future<void> remove(int index) async {
    categories.removeAt(index);
    await _storageService.saveCategories(categories);
  }
}

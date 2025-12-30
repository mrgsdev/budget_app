import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 3)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int iconCodePoint;

  @HiveField(2)
  final String iconFontFamily;

  @HiveField(3)
  final String iconFontPackage;

  @HiveField(4)
  final int colorValue;

  CategoryModel({
    required this.name,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.iconFontPackage,
    required this.colorValue,
  });

  // Конвертация в Category
  Category toCategory() {
    return Category(
      name: name,
      icon: IconData(
        iconCodePoint,
        fontFamily: iconFontFamily.isEmpty ? null : iconFontFamily,
        fontPackage: iconFontPackage.isEmpty ? null : iconFontPackage,
      ),
      color: Color(colorValue),
    );
  }

  // Создание из Category
  factory CategoryModel.fromCategory(Category category) {
    return CategoryModel(
      name: category.name,
      iconCodePoint: category.icon.codePoint,
      iconFontFamily: category.icon.fontFamily ?? '',
      iconFontPackage: category.icon.fontPackage ?? '',
      colorValue: category.color.value,
    );
  }
}


import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final int amount;

  @HiveField(3)
  final DateTime date;

  ExpenseModel({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });
}
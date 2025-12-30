class CategoryBudget {
  final String categoryName;
  final int budget;

  CategoryBudget({
    required this.categoryName,
    required this.budget,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'budget': budget,
    };
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      categoryName: json['categoryName'] as String,
      budget: json['budget'] as int,
    );
  }
}


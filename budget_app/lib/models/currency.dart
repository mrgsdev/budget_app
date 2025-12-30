import 'package:hive/hive.dart';

part 'currency.g.dart';

@HiveType(typeId: 2)
enum Currency {
  @HiveField(0)
  rub,

  @HiveField(1)
  usd,

  @HiveField(2)
  eur,
}

extension CurrencyX on Currency {
  String get symbol {
    switch (this) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.rub:
        return '₽';
    }
  }
}
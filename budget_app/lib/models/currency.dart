enum Currency { rub, usd, eur }

extension CurrencyX on Currency {
  String get symbol {
    switch (this) {
      case Currency.rub:
        return '₽';
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
    }
  }

  String get label => symbol;
}
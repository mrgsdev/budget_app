enum Currency { rub, usd, eur }

extension CurrencyX on Currency {
  String get symbol {
    switch (this) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.rub:
      default:
        return '₽';
    }
  }

  String get label {
    switch (this) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.rub:
      default:
        return '₽';
    }
  }
}
import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyCfa =
      NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  static final NumberFormat _decimalOne =
      NumberFormat.decimalPatternDigits(locale: 'fr_FR', decimalDigits: 1);

  static String currencyCfa(num value) {
    if (value == 0) return '0 FCFA';
    // On veut le format "12 500 FCFA"
    final formatted = NumberFormat.decimalPattern('fr_FR').format(value);
    return '$formatted FCFA';
  }

  static String rating(num value) => _decimalOne.format(value);
}


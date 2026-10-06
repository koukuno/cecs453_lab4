import 'package:decimal/decimal.dart';

class Mortgage {
  final Decimal amount;
  final Decimal rate;
  final int years;

  const Mortgage({required this.amount, required this.rate, required this.years});

  Decimal getMonthlyPayment() {
    final monthlyRate = (rate / Decimal.fromInt(12)).toDecimal(scaleOnInfinitePrecision: 8);
    final numerator = amount * monthlyRate;
    final denominator = Decimal.fromInt(1) - (Decimal.fromInt(1) + monthlyRate).pow(-12 * years).toDecimal(scaleOnInfinitePrecision: 8);
    return (numerator / denominator).toDecimal(scaleOnInfinitePrecision: 2);
  }

  Decimal getTotalPayment() => getMonthlyPayment() * Decimal.fromInt(12) * Decimal.fromInt(years);
  String formatMonthlyPayment() => getMonthlyPayment().toStringAsFixed(2);
  String formatTotalPayment() => getTotalPayment().toStringAsFixed(2);
}

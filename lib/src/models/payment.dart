/// Represents a payment amount for user tracking.
abstract class Payment {
  /// The monthly amount in cents.
  int get monthlyAmountInCents;

  const Payment();

  /// Creates a weekly payment amount.
  factory Payment.weekly(double amount) = WeeklyPayment;

  /// Creates a monthly payment amount.
  factory Payment.monthly(double amount) = MonthlyPayment;

  /// Creates a yearly payment amount.
  factory Payment.yearly(double amount) = YearlyPayment;
}

/// Weekly payment amount.
class WeeklyPayment extends Payment {
  final double amount;

  const WeeklyPayment(this.amount);

  @override
  int get monthlyAmountInCents => (amount * 4.33 * 100).round();
}

/// Monthly payment amount.
class MonthlyPayment extends Payment {
  final double amount;

  const MonthlyPayment(this.amount);

  @override
  int get monthlyAmountInCents => (amount * 100).round();
}

/// Yearly payment amount.
class YearlyPayment extends Payment {
  final double amount;

  const YearlyPayment(this.amount);

  @override
  int get monthlyAmountInCents => ((amount / 12) * 100).ceil();
}

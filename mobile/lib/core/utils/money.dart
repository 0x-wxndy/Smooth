import 'package:intl/intl.dart';

/// Algerian Dinar formatting helpers.
/// Stored amounts use "centimes" (1 DZD = 100) for consistency with the schema.
abstract final class Money {
  static const currencyCode = 'DZD';
  static const symbol = 'د.ج';

  /// Format a price stored as centimes (e.g. 150000 → "1 500 د.ج").
  static String format(int centimes, {String? freeLabel}) {
    if (centimes <= 0 && freeLabel != null) return freeLabel;
    final amount = centimes / 100;
    final formatted = NumberFormat('#,###', 'fr_DZ').format(amount.round());
    return '$formatted $symbol';
  }

  /// Hourly rate from DZD (whole dinars).
  static String perHour(int dinars, {required String perHourSuffix}) {
    final formatted = NumberFormat('#,###', 'fr_DZ').format(dinars);
    return '$formatted $symbol$perHourSuffix';
  }

  /// Convert legacy USD-cents style seed values if needed — prefer storing DZD.
  static int dzd(int dinars) => dinars * 100;
}

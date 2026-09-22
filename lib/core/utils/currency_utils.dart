import '../constants/app_constants.dart';

/// Formatting for Kenyan shilling amounts.
///
/// Two variants are in use across the app:
/// [format] for on-screen values (whole shillings, "Ksh" symbol) and
/// [formatPrecise] for documents such as PDF invoices (two decimals, "KES"
/// currency code).
class CurrencyUtils {
  const CurrencyUtils._();

  /// Matches each digit group that should be followed by a thousands comma.
  static final RegExp _thousands = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

  static String _separate(String value) =>
      value.replaceAllMapped(_thousands, (m) => '${m[1]},');

  /// Whole shillings for display, e.g. `150000` becomes `Ksh 150,000`.
  static String format(double amount) =>
      '${AppConstants.currencySymbol} ${_separate(amount.toStringAsFixed(0))}';

  /// Two decimal places for documents, e.g. `150000` becomes `KES 150,000.00`.
  static String formatPrecise(double amount) =>
      '${AppConstants.currency} ${_separate(amount.toStringAsFixed(2))}';
}

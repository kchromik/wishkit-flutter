import 'package:intl/intl.dart';

/// Locale-aware absolute date formatting.
///
/// Replaces the old `'%dy ago'` string-template approach, which could not
/// express the plural and gender rules that Russian, Polish, Arabic and Czech
/// need. iOS sidesteps the problem by only ever formatting an absolute date
/// (`Date.wkFormatted()`, used for the "3 days ago" style comment timestamps in
/// the detail view) — so this does the same and nothing more.
abstract final class WishKitDateFormat {
  /// Two-digit day, two-digit month, four-digit year, in the locale's own
  /// order and separators.
  ///
  /// `06/07/2026` in en-US, `07.06.2026` in de-DE, `2026/06/07` in ja-JP —
  /// the same output as iOS's `Date.FormatStyle(date: .numeric)` with
  /// two-digit month and day.
  ///
  /// [intl] does not expose a year-first/two-digit-day pattern equivalent to
  /// CLDR's `yMMMd` for every locale without pulling in `DateFormat` skeleton
  /// lookups per locale, so the pattern is chosen from the resolved locale's
  /// own skeleton via [DateFormat.yMMMd], which Flutter's localizations
  /// initialize.
  static String medium(DateTime date, String localeName) =>
      DateFormat.yMMMd(localeName).format(date);

  /// [medium] for a date that may not be parseable.
  ///
  /// The API hands back `createdAt` as a string and the contract has never
  /// promised a format, so a single unparseable row must not take the comment
  /// list down with it. Returns `null` so the caller can hide the timestamp.
  static String? mediumOrNull(String? rawDate, String localeName) {
    if (rawDate == null || rawDate.isEmpty) return null;
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return null;
    return medium(parsed.toLocal(), localeName);
  }
}

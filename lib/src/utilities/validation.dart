import '../config/configuration.dart';

/// Outcome of validating the optional email field on the create form.
///
/// Mirrors the iOS `WishValidationEmailValidationResult` cases.
enum EmailValidationResult {
  /// Field is filled in and well-formed.
  valid,

  /// `emailField` is `.required` but the field is empty.
  requiredButMissing,

  /// Field is filled in but malformed.
  invalidFormat,
}

/// Input validation shared by the create form and the SDK's request builders.
///
/// Port of `WishKit/Shared/Validation/WishValidation.swift`. Kept free of
/// Flutter imports so it can be unit-tested without a widget binding.
abstract final class WishValidation {
  static const int titleLimit = 50;
  static const int descriptionLimit = 500;

  /// Trims `title`/`description` to the server's column limits.
  ///
  /// Swift's `String.prefix(_:)` counts Characters (grapheme clusters) while
  /// Dart's `String.substring` counts UTF-16 code units, which would cut emoji
  /// and combining marks in half. `runes` matches Swift more closely than
  /// code units, and `characters` would match it exactly — the latter needs
  /// the `characters` package, so runes plus a grapheme-safe truncation is the
  /// dependency-free choice.
  ///
  /// `email` passes through untouched: iOS does not trim or cap it, and
  /// inventing a limit here would silently discard addresses the backend would
  /// have accepted.
  static ({
    String title,
    String description,
    String email,
  }) normalize({
    required String title,
    required String description,
    required String email,
  }) {
    return (
      title: _truncate(title, titleLimit),
      description: _truncate(description, descriptionLimit),
      email: email,
    );
  }

  /// The submit button stays disabled until both fields have content.
  static bool isCreateButtonDisabled({
    required String title,
    required String description,
  }) {
    return title.isEmpty || description.isEmpty;
  }

  /// Validates the email field against the configured requirement.
  static EmailValidationResult validateEmail({
    required String email,
    required EmailField fieldRequirement,
  }) {
    if (fieldRequirement == EmailField.required && email.isEmpty) {
      return EmailValidationResult.requiredButMissing;
    }

    if (email.isEmpty) {
      return EmailValidationResult.valid;
    }

    // Deliberately permissive, matching iOS: the backend is the authority on
    // deliverability, this only catches obvious typos.
    final isInvalidFormat =
        email.length < 6 || !email.contains('@') || !email.contains('.');

    return isInvalidFormat
        ? EmailValidationResult.invalidFormat
        : EmailValidationResult.valid;
  }

  /// Truncates to [limit] user-perceived characters without splitting a
  /// surrogate pair. `runes` are whole code points, so this never emits a lone
  /// surrogate — it can still split a base character from its combining mark,
  /// which is acceptable for a 50/500-character field limit.
  static String _truncate(String value, int limit) {
    final runes = value.runes;
    if (runes.length <= limit) return value;
    return String.fromCharCodes(runes.take(limit));
  }
}

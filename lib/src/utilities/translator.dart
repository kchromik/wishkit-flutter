import 'dart:ui' show Locale;

/// One string to translate.
///
/// A *batch* is used rather than a single string because a wish's title and
/// description are translated together, and a host implementation that talks to
/// a real translation engine (ML Kit, Google Translate, an on-device model)
/// amortises its setup cost across the pair. Translating them one at a time
/// would double the latency of the thing the user is waiting on.
class WishKitTranslationRequest {
  /// The text to translate.
  final String sourceText;

  /// Stable key echoed back on [WishKitTranslation.clientIdentifier] so the
  /// caller can tell which result belongs to which input.
  ///
  /// WishKit uses `title` and `description`.
  final String clientIdentifier;

  /// BCP-47 tag the text is believed to be in, or `null` when unknown.
  ///
  /// Pass `null` to let the translator auto-detect. WishKit always fills this in
  /// from [FeedbackLanguage] when it could, which saves the host a detection
  /// round-trip.
  final String? sourceLanguage;

  /// BCP-47 tag to translate into. Always the app's language.
  final String targetLanguage;

  const WishKitTranslationRequest({
    required this.sourceText,
    required this.clientIdentifier,
    required this.targetLanguage,
    this.sourceLanguage,
  });

  @override
  String toString() =>
      'WishKitTranslationRequest($clientIdentifier, $sourceLanguage'
      '→$targetLanguage)';
}

/// The result of translating one [WishKitTranslationRequest].
class WishKitTranslation {
  /// The text that was sent in the request.
  final String sourceText;

  /// The translated text. Equal to [sourceText] when the translator had nothing
  /// to do, which is what a translator should return for a no-op.
  final String targetText;

  /// The [WishKitTranslationRequest.clientIdentifier] this result answers.
  final String clientIdentifier;

  const WishKitTranslation({
    required this.sourceText,
    required this.targetText,
    required this.clientIdentifier,
  });

  /// Convenience for the common case of a no-op.
  factory WishKitTranslation.unchanged(WishKitTranslationRequest request) =>
      WishKitTranslation(
        sourceText: request.sourceText,
        targetText: request.sourceText,
        clientIdentifier: request.clientIdentifier,
      );

  @override
  String toString() => 'WishKitTranslation($clientIdentifier)';
}

/// Translates a batch of requests, and is expected to return one result per
/// request, in the same order.
///
/// The whole batch is one call so a host can share a single engine session
/// across the wish's title and description.
///
/// Set this on [WishKitConfiguration.translator] to enable the
/// "See translation" affordance. Left `null`, WishKit shows no translation UI
/// at all — same as iOS on a system older than iOS 18, where Apple's
/// Translation framework is unavailable.
///
/// ## Example
///
/// ```dart
/// WishKit.config.translator = (requests) async {
///   final translated = <WishKitTranslation>[];
///   for (final request in requests) {
///     final result = await translator.translate(
///       request.sourceText,
///       from: request.sourceLanguage,
///       to: request.targetLanguage,
///     );
///     translated.add(WishKitTranslation(
///       sourceText: request.sourceText,
///       targetText: result,
///       clientIdentifier: request.clientIdentifier,
///     ));
///   }
///   return translated;
/// };
/// ```
///
/// ## Contract
///
/// * Called from a Flutter widget's build/lifecycle, not from an isolate, so it
///   may use platform channels directly.
/// * Throwing is safe: WishKit catches, logs and leaves the wish untranslated.
/// * Returning fewer results than requests is safe too — the missing ones fall
///   back to the original text.
typedef WishKitTranslator = Future<List<WishKitTranslation>> Function(
  List<WishKitTranslationRequest> requests,
);

/// The app's language as a BCP-47 tag, which is what translation targets and
/// [WishKitTranslationRequest.sourceLanguage] are expressed in.
///
/// Deliberately reads the *widget* locale rather than `PlatformDispatcher`,
/// because a host app can override the locale for a subtree and WishKit should
/// translate into the language the user is actually looking at.
String wishKitLanguageTag(Locale locale) => locale.toLanguageTag();

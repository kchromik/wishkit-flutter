/// A language guess for a piece of user-generated feedback.
class DetectedLanguage {
  /// ISO 639 language code, e.g. `en`, `de`, `zh`.
  final String languageCode;

  /// ISO 15924 script code when the script disambiguates, e.g. `Hans`/`Hant`
  /// for Chinese. `null` when the script is not meaningful for this language.
  final String? scriptCode;

  /// Detector confidence in the range 0..1.
  final double confidence;

  const DetectedLanguage({
    required this.languageCode,
    this.scriptCode,
    this.confidence = 0.5,
  });

  /// `zh-Hans` / `pt-BR` style tag, used for logging and equality checks.
  String get tag =>
      scriptCode == null ? languageCode : '$languageCode-$scriptCode';

  @override
  bool operator ==(Object other) =>
      other is DetectedLanguage &&
      other.languageCode == languageCode &&
      other.scriptCode == scriptCode;

  @override
  int get hashCode => Object.hash(languageCode, scriptCode);

  @override
  String toString() => 'DetectedLanguage($tag, ${confidence.toStringAsFixed(2)})';
}

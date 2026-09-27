import 'package:flutter/foundation.dart';

/// Debug logging for WishKit.
///
/// The iOS SDK gates this on `Configuration.showDebugLogs` and it works in
/// release builds. The Flutter SDK previously used `assert`-wrapped
/// `debugPrint` calls, which the compiler strips from release and profile
/// builds — so the diagnostics were effectively debug-only. This logger keeps
/// the same config gate but stays live in every build mode.
class WishKitLogger {
  WishKitLogger._();

  /// Mirrors `WishKit.config.showDebugLogs`. Set by `WishKit.configure`.
  ///
  /// Defaults to `true` in debug builds so a misconfigured app is still
  /// diagnosable, matching the iOS `#if DEBUG` API-key warning.
  static bool _enabled = kDebugMode;

  /// Sink for log lines. Replaceable so tests can capture output without
  /// depending on the global `debugPrint` throttler.
  static void Function(String message) _sink = debugPrint;

  static bool get isEnabled => _enabled;

  static void configure({required bool enabled}) => _enabled = enabled;

  /// Redirects log output. Pass `null` to restore the default sink.
  @visibleForTesting
  static void setSink(void Function(String message)? sink) {
    _sink = sink ?? debugPrint;
  }

  /// Logs an informational line. No-op unless debug logs are enabled.
  static void log(String message) {
    if (!_enabled) return;
    _sink('[WishKit] $message');
  }

  /// Logs a failure. Unlike [log] this always prints: a failed request is
  /// worth surfacing even when the host app asked for a quiet SDK, and it
  /// carries no user data beyond the error the backend already returned.
  static void error(String message) {
    _sink('[WishKit] ⚠️ $message');
  }

  /// Clears the override installed by [setSink] and restores the default gate.
  @visibleForTesting
  static void reset() {
    _sink = debugPrint;
    _enabled = kDebugMode;
  }
}

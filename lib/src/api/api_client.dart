import 'dart:convert';

import 'package:http/http.dart' as http;

import '../manager/uuid_manager.dart';
import '../utilities/logger.dart';

/// Result type for API calls.
class ApiResult<T> {
  /// The decoded response, or `null` for a `void` call.
  final T? data;

  /// Why the call failed, or `null` on success.
  final ApiError? error;

  final bool isSuccess;

  const ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  const ApiResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// Why a request failed, independent of the wording the server chose.
///
/// Port of the iOS SDK's `ApiErrorReason`. The server's own `reason` string is
/// authoritative and is what [ApiError.reason] exposes; this enum only covers
/// the cases WishKit can identify without trusting the response, so a host can
/// branch on "no network" without string-matching a message.
enum ApiErrorReason {
  /// The request never left the device: no connectivity, DNS failure, timeout.
  network,

  /// The response was not JSON, or was JSON of an unexpected shape.
  couldNotDecodeBackendResponse,

  /// The server rejected the request. See [ApiError.statusCode].
  requestRejected,

  /// No API key was configured.
  missingApiKey,

  /// Anything else.
  requestResultedInError,
}

/// API error information.
///
/// [message] and [statusCode] are kept for backwards compatibility with hosts
/// that already read them; new code should prefer [reason] and [serverReason].
class ApiError {
  /// Human-readable description, safe to show in a debug screen.
  final String message;

  /// HTTP status, or `null` when the request never completed.
  final int? statusCode;

  /// What went wrong, as far as WishKit could tell.
  final ApiErrorReason reason;

  /// The server's own `reason` string, verbatim.
  final String? serverReason;

  const ApiError({
    required this.message,
    this.statusCode,
    this.reason = ApiErrorReason.requestResultedInError,
    this.serverReason,
  });

  /// Whether a retry could plausibly succeed.
  ///
  /// A rejected request will fail identically on retry; a decode failure or a
  /// network blip might not.
  bool get isRetryable =>
      reason == ApiErrorReason.network ||
      reason == ApiErrorReason.couldNotDecodeBackendResponse;

  @override
  String toString() {
    final code = statusCode == null ? 'no status' : 'status $statusCode';
    return 'ApiError(${reason.name}, $code): $message';
  }
}

/// HTTP client for WishKit API.
class ApiClient {
  /// Overridable at build time so an app can point at staging without forking
  /// the SDK:
  ///
  /// ```sh
  /// flutter run --dart-define=wishkit-url=https://staging.wishkit.io/api
  /// ```
  ///
  /// The default is the production API.
  static const String defaultBaseUrl = String.fromEnvironment(
    'wishkit-url',
    defaultValue: 'https://www.wishkit.io/api',
  );

  static const String _sdkVersion = '1.0.0';
  static const String _sdkKind = 'flutter';

  final String baseUrl;
  final String apiKey;

  /// Display name of the host app, reported to the dashboard.
  final String? appName;

  /// Reverse-DNS bundle identifier, reported to the dashboard.
  ///
  /// Only sent outside debug builds, matching iOS's
  /// `if AppEnvironment.isProduction` guard: a bundle id identifies an app
  /// precisely, and a developer running against production does not need to
  /// identify themselves that way in their own traffic.
  final String? appId;

  final http.Client _client;

  ApiClient({
    required this.apiKey,
    this.appName,
    this.appId,
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  /// Creates request headers with authentication and SDK metadata.
  Future<Map<String, String>> _createHeaders() async {
    final uuid = await UUIDManager.getUUID();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-wishkit-api-key': apiKey,
      'x-wishkit-uuid': uuid,
      'x-wishkit-sdk-kind': _sdkKind,
      'x-wishkit-sdk-version': _sdkVersion,
      'x-wishkit-sdk-app-name': appName ?? 'none',
      if (appId != null && !_isDebugBuild) 'x-wishkit-sdk-bundle-id': appId!,
    };
  }

  static bool get _isDebugBuild {
    bool isDebug = false;
    assert(() {
      isDebug = true;
      return true;
    }());
    return isDebug;
  }

  /// Performs a GET request.
  Future<ApiResult<T>> get<T>(
    String endpoint,
    T Function(dynamic json) fromJson,
  ) =>
      _send<T>('GET', endpoint, fromJson, (uri, headers) {
        return _client.get(uri, headers: headers);
      });

  /// Performs a POST request.
  Future<ApiResult<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic json) fromJson,
  ) =>
      _send<T>('POST', endpoint, fromJson, (uri, headers) {
        return _client.post(uri, headers: headers, body: jsonEncode(body));
      });

  /// Performs a POST request without expecting a response body.
  Future<ApiResult<void>> postVoid(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final result = await _send<dynamic>(
      'POST',
      endpoint,
      _ignoreJson,
      (uri, headers) =>
          _client.post(uri, headers: headers, body: jsonEncode(body)),
    );
    if (result.isSuccess) return const ApiResult.success(null);
    return ApiResult.failure(result.error!);
  }

  /// Performs a PATCH request.
  Future<ApiResult<T>> patch<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic json) fromJson,
  ) =>
      _send<T>('PATCH', endpoint, fromJson, (uri, headers) {
        return _client.patch(uri, headers: headers, body: jsonEncode(body));
      });

  /// Performs a DELETE request.
  Future<ApiResult<T>> delete<T>(
    String endpoint,
    T Function(dynamic json) fromJson,
  ) =>
      _send<T>('DELETE', endpoint, fromJson, (uri, headers) {
        return _client.delete(uri, headers: headers);
      });

  /// Performs a DELETE request without expecting a response body.
  Future<ApiResult<void>> deleteVoid(String endpoint) async {
    final result = await _send<dynamic>(
      'DELETE',
      endpoint,
      _ignoreJson,
      (uri, headers) => _client.delete(uri, headers: headers),
    );
    if (result.isSuccess) return const ApiResult.success(null);
    return ApiResult.failure(result.error!);
  }

  // -----------------------------------------------------------------------
  // Plumbing
  // -----------------------------------------------------------------------

  Uri _uri(String endpoint) => Uri.parse('$baseUrl$endpoint');

  /// For endpoints that return nothing worth decoding.
  static dynamic _ignoreJson(dynamic json) => json;

  Future<ApiResult<T>> _send<T>(
    String method,
    String endpoint,
    T Function(dynamic json) fromJson,
    Future<http.Response> Function(Uri uri, Map<String, String> headers)
        request,
  ) async {
    if (apiKey.isEmpty) {
      return ApiResult.failure(const ApiError(
        message: 'WishKit API key is missing. Call WishKit.configure() with '
            'your API key from the wishkit.io dashboard before showing any '
            'WishKit view.',
        reason: ApiErrorReason.missingApiKey,
      ));
    }

    final uri = _uri(endpoint);
    try {
      WishKitLogger.log('🌐 API | $method | $uri');
      final response = await request(uri, await _createHeaders());
      WishKitLogger.log('$method $endpoint → ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResult<T>.success(null as T);
        }
        try {
          return ApiResult.success(fromJson(jsonDecode(response.body)));
        } on Object catch (error) {
          WishKitLogger.error('$endpoint could not decode: $error');
          WishKitLogger.error('Body: ${response.body}');
          return ApiResult.failure(ApiError(
            message: 'Could not decode the response from $endpoint.',
            statusCode: response.statusCode,
            reason: ApiErrorReason.couldNotDecodeBackendResponse,
          ));
        }
      }

      return ApiResult.failure(_errorFromResponse(response));
    } on Object catch (error) {
      WishKitLogger.error('$method $endpoint error: $error');
      return ApiResult.failure(ApiError(
        message: error.toString(),
        reason: ApiErrorReason.network,
      ));
    }
  }

  /// Builds an [ApiError] from a non-2xx response, preferring the server's own
  /// structured error over anything invented here.
  ApiError _errorFromResponse(http.Response response) {
    String? serverReason;
    var message = 'Request failed';

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        serverReason = decoded['reason'] as String?;
        message = (decoded['message'] ?? decoded['error'] ?? message).toString();
      }
    } on Object {
      // Not JSON — an HTML error page from a proxy, most likely. The status
      // line is the only thing worth reporting.
      if (response.body.isNotEmpty && response.body.length <= 200) {
        message = response.body;
      }
    }

    WishKitLogger.error('$serverReason. $message');
    return ApiError(
      message: message,
      statusCode: response.statusCode,
      reason: ApiErrorReason.requestRejected,
      serverReason: serverReason,
    );
  }

  /// Closes the HTTP client.
  void dispose() => _client.close();
}

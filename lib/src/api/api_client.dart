import 'dart:convert';
import 'package:http/http.dart' as http;
import '../manager/uuid_manager.dart';

/// Result type for API calls.
class ApiResult<T> {
  final T? data;
  final ApiError? error;
  final bool isSuccess;

  const ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  const ApiResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// API error information.
class ApiError {
  final String message;
  final int? statusCode;

  const ApiError({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ApiError: $message (status: $statusCode)';
}

/// HTTP client for WishKit API.
class ApiClient {
  static const String _defaultBaseUrl = 'https://www.wishkit.io/api';
  static const String _sdkVersion = '1.0.0';
  static const String _sdkKind = 'flutter';

  final String baseUrl;
  final String apiKey;
  final String? appName;
  final http.Client _client;

  ApiClient({
    required this.apiKey,
    this.appName,
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl,
        _client = client ?? http.Client();

  /// Creates request headers with authentication.
  Future<Map<String, String>> _createHeaders() async {
    final uuid = await UUIDManager.getUUID();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'x-wishkit-api-key': apiKey,
      'x-wishkit-uuid': uuid,
      'x-wishkit-sdk-kind': _sdkKind,
      'x-wishkit-sdk-version': _sdkVersion,
      if (appName != null) 'x-wishkit-sdk-app-name': appName!,
    };
  }

  /// Performs a GET request.
  Future<ApiResult<T>> get<T>(
    String endpoint,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final headers = await _createHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body);
        return ApiResult.success(fromJson(json));
      } else {
        return ApiResult.failure(ApiError(
          message: _parseErrorMessage(response.body),
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// Performs a POST request.
  Future<ApiResult<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final headers = await _createHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResult.success(null as T);
        }
        final json = jsonDecode(response.body);
        return ApiResult.success(fromJson(json));
      } else {
        return ApiResult.failure(ApiError(
          message: _parseErrorMessage(response.body),
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  /// Performs a POST request without expecting a response body.
  Future<ApiResult<void>> postVoid(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _createHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const ApiResult.success(null);
      } else {
        return ApiResult.failure(ApiError(
          message: _parseErrorMessage(response.body),
          statusCode: response.statusCode,
        ));
      }
    } catch (e) {
      return ApiResult.failure(ApiError(message: e.toString()));
    }
  }

  String _parseErrorMessage(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? json['error'] ?? 'Unknown error';
    } catch (_) {
      return body.isNotEmpty ? body : 'Unknown error';
    }
  }

  /// Closes the HTTP client.
  void dispose() {
    _client.close();
  }
}

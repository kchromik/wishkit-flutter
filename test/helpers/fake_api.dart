import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wishkit/src/manager/uuid_manager.dart';
import 'package:wishkit/wishkit.dart';

/// A recorded request the fake API saw.
class RecordedRequest {
  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final String body;

  const RecordedRequest({
    required this.method,
    required this.uri,
    required this.headers,
    required this.body,
  });

  /// The decoded JSON body, or an empty map for a bodyless request.
  Map<String, dynamic> get json => body.isEmpty
      ? <String, dynamic>{}
      : jsonDecode(body) as Map<String, dynamic>;

  /// The path without the query string, e.g. `/wish/list`.
  String get path => uri.path.replaceFirst(RegExp(r'^/api'), '');

  @override
  String toString() => '$method $path';
}

/// A stand-in for the WishKit backend.
///
/// Injected through [ApiClient]'s `client` seam rather than by stubbing out
/// [WishModel], so a test exercises the real request building, the real JSON
/// parsing and the real bucketing. The alternative — a test-only setter on
/// [WishModel] — would ship a way for the board to display a list it never
/// fetched.
class FakeWishKitApi {
  /// The device user id every seeded model reports, so ownership-dependent
  /// bucketing is deterministic.
  ///
  /// Pending feedback is bucketed by ownership, so a test that does not control
  /// the user id silently tests the "someone else's pending is excluded" path
  /// while claiming to test your own.
  static const String userUuid = '11111111-1111-1111-1111-111111111111';

  final List<RecordedRequest> requests = <RecordedRequest>[];

  /// The payload each endpoint answers with, keyed by path.
  final Map<String, Object?> responses = <String, Object?>{};

  /// Status code for a path, when the test wants a failure.
  final Map<String, int> statusCodes = <String, int>{};

  /// The client to hand to [ApiClient].
  ///
  /// An unregistered path answers `404` with the path in the body, so a test
  /// that hits an endpoint the fake does not know about fails with something
  /// readable instead of a `TypeError` from decoding `null`.
  http.Client get client => MockClient((request) async {
        final path = request.url.path.replaceFirst(RegExp(r'^/api'), '');
        requests.add(
          RecordedRequest(
            method: request.method,
            uri: request.url,
            headers: request.headers,
            body: request.body,
          ),
        );

        final status = statusCodes[path];
        if (status != null && status >= 400) {
          return _jsonResponse(
            <String, dynamic>{'error': 'boom', 'path': path},
            status,
          );
        }

        return _jsonResponse(responses[path], status ?? 200);
      });

  /// Registers the `/wish/list` payload for [wishes].
  ///
  /// [watermark] of `null` omits the field entirely, which is how an older
  /// backend behaves.
  void givenWishList(List<Wish> wishes, {bool? watermark}) {
    responses['/wish/list'] = <String, dynamic>{
      'list': wishes.map((wish) => wish.toJson()).toList(),
      if (watermark != null) 'shouldShowWatermark': watermark,
    };
  }

  /// Registers a bare `/comment/list` payload for [wishId].
  void givenCommentList(String wishId, List<Comment> comments) {
    responses['/comment/list'] = <String, dynamic>{
      'wishId': wishId,
      'commentList': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  /// Registers a `/comment/create` response.
  void givenCreatedComment(Comment comment) {
    responses['/comment/create'] = comment.toJson();
  }

  /// Registers a `/chat/status` response.
  void givenChatStatus({required bool available, bool unread = false}) {
    responses['/chat/status'] = <String, dynamic>{
      'chatAvailable': available,
      'hasUnread': unread,
    };
  }

  /// Every request whose path is [path].
  Iterable<RecordedRequest> requestsTo(String path) =>
      requests.where((request) => request.path == path);

  /// The single request to [path], or a readable failure.
  RecordedRequest requestTo(String path) {
    final matching = requestsTo(path).toList();
    if (matching.length != 1) {
      throw StateError(
        'expected exactly one request to $path, saw ${matching.length}: '
        '$requests',
      );
    }
    return matching.single;
  }

  static http.Response _jsonResponse(Object? payload, int status) {
    // A registered `null` means "this endpoint returns nothing".
    final body = payload ?? <String, dynamic>{};
    return http.Response(
      jsonEncode(body),
      status,
      headers: const <String, String>{'content-type': 'application/json'},
    );
  }
}

/// Builds a [WishModel] already holding [wishes], with the device id pinned.
///
/// Pinned via [UUIDManager.setCachedForTest] rather than mocked
/// `SharedPreferences`, so the id the tests reason about is the same one the
/// SDK would produce on a device.
Future<WishModel> seededModel(
  FakeWishKitApi api, {
  List<Wish> wishes = const [],
  bool? watermark,
}) async {
  UUIDManagerStore.pin(FakeWishKitApi.userUuid);

  api.givenWishList(wishes, watermark: watermark);
  final model = WishModel(
    apiClient: ApiClient(
      apiKey: 'test-api-key',
      client: api.client,
      baseUrl: 'https://api.test.local/api',
    ),
  );
  await model.fetchList();
  return model;
}

/// Pins [UUIDManager]'s cached id for the duration of a test.
///
/// [UUIDManager.setCachedForTest] sidesteps `SharedPreferences`, which throws
/// `MissingPluginException` under `flutter test`. Pinning the in-memory cache
/// keeps the test fast and deterministic, and [clear] puts it back so one test's
/// id cannot leak into the next.
abstract final class UUIDManagerStore {
  static String? _pinned;

  /// Whether [clear] is needed, for a `tearDown`.
  static bool get isPinned => _pinned != null;

  static String pin(String uuid) {
    _pinned = uuid;
    UUIDManager.setCachedForTest(uuid);
    return uuid;
  }

  static void clear() {
    _pinned = null;
    UUIDManager.clearCache();
  }
}



import '../models/wish.dart';
import 'api_client.dart';

/// The `/wish/list` response.
///
/// The server sends more than just the list: [shouldShowWatermark] is the
/// plan-level branding switch, and the Flutter SDK used to drop it on the
/// floor. That is a compliance bug for any paid plan, so it is parsed and
/// threaded through to the board.
class ListWishResponse {
  final List<Wish> list;

  /// Whether the "Powered by WishKit" watermark must be rendered.
  ///
  /// `null` when the server did not send the field at all, which is how an
  /// older backend behaves. Treated as `false` — showing a watermark the
  /// server did not ask for is a smaller problem than hiding one it did, and
  /// the server is authoritative the moment it starts sending the field.
  final bool? shouldShowWatermark;

  const ListWishResponse({required this.list, this.shouldShowWatermark});

  factory ListWishResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['list'] as List<dynamic>? ?? const [];
    final watermark = json['shouldShowWatermark'] ?? json['should_show_watermark'];
    return ListWishResponse(
      list: raw
          .whereType<Map<String, dynamic>>()
          .map(Wish.fromJson)
          .toList(growable: false),
      shouldShowWatermark: watermark is bool ? watermark : null,
    );
  }
}

/// API methods for wishes.
class WishApi {
  final ApiClient _client;

  WishApi(this._client);

  /// Fetches all wishes, plus the plan-level branding switch.
  Future<ApiResult<ListWishResponse>> fetchList() {
    return _client.get<ListWishResponse>(
      '/wish/list',
      (json) => ListWishResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Creates a new wish.
  Future<ApiResult<void>> create(CreateWishRequest request) {
    return _client.postVoid('/wish/create', request.toJson());
  }

  /// Votes for a wish.
  Future<ApiResult<void>> vote(VoteWishRequest request) {
    return _client.postVoid('/wish/vote', request.toJson());
  }

  /// Removes a vote from a wish.
  ///
  /// A dedicated `/wish/unvote` endpoint, which the iOS SDK does not have — it
  /// reuses `/wish/vote` with a `-1` delta. Both work against the same backend;
  /// this one is a single round-trip and cannot drift a count by two.
  Future<ApiResult<void>> removeVote(VoteWishRequest request) {
    return _client.postVoid('/wish/unvote', request.toJson());
  }
}

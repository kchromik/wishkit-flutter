import '../models/wish.dart';
import 'api_client.dart';

/// API methods for wishes.
class WishApi {
  final ApiClient _client;

  WishApi(this._client);

  /// Fetches all wishes.
  Future<ApiResult<List<Wish>>> fetchList() async {
    return _client.get<List<Wish>>(
      '/wish/list',
      (json) {
        final map = json as Map<String, dynamic>;
        final list = map['list'] as List<dynamic>;
        return list
            .map((e) => Wish.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Creates a new wish.
  Future<ApiResult<void>> create(CreateWishRequest request) async {
    return _client.postVoid(
      '/wish/create',
      request.toJson(),
    );
  }

  /// Votes for a wish.
  Future<ApiResult<void>> vote(VoteWishRequest request) async {
    return _client.postVoid(
      '/wish/vote',
      request.toJson(),
    );
  }

  /// Removes a vote from a wish.
  Future<ApiResult<void>> removeVote(VoteWishRequest request) async {
    return _client.postVoid(
      '/wish/unvote',
      request.toJson(),
    );
  }
}

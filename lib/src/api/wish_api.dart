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
        final list = json as List<dynamic>;
        return list
            .map((e) => Wish.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Creates a new wish.
  Future<ApiResult<Wish>> create(CreateWishRequest request) async {
    return _client.post<Wish>(
      '/wish/create',
      request.toJson(),
      (json) => Wish.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Votes for a wish.
  Future<ApiResult<Wish>> vote(VoteWishRequest request) async {
    return _client.post<Wish>(
      '/wish/vote',
      request.toJson(),
      (json) => Wish.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Removes a vote from a wish.
  Future<ApiResult<Wish>> removeVote(VoteWishRequest request) async {
    return _client.post<Wish>(
      '/wish/unvote',
      request.toJson(),
      (json) => Wish.fromJson(json as Map<String, dynamic>),
    );
  }
}

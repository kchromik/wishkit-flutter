import '../models/comment.dart';
import 'api_client.dart';

/// API methods for comments.
class CommentApi {
  final ApiClient _client;

  CommentApi(this._client);

  /// Creates a new comment.
  Future<ApiResult<Comment>> create(CreateCommentRequest request) async {
    return _client.post<Comment>(
      '/comment/create',
      request.toJson(),
      (json) => Comment.fromJson(json as Map<String, dynamic>),
    );
  }
}

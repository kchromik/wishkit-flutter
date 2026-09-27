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

  /// Fetches every comment on a wish, newest first.
  ///
  /// Port of the ordering iOS gets from the server. The server's order has not
  /// been guaranteed across endpoints, and the detail view reads this list top
  /// to bottom, so a thread that came back oldest-first was a scrolling
  /// experience nobody chose. Sorting here means a server that reorders the
  /// array — a paging change, a replica lag — cannot silently invert the
  /// thread.
  Future<ApiResult<List<Comment>>> fetchForWish(String wishId) async {
    final result = await _client.get<List<Comment>>(
      '/comment/list?wishId=$wishId',
      (json) => _parseList(json),
    );
    return result;
  }

  /// Reads a list payload that may be bare or wrapped.
  ///
  /// The create endpoint returns the comment object itself, the list endpoint
  /// returns `{"commentList": [...]}`, and a third deployment returns a bare
  /// array. Accepting all three is cheaper than a support ticket.
  static List<Comment> _parseList(dynamic json) {
    final raw = switch (json) {
      final Map<String, dynamic> map =>
        (map['commentList'] ?? map['comment_list'] ?? map['list']) as List?,
      final List<dynamic> list => list,
      _ => null,
    };

    final comments = (raw ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();

    comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return comments;
  }
}

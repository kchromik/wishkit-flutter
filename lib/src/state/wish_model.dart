import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/comment_api.dart';
import '../api/wish_api.dart';
import '../manager/uuid_manager.dart';
import '../models/comment.dart';
import '../models/wish.dart';
import '../utilities/logger.dart';
import '../utilities/wish_filtering.dart';

/// The wish data itself: what the server returned, and the writes against it.
///
/// Split out of the old monolithic `WishProvider` to mirror iOS's `WishModel`,
/// and — more importantly — to keep *filtering* out of the data layer.
/// `WishlistViewModel` decides what the user sees; this class never does.
///
/// The write actions are injectable, so a test can exercise the state machine
/// without a network and a host can intercept a mutation.
class WishModel extends ChangeNotifier {
  final ApiClient _apiClient;
  final WishApi _wishApi;
  final CommentApi _commentApi;

  final Future<bool> Function(CreateWishRequest)? _createWishAction;
  final Future<bool> Function(CreateCommentRequest)? _addCommentAction;

  List<Wish> _wishes = const [];
  bool _isLoading = false;
  bool _hasFetched = false;
  String? _error;
  String? _currentUserUuid;
  bool _shouldShowWatermark = false;

  WishModel({
    required ApiClient apiClient,
    Future<bool> Function(CreateWishRequest)? createWishAction,
    Future<bool> Function(CreateCommentRequest)? addCommentAction,
  })  : _apiClient = apiClient,
        _wishApi = WishApi(apiClient),
        _commentApi = CommentApi(apiClient),
        _createWishAction = createWishAction,
        _addCommentAction = addCommentAction;

  /// The underlying client, so the view models that own the writes can reach it
  /// without duplicating the wiring.
  ApiClient get apiClient => _apiClient;

  CommentApi get commentApi => _commentApi;

  // -----------------------------------------------------------------------
  // Reads
  // -----------------------------------------------------------------------

  /// Every wish, vote-count sorted.
  List<Wish> get all => _wishes;

  bool get isLoading => _isLoading;

  /// Distinguishes "the list is empty" from "nothing has been fetched yet",
  /// which is the difference between an empty state and a spinner.
  bool get hasFetched => _hasFetched;

  String? get error => _error;

  /// The device-local user id, or `null` before the first fetch.
  String? get currentUserUuid => _currentUserUuid;

  /// Whether the "Powered by WishKit" watermark must be rendered.
  ///
  /// Server-controlled and plan-level. The Flutter SDK used to discard this
  /// field, so a paid plan had its watermark suppressed from the app.
  bool get shouldShowWatermark => _shouldShowWatermark;

  /// Whether the current user has voted for [wish].
  bool hasVoted(Wish wish) {
    final uuid = _currentUserUuid;
    if (uuid == null) return false;
    return wish.hasUserVoted(uuid);
  }

  /// The buckets the board filters on, recomputed from the current list.
  WishFilteringLists get lists =>
      WishFiltering.bucketize(_wishes, currentUserUuid: _currentUserUuid);

  // -----------------------------------------------------------------------
  // Writes
  // -----------------------------------------------------------------------

  /// Fetches the whole list.
  ///
  /// A failure leaves the previous list in place rather than clearing it: a
  /// user who scrolls away and back should not lose the board they were
  /// reading because a refresh timed out.
  Future<bool> fetchList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _currentUserUuid ??= await UUIDManager.getUUID();

    final result = await _wishApi.fetchList();

    if (result.isSuccess) {
      final response = result.data!;
      _wishes = List.of(response.list)
        ..sort((a, b) => b.voteCount.compareTo(a.voteCount));
      // An absent field means the server is not tracking it, which is not the
      // same as saying "no". Keeping the last known value avoids the watermark
      // flickering off on every fetch against an older backend.
      _shouldShowWatermark =
          response.shouldShowWatermark ?? _shouldShowWatermark;
      _logFetchDiagnostics();
    } else {
      _error = result.error?.message;
    }

    _isLoading = false;
    _hasFetched = true;
    notifyListeners();
    return result.isSuccess;
  }

  /// Creates a wish and refreshes so the new row carries the server's ids.
  Future<bool> createWish(CreateWishRequest request) async {
    _isLoading = true;
    notifyListeners();

    final created = _createWishAction != null
        ? await _createWishAction!(request)
        : (await _wishApi.create(request)).isSuccess;

    _isLoading = false;

    if (created) {
      await fetchList();
      return true;
    }

    notifyListeners();
    return false;
  }

  /// Adds a comment and refreshes.
  Future<bool> addComment(String wishId, String description) async {
    final request = CreateCommentRequest(
      wishId: wishId,
      description: description,
    );

    final added = _addCommentAction != null
        ? await _addCommentAction!(request)
        : (await _commentApi.create(request)).isSuccess;

    if (!added) {
      notifyListeners();
      return false;
    }

    await fetchList();
    return true;
  }

  /// Inserts an already-created comment at the head of a wish's thread.
  ///
  /// Used by the detail view, which has the server's response in hand and
  /// should not pay for a full refetch to show one new bubble.
  void insertComment(String wishId, Comment comment) {
    final index = _wishes.indexWhere((w) => w.id == wishId);
    if (index < 0) return;
    _wishes[index] = _wishes[index].copyWith(
      comments: [comment, ..._wishes[index].comments],
    );
    notifyListeners();
  }

  /// Votes for a wish.
  ///
  /// Returns success rather than throwing: a failed vote is an expected
  /// outcome the view has to render, not an exceptional one.
  Future<bool> vote(String wishId) async {
    final result = await _wishApi.vote(VoteWishRequest(wishId: wishId));
    if (!result.isSuccess) _error = result.error?.message;
    return result.isSuccess;
  }

  /// Takes a vote back.
  Future<bool> removeVote(String wishId) async {
    final result = await _wishApi.removeVote(VoteWishRequest(wishId: wishId));
    if (!result.isSuccess) _error = result.error?.message;
    return result.isSuccess;
  }

  /// Creates a comment and returns the server's copy, or `null`.
  ///
  /// The caller decides whether to insert it, so the detail view can show the
  /// new bubble immediately without a refetch.
  Future<Comment?> createComment({
    required String wishId,
    required String description,
  }) async {
    final result = await _commentApi.create(
      CreateCommentRequest(wishId: wishId, description: description),
    );
    if (!result.isSuccess) {
      _error = result.error?.message;
      return null;
    }
    return result.data;
  }

  /// Fetches a wish's comment thread, newest first, and replaces the copy the
  /// board is holding.
  ///
  /// The detail screen calls this on open so a thread that gained replies since
  /// the list fetch is not read from a stale snapshot.
  Future<List<Comment>> fetchComments(String wishId) async {
    final result = await _commentApi.fetchForWish(wishId);
    if (!result.isSuccess) {
      _error = result.error?.message;
      notifyListeners();
      return const [];
    }

    _replaceComments(wishId, result.data ?? const []);
    return result.data ?? const [];
  }

  /// Replaces a wish's thread, keeping the id stable for widget keys.
  void _replaceComments(String wishId, List<Comment> comments) {
    final index = _wishes.indexWhere((w) => w.id == wishId);
    if (index < 0) return;
    _wishes[index] = _wishes[index].copyWith(comments: comments);
    notifyListeners();
  }

  /// Clears the error state.
  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _logFetchDiagnostics() {
    if (!WishKitLogger.isEnabled) return;

    final counts = <String, int>{};
    for (final wish in _wishes) {
      counts[wish.state.name] = (counts[wish.state.name] ?? 0) + 1;
    }
    WishKitLogger.log(
      'fetched ${_wishes.length} wishes; states $counts; '
      'user ${_currentUserUuid ?? 'none'}',
    );
    if (_wishes.isNotEmpty) {
      WishKitLogger.log('sample wish owner ${_wishes.first.userUUID}');
    }
  }
}

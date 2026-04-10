import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/wish_api.dart';
import '../api/comment_api.dart';
import '../manager/uuid_manager.dart';
import '../models/wish.dart';
import '../models/wish_state.dart';
import '../models/comment.dart';

/// State management for wishes.
class WishProvider extends ChangeNotifier {
  final WishApi _wishApi;
  final CommentApi _commentApi;

  List<Wish> _wishes = [];
  bool _isLoading = false;
  bool _hasFetched = false;
  String? _error;
  String? _currentUserUUID;

  WishProvider({
    required ApiClient apiClient,
  })  : _wishApi = WishApi(apiClient),
        _commentApi = CommentApi(apiClient);

  // Getters
  List<Wish> get wishes => _wishes;
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;
  String? get error => _error;

  /// All wishes.
  List<Wish> get all => _wishes;

  /// Wishes filtered by pending state (only current user's own wishes, like iOS).
  List<Wish> get pendingList => _wishes
      .where((w) =>
          w.state == WishState.pending &&
          w.userUUID.toLowerCase() == _currentUserUUID?.toLowerCase())
      .toList();

  /// Wishes filtered by in-review state (includes approved, like iOS).
  List<Wish> get inReviewList => _wishes
      .where((w) =>
          w.state == WishState.inReview || w.state == WishState.approved)
      .toList();

  /// Wishes filtered by planned state.
  List<Wish> get plannedList =>
      _wishes.where((w) => w.state == WishState.planned).toList();

  /// Wishes filtered by in-progress state.
  List<Wish> get inProgressList =>
      _wishes.where((w) => w.state == WishState.inProgress).toList();

  /// Wishes filtered by completed state.
  List<Wish> get completedList => _wishes
      .where((w) =>
          w.state == WishState.completed || w.state == WishState.implemented)
      .toList();

  /// Gets filtered wishes by state.
  List<Wish> getByState(WishState? state) {
    if (state == null) {
      // "All" list: concatenation of all filtered lists (like iOS).
      return [
        ...pendingList,
        ...inReviewList,
        ...plannedList,
        ...inProgressList,
        ...completedList,
      ]..sort((a, b) => b.voteCount.compareTo(a.voteCount));
    }
    if (state == WishState.pending) return pendingList;
    if (state == WishState.inReview) return inReviewList;
    if (state == WishState.completed) return completedList;
    return _wishes.where((w) => w.state == state).toList();
  }

  /// Checks if the current user has voted for a wish.
  bool hasVoted(Wish wish) {
    if (_currentUserUUID == null) return false;
    return wish.hasUserVoted(_currentUserUUID!);
  }

  /// Fetches all wishes from the API.
  Future<void> fetchList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Get current user UUID
    _currentUserUUID = await UUIDManager.getUUID();

    final result = await _wishApi.fetchList();

    if (result.isSuccess) {
      _wishes = result.data ?? [];
      // Sort by vote count descending
      _wishes.sort((a, b) => b.voteCount.compareTo(a.voteCount));

      // Debug: log state distribution to help diagnose filtering issues.
      assert(() {
        final stateCounts = <String, int>{};
        for (final w in _wishes) {
          final key = w.state.name;
          stateCounts[key] = (stateCounts[key] ?? 0) + 1;
        }
        debugPrint('[WishKit] Fetched ${_wishes.length} wishes. '
            'States: $stateCounts. '
            'Current UUID: $_currentUserUUID');
        if (_wishes.isNotEmpty) {
          debugPrint('[WishKit] Sample wish UUID: ${_wishes.first.userUUID}');
        }
        return true;
      }());
    } else {
      _error = result.error?.message;
    }

    _isLoading = false;
    _hasFetched = true;
    notifyListeners();
  }

  /// Creates a new wish.
  Future<bool> createWish(CreateWishRequest request) async {
    _isLoading = true;
    notifyListeners();

    final result = await _wishApi.create(request);

    _isLoading = false;

    if (result.isSuccess) {
      // Refresh the list to get the complete wish data from server
      await fetchList();
      return true;
    } else {
      _error = result.error?.message;
      notifyListeners();
      return false;
    }
  }

  /// Votes for a wish.
  Future<VoteResult> vote(String wishId) async {
    if (_currentUserUUID == null) {
      _currentUserUUID = await UUIDManager.getUUID();
    }

    // Check if already voted
    final wishIndex = _wishes.indexWhere((w) => w.id == wishId);
    if (wishIndex == -1) return VoteResult.error;

    final wish = _wishes[wishIndex];
    if (hasVoted(wish)) return VoteResult.alreadyVoted;

    final result = await _wishApi.vote(VoteWishRequest(wishId: wishId));

    if (result.isSuccess) {
      // Refresh the list to get updated vote counts
      await fetchList();
      return VoteResult.success;
    } else {
      _error = result.error?.message;
      notifyListeners();
      return VoteResult.error;
    }
  }

  /// Removes a vote from a wish.
  Future<VoteResult> removeVote(String wishId) async {
    if (_currentUserUUID == null) {
      _currentUserUUID = await UUIDManager.getUUID();
    }

    final wishIndex = _wishes.indexWhere((w) => w.id == wishId);
    if (wishIndex == -1) return VoteResult.error;

    final result = await _wishApi.removeVote(VoteWishRequest(wishId: wishId));

    if (result.isSuccess) {
      // Refresh the list to get updated vote counts
      await fetchList();
      return VoteResult.success;
    } else {
      _error = result.error?.message;
      notifyListeners();
      return VoteResult.error;
    }
  }

  /// Adds a comment to a wish.
  Future<bool> addComment(String wishId, String description) async {
    final request = CreateCommentRequest(
      wishId: wishId,
      description: description,
    );

    final result = await _commentApi.create(request);

    if (result.isSuccess && result.data != null) {
      // Update local wish with new comment
      final wishIndex = _wishes.indexWhere((w) => w.id == wishId);
      if (wishIndex != -1) {
        final wish = _wishes[wishIndex];
        final updatedComments = [...wish.comments, result.data!];
        _wishes[wishIndex] = wish.copyWith(comments: updatedComments);
        notifyListeners();
      }
      return true;
    } else {
      _error = result.error?.message;
      notifyListeners();
      return false;
    }
  }

  /// Clears the error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// Result of a vote operation.
enum VoteResult {
  success,
  alreadyVoted,
  error,
}

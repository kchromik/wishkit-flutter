import 'package:flutter/foundation.dart';

import '../config/configuration.dart';
import '../models/comment.dart';
import '../models/wish.dart';
import '../models/wish_state.dart';
import '../utilities/detected_language.dart';
import '../utilities/feedback_language.dart';
import '../utilities/logger.dart';
import '../utilities/translator.dart';
import '../wishkit.dart' show WishKit;
import 'wish_model.dart';

/// Why a vote was refused.
///
/// Port of iOS's two enforced vote guards plus the configuration-driven undo
/// path. The view turns one of these into the exact localized copy from the
/// iOS `.strings` files.
enum VoteOutcome {
  /// The vote was recorded.
  success,

  /// A vote was taken back.
  voteRemoved,

  /// The current user already voted and `allowUndoVote` is off.
  alreadyVoted,

  /// The wish is completed or implemented.
  completedWish,

  /// The request failed.
  error,
}

/// Screen state for one wish's detail view.
///
/// Port of iOS's `DetailWishViewModel`, plus the translation affordance from
/// `WishTranslateSection+iOS.swift`. The vote and comment actions are injected
/// so the guards and the optimistic-update paths can be tested without a
/// network.
class DetailWishViewModel extends ChangeNotifier {
  final String _wishId;
  final String _userUuid;
  final String _ownerUuid;
  final String _appLanguage;
  final String? _appScript;

  /// Both vote actions report success as a bool rather than by throwing.
  ///
  /// A failed vote is an expected outcome, not an exception: it becomes
  /// [VoteOutcome.error] and the optimistic count is reverted. Throwing would
  /// force every call site to wrap the same try/catch.
  final Future<bool> Function(String wishId) _voteAction;
  final Future<bool> Function(String wishId) _unvoteAction;
  final Future<Comment?> Function(CreateCommentRequest) _createCommentAction;
  final WishKitTranslator? _translator;

  final String _title;
  final String _description;
  final WishState _state;
  final Wish _wish;

  /// Optimistic vote count.
  ///
  /// Starts at the server's value and moves by ±1 the instant the button is
  /// tapped. A round-trip-refetch-and-rebuild is what made voting feel broken
  /// on a slow connection; the server value is reconciled on the next fetch.
  late int _voteCount;
  bool _hasVoted;

  String _newComment = '';
  bool _isLoading = false;
  String? _error;

  /// Translation state.
  ///
  /// `null` until the user asks for a translation, so nothing is paid for
  /// unless the affordance is tapped.
  String? _translatedTitle;
  String? _translatedDescription;
  bool _isShowingTranslation = false;
  bool _isTranslating = false;
  DetectedLanguage? _detected;

  DetailWishViewModel({
    required String wishId,
    required Wish wish,
    required String userUuid,
    required String appLanguage,
    String? appScript,
    required Future<bool> Function(String wishId) onVote,
    required Future<bool> Function(String wishId) onUnvote,
    required Future<Comment?> Function(CreateCommentRequest) onCreateComment,
    WishKitTranslator? translator,
  }) : assert(
          wishId == wish.id,
          'wishId and wish.id disagree; the vote would land on the wrong wish',
        ),
        _wishId = wishId,
        _userUuid = userUuid,
        _ownerUuid = wish.userUUID,
        _appLanguage = appLanguage,
        _appScript = appScript,
        _voteAction = onVote,
        _unvoteAction = onUnvote,
        _createCommentAction = onCreateComment,
        _translator = translator,
        _title = wish.title,
        _description = wish.description,
        _state = wish.state,
        _wish = wish,
        _voteCount = wish.voteCount,
        _hasVoted = userUuid.isNotEmpty && wish.hasUserVoted(userUuid);

  String get title => _isShowingTranslation && _translatedTitle != null
      ? _translatedTitle!
      : _title;

  String get description => _isShowingTranslation && _translatedDescription != null
      ? _translatedDescription!
      : _description;

  /// The untranslated original, which is what "See original" restores.
  String get originalTitle => _title;
  String get originalDescription => _description;

  WishState get state => _state;

  /// The wish this view model was built from.
  ///
  /// Exposed so a list can decide whether its copy has gone stale by identity.
  /// The view model snapshots its inputs at construction rather than watching
  /// them, so a caller that swaps the `Wish` needs a new instance.
  Wish get wish => _wish;

  int get voteCount => _voteCount;
  bool get hasVoted => _hasVoted;
  String get newComment => _newComment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isTranslating => _isTranslating;
  bool get isShowingTranslation => _isShowingTranslation;

  /// Whether a "See translation" / "See original" toggle should be drawn.
  ///
  /// False when the host wired no translator — the same outcome as iOS on a
  /// system older than iOS 18, where Apple's Translation framework is
  /// unavailable and `WishTranslateSection` is not compiled in at all.
  bool get canTranslate => _translator != null && (_title + _description).trim().isNotEmpty;

  /// The detected feedback language, for logging. `null` when detection was not
  /// confident.
  DetectedLanguage? get detected => _detected;

  // -----------------------------------------------------------------------
  // Voting
  // -----------------------------------------------------------------------

  /// Votes, or takes the vote back when [WishKit.config.allowUndoVote] is on.
  ///
  /// The two guards run before any optimistic update, so a refused vote never
  /// makes the button look like it worked, and in the same order iOS checks
  /// them: a shipped wish is reported as shipped even if the user has already
  /// voted for it.
  ///
  /// There is deliberately **no** own-wish guard. iOS carries the
  /// `youCanNotVoteForYourOwnWish` string and an `.none` alert reason, but never
  /// sets either from the vote path — the string is unreachable there. Blocking
  /// own-wish votes here would be a restriction the iOS SDK does not impose.
  /// [isOwnWish] is still exposed so a host that wants the restriction can add
  /// it without re-deriving ownership.
  Future<VoteOutcome> toggleVote() async {
    if (_state == WishState.completed || _state == WishState.implemented) {
      return VoteOutcome.completedWish;
    }
    if (_hasVoted && !WishKit.config.allowUndoVote) {
      return VoteOutcome.alreadyVoted;
    }

    return _hasVoted ? removeVote() : vote();
  }

  /// Votes.
  ///
  /// The count and the button move immediately and are reverted if the request
  /// fails. A round-trip-refetch-and-rebuild is what made voting feel broken on
  /// a slow connection; the server value is reconciled on the next fetch.
  Future<VoteOutcome> vote() async {
    if (_hasVoted) return VoteOutcome.alreadyVoted;

    _hasVoted = true;
    _voteCount += 1;
    _error = null;
    _isVoting = true;
    notifyListeners();

    var ok = false;
    try {
      ok = await _voteAction(_wishId);
    } on Object catch (error) {
      // An action that throws is treated exactly like one that returns false:
      // the user sees the same "something went wrong" and the same revert.
      _error = error.toString();
      WishKitLogger.error('vote failed: $error');
    }

    if (!ok) {
      _hasVoted = false;
      _voteCount -= 1;
    }

    _isVoting = false;
    notifyListeners();
    return ok ? VoteOutcome.success : VoteOutcome.error;
  }

  /// Takes the vote back.
  Future<VoteOutcome> removeVote() async {
    if (!_hasVoted) return VoteOutcome.error;

    _hasVoted = false;
    _voteCount -= 1;
    _error = null;
    _isVoting = true;
    notifyListeners();

    var ok = false;
    try {
      ok = await _unvoteAction(_wishId);
    } on Object catch (error) {
      _error = error.toString();
      WishKitLogger.error('unvote failed: $error');
    }

    if (!ok) {
      _hasVoted = true;
      _voteCount += 1;
    }

    _isVoting = false;
    notifyListeners();
    return ok ? VoteOutcome.voteRemoved : VoteOutcome.error;
  }

  /// Whether a vote is in flight.
  bool get isVoting => _isVoting;

  bool _isVoting = false;

  /// Whether the vote can be taken back.
  ///
  /// Read live so a host that flips `allowUndoVote` at runtime takes effect on
  /// the next tap.
  bool get allowUndoVote => WishKit.config.allowUndoVote;

  /// Whether the current user authored this wish.
  ///
  /// Not enforced by [toggleVote]; see its docs. Useful for a host that wants
  /// to hide the vote button on your own feedback.
  bool get isOwnWish =>
      _userUuid.isNotEmpty &&
      _userUuid.toLowerCase() == _ownerUuid.toLowerCase();

  // -----------------------------------------------------------------------
  // Comments
  // -----------------------------------------------------------------------

  void setNewComment(String value) {
    if (_newComment == value) return;
    _newComment = value;
    notifyListeners();
  }

  /// Submits [newComment] and returns the created comment, or `null`.
  ///
  /// The caller inserts the comment so the board's copy of the wish stays the
  /// single source of truth — the same split iOS uses, where the detail view
  /// owns its thread and the model owns the wish.
  Future<Comment?> submitComment() async {
    final body = _newComment.trim();
    if (body.isEmpty) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final comment = await _createCommentAction(
        CreateCommentRequest(wishId: _wishId, description: body),
      );
      if (comment != null) _newComment = '';
      return comment;
    } on Object catch (error) {
      _error = error.toString();
      WishKitLogger.error('comment submit failed: $error');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------------------
  // Translation
  // -----------------------------------------------------------------------

  /// Whether the affordance should be offered for this wish.
  ///
  /// Mirrors `WishTranslateSection.init`: `always` offers it unconditionally,
  /// `hide` never does, and `automatic` offers it only when the feedback's
  /// language differs from the app's.
  bool shouldOfferTranslation(TranslateButton mode) {
    if (_translator == null) return false;
    return switch (mode) {
      TranslateButton.hide => false,
      TranslateButton.always => true,
      TranslateButton.automatic => FeedbackLanguage.differsFromAppLanguage(
          '$_title $_description',
          appLanguage: _appLanguage,
          appScript: _appScript,
        ),
    };
  }

  /// Toggles between the original and the translation, translating on first
  /// request.
  Future<void> toggleTranslation() async {
    if (_isShowingTranslation) {
      _isShowingTranslation = false;
      notifyListeners();
      return;
    }

    if (_translatedTitle == null) await _translate();

    _isShowingTranslation = _translatedTitle != null;
    notifyListeners();
  }

  Future<void> _translate() async {
    final translator = _translator;
    if (translator == null) return;

    // Detect once and reuse, so the hint shown to the host and the source
    // language handed to the translator can never disagree.
    final combined = '$_title $_description';
    _detected = FeedbackLanguage.dominantLanguage(combined);
    final source = _detected?.tag;

    _isTranslating = true;
    notifyListeners();

    try {
      final results = await translator(<WishKitTranslationRequest>[
        WishKitTranslationRequest(
          sourceText: _title,
          clientIdentifier: 'title',
          targetLanguage: _appLanguage,
          sourceLanguage: source,
        ),
        if (_description.isNotEmpty)
          WishKitTranslationRequest(
            sourceText: _description,
            clientIdentifier: 'description',
            targetLanguage: _appLanguage,
            sourceLanguage: source,
          ),
      ]);

      for (final result in results) {
        switch (result.clientIdentifier) {
          case 'title':
            _translatedTitle = result.targetText;
          case 'description':
            _translatedDescription = result.targetText;
        }
      }
    } on Object catch (error) {
      // A failing translator must not break the board: the wish simply stays
      // in its original language.
      WishKitLogger.error('translation failed: $error');
      _translatedTitle = null;
      _translatedDescription = null;
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  /// Drops the translation cache, e.g. when the app's language changed.
  void invalidateTranslation() {
    _translatedTitle = null;
    _translatedDescription = null;
    _isShowingTranslation = false;
    _isTranslating = false;
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Convenience
  // -----------------------------------------------------------------------

  /// Builds a view model wired to [model]'s APIs.
  ///
  /// The wish list and the detail screen both want the same guards, the same
  /// optimistic vote and the same translation toggle, so they share one
  /// construction path. Hand-writing the three action closures at each call
  /// site is how the list and the detail screen ended up disagreeing about
  /// whether a vote on a shipped wish is allowed.
  factory DetailWishViewModel.forWish(
    Wish wish, {
    required WishModel model,
    required String appLanguage,
    String? appScript,
  }) {
    return DetailWishViewModel(
      wishId: wish.id,
      wish: wish,
      userUuid: model.currentUserUuid ?? '',
      appLanguage: appLanguage,
      appScript: appScript,
      onVote: model.vote,
      onUnvote: model.removeVote,
      onCreateComment: (request) => model.createComment(
        wishId: request.wishId,
        description: request.description,
      ),
      translator: WishKit.config.translator,
    );
  }
}

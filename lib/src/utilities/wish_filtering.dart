import '../models/wish.dart';
import '../models/wish_state.dart';

/// The buckets the feedback board is split into.
///
/// A direct port of iOS's `LocalWishState`. The three synthetic buckets
/// ([all], [open], [closed]) are what the segmented control shows by default;
/// a [byState] bucket exists for hosts that opted into the finer-grained
/// Flutter-only `visibleStates` control.
///
/// iOS calls the fourth case `library`; Dart reserves that word, so it is
/// `byState` here.
///
/// Modelled as a sealed class rather than an enum because a bucket has to carry
/// a `WishState` payload, and Dart's enum values cannot. Equality is by value,
/// so `WishFilter.byState(s) == WishFilter.byState(s)` and segment lists behave
/// the way a plain enum would.
sealed class WishFilter {
  const WishFilter._();

  /// Everything the user can see, vote-count sorted.
  static const WishFilter all = _Bucket('all');

  /// The user's own pending feedback plus all actively worked-on feedback.
  static const WishFilter open = _Bucket('open');

  /// Shipped feedback.
  static const WishFilter closed = _Bucket('closed');

  /// The two buckets the segmented control shows by default.
  static const List<WishFilter> boardSegments = <WishFilter>[open, closed];

  /// A bucket holding one raw [WishState].
  static WishFilter byState(WishState state) => _StateBucket(state);

  /// The raw state behind a [byState] bucket, `null` for a synthetic one.
  WishState? get state => null;

  /// Whether this is one raw state rather than a synthetic bucket.
  bool get isStateBucket => false;

  /// Stable identity for widget keys and debug output.
  String get key;

  @override
  bool operator ==(Object other) =>
      other is WishFilter && other.runtimeType == runtimeType && other.key == key;

  @override
  int get hashCode => Object.hash(runtimeType, key);
}

/// A bucket that is not tied to one raw state.
final class _Bucket extends WishFilter {
  const _Bucket(this.key) : super._();

  @override
  final String key;

  @override
  String toString() => 'WishFilter.$key';
}

/// A bucket for one raw [WishState].
final class _StateBucket extends WishFilter {
  const _StateBucket(this.state) : super._();

  @override
  final WishState state;

  @override
  bool get isStateBucket => true;

  @override
  String get key => 'state:${state.name}';

  @override
  String toString() => 'WishFilter.byState(${state.name})';
}

/// The pre-bucketed wish lists a [WishFilter] reads from.
///
/// Port of iOS's `WishFilteringLists`. Produced by [WishFiltering.bucketize]
/// rather than filtered on demand, because the board filters on every tab
/// switch and every rebuild.
class WishFilteringLists {
  /// Every wish the user may see — pending, approved and completed, vote-count
  /// sorted. This is what a hidden segmented control shows, so it already has
  /// rejected and other users' pending feedback removed.
  final List<Wish> all;

  /// The current user's own pending feedback, nothing else.
  final List<Wish> pending;

  /// All actively worked-on feedback: approved, in review, planned and in
  /// progress.
  final List<Wish> approved;

  /// Completed and implemented feedback.
  final List<Wish> completed;

  const WishFilteringLists({
    required this.all,
    required this.pending,
    required this.approved,
    required this.completed,
  });

  /// The buckets before anything has been fetched.
  static const WishFilteringLists empty = WishFilteringLists(
    all: <Wish>[],
    pending: <Wish>[],
    approved: <Wish>[],
    completed: <Wish>[],
  );
}

/// Which bucket a single wish belongs to.
///
/// Port of `WishModel.bucket(for:currentUserUUID:)`.
enum WishBucket {
  pending,
  approved,
  completed,

  /// Not shown in any bucket: another user's pending feedback, a rejected
  /// wish, or a state this SDK version does not know about.
  excluded,
}

/// Turns a raw wish list into the buckets the board filters on.
///
/// Pure functions with no Flutter or API dependency, so the parity rules can be
/// tested directly.
abstract final class WishFiltering {
  /// Which bucket [wish] belongs to.
  ///
  /// [currentUserUuid] decides whether pending feedback is the user's own.
  static WishBucket bucket(Wish wish, String? currentUserUuid) {
    switch (wish.state) {
      case WishState.pending:
        // Pending should only surface your own requests. Other users' pending
        // feedback is excluded rather than shown in the open bucket.
        return _isSameUser(wish, currentUserUuid)
            ? WishBucket.pending
            : WishBucket.excluded;
      case WishState.completed:
      case WishState.implemented:
        return WishBucket.completed;
      case WishState.rejected:
        // Rejected is intentionally hidden from every bucket.
        return WishBucket.excluded;
      case WishState.approved:
      case WishState.inReview:
      case WishState.planned:
      case WishState.inProgress:
        // The "open" bucket intentionally groups all active non-pending work,
        // which is why this is not the same as a raw `planned` filter.
        return WishBucket.approved;
    }
  }

  /// Splits [wishes] into the board's buckets, vote-count sorted descending.
  ///
  /// Port of `WishModel.makeFilteredLists(from:currentUserUUID:)`.
  static WishFilteringLists bucketize(
    List<Wish> wishes, {
    String? currentUserUuid,
  }) {
    final sorted = [...wishes]
      ..sort((a, b) => b.voteCount.compareTo(a.voteCount));

    final all = <Wish>[];
    final pending = <Wish>[];
    final approved = <Wish>[];
    final completed = <Wish>[];

    for (final wish in sorted) {
      switch (bucket(wish, currentUserUuid)) {
        case WishBucket.pending:
          pending.add(wish);
          all.add(wish);
        case WishBucket.approved:
          approved.add(wish);
          all.add(wish);
        case WishBucket.completed:
          completed.add(wish);
          all.add(wish);
        case WishBucket.excluded:
          break;
      }
    }

    return WishFilteringLists(
      all: all,
      pending: pending,
      approved: approved,
      completed: completed,
    );
  }

  /// The wishes a [filter] shows.
  ///
  /// Port of `WishFiltering.list(from:selectedState:segmentedControlDisplay:)`.
  /// When the segmented control is hidden the board shows everything, which
  /// makes the filter irrelevant.
  static List<Wish> list(
    WishFilteringLists lists,
    WishFilter filter, {
    bool segmentedControlVisible = true,
  }) {
    if (!segmentedControlVisible) return lists.all;

    return switch (filter) {
      // Re-sorted because concatenating two already-sorted buckets can leave a
      // 9-vote pending wish above a 12-vote approved one. Matches iOS.
      _Bucket(key: 'open') => [...lists.pending, ...lists.approved]
        ..sort((a, b) => b.voteCount.compareTo(a.voteCount)),
      _Bucket(key: 'closed') => lists.completed,
      // `all`, plus any synthetic bucket added later: showing everything is the
      // safe default for a bucket with no narrower definition.
      _Bucket() => lists.all,
      _StateBucket(state: final s) => switch (s) {
          WishState.pending => lists.pending,
          // One raw state maps onto a whole bucket, mirroring the open tab.
          WishState.approved ||
          WishState.inReview ||
          WishState.planned ||
          WishState.inProgress =>
            lists.approved,
          WishState.completed || WishState.implemented => lists.completed,
          // Rejected is never shown, so an opted-in raw-state filter for it is
          // empty rather than falling back to `all`.
          WishState.rejected => const <Wish>[],
        },
    };
  }

  /// How many wishes a [filter] shows. Always read off [list] so the badge on
  /// a segment can never disagree with what tapping it produces.
  static int count(
    WishFilteringLists lists,
    WishFilter filter, {
    bool segmentedControlVisible = true,
  }) =>
      list(lists, filter, segmentedControlVisible: segmentedControlVisible)
          .length;

  /// Resolves a host's `visibleStates` into filters, dropping duplicates and
  /// keeping the host's ordering.
  ///
  /// A host that lists both `pending` and `planned` gets two segments that show
  /// the same rows, because iOS's grouping cannot be expressed finer than the
  /// bucket level. That is the host's call to make, not something to silently
  /// paper over here.
  static List<WishFilter> stateFilters(List<WishState> states) {
    final filters = <WishFilter>[];
    for (final state in states) {
      final filter = WishFilter.byState(state);
      if (filters.contains(filter)) continue;
      filters.add(filter);
    }
    return filters;
  }

  /// The segments a host's configuration asks for.
  ///
  /// [visibleStates] of `null` or empty means the iOS default, the Open/Closed
  /// pair. [includeAll] prepends the All tab, which is off by default in both
  /// SDKs.
  static List<WishFilter> segmentsFor({
    List<WishState>? visibleStates,
    bool includeAll = false,
  }) {
    if (visibleStates != null && visibleStates.isNotEmpty) {
      return <WishFilter>[
        if (includeAll) WishFilter.all,
        ...stateFilters(visibleStates),
      ];
    }
    return <WishFilter>[
      if (includeAll) WishFilter.all,
      ...WishFilter.boardSegments,
    ];
  }

  /// The segment selected when the board opens.
  ///
  /// `null` — the default — is Open, matching iOS. A host-set [defaultState]
  /// that is not on offer falls back to the first segment rather than leaving
  /// the board on a filter with no tab highlighted.
  static WishFilter initialSelection({
    List<WishState>? visibleStates,
    bool includeAll = false,
    WishState? defaultState,
  }) {
    final available = segmentsFor(
      visibleStates: visibleStates,
      includeAll: includeAll,
    );
    if (defaultState == null) return WishFilter.open;
    final wanted = WishFilter.byState(defaultState);
    return available.contains(wanted) ? wanted : available.first;
  }

  static bool _isSameUser(Wish wish, String? currentUserUuid) {
    if (currentUserUuid == null) return false;
    return wish.userUUID.toLowerCase() == currentUserUuid.toLowerCase();
  }
}

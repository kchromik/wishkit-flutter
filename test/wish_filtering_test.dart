import 'package:flutter_test/flutter_test.dart';
import 'package:wishkit/wishkit.dart';

import 'helpers/fixtures.dart';

/// Port of `WishFilteringTests` and `WishModelFilterTests`.
///
/// These are the rules that decide what a user sees, and they are the rules
/// most likely to be "simplified" by a later refactor — a rejected wish
/// creeping back into Open, or another user's pending feedback appearing under
/// your own name. Every case below is one that iOS pins.
void main() {
  const me = 'me';

  WishFilteringLists makeLists() {
    final pending = makeWish(id: 'pending', state: WishState.pending, userUuid: me);
    final approved = makeWish(id: 'approved', state: WishState.approved);
    final completed = makeWish(id: 'completed', state: WishState.completed);

    return WishFilteringLists(
      all: [pending, approved, completed],
      pending: [pending],
      approved: [approved],
      completed: [completed],
    );
  }

  group('bucket', () {
    test('pending is only yours', () {
      final own = makeWish(id: 'a', state: WishState.pending, userUuid: me);
      final other = makeWish(id: 'b', state: WishState.pending);

      expect(WishFiltering.bucket(own, me), WishBucket.pending);
      expect(WishFiltering.bucket(other, me), WishBucket.excluded);
    });

    test('pending belongs to nobody before the user id is known', () {
      // The first frame, before `UUIDManager` resolves. Showing nothing is
      // right; showing *everyone's* pending feedback is not.
      final other = makeWish(id: 'b', state: WishState.pending);
      expect(WishFiltering.bucket(other, null), WishBucket.excluded);
    });

    test('the approved bucket groups every actively-worked state', () {
      const grouped = <WishState>[
        WishState.approved,
        WishState.inReview,
        WishState.planned,
        WishState.inProgress,
      ];

      for (final state in grouped) {
        expect(
          WishFiltering.bucket(makeWish(id: state.name, state: state), me),
          WishBucket.approved,
          reason: '$state should be grouped into the approved bucket',
        );
      }
    });

    test('completed and implemented share the closed bucket', () {
      expect(
        WishFiltering.bucket(makeWish(id: 'a', state: WishState.completed), me),
        WishBucket.completed,
      );
      expect(
        WishFiltering.bucket(makeWish(id: 'b', state: WishState.implemented), me),
        WishBucket.completed,
      );
    });

    test('rejected is excluded from every bucket', () {
      expect(
        WishFiltering.bucket(makeWish(id: 'a', state: WishState.rejected), me),
        WishBucket.excluded,
      );
    });

    test('ownership is case-insensitive, because UUIDs arrive either way', () {
      final own = makeWish(id: 'a', state: WishState.pending, userUuid: 'AB-CD');
      expect(WishFiltering.bucket(own, 'ab-cd'), WishBucket.pending);
    });
  });

  group('bucketize', () {
    test('partitions the whole list the way iOS does', () {
      final ownPending =
          makeWish(id: 'ownPending', state: WishState.pending, userUuid: me, votes: 5);
      final otherPending =
          makeWish(id: 'otherPending', state: WishState.pending, votes: 7);
      final approved = makeWish(id: 'approved', state: WishState.approved, votes: 6);
      final inReview = makeWish(id: 'inReview', state: WishState.inReview, votes: 4);
      final planned = makeWish(id: 'planned', state: WishState.planned, votes: 3);
      final inProgress =
          makeWish(id: 'inProgress', state: WishState.inProgress, votes: 2);
      final completed =
          makeWish(id: 'completed', state: WishState.completed, votes: 9);
      final implemented =
          makeWish(id: 'implemented', state: WishState.implemented, votes: 8);
      final rejected = makeWish(id: 'rejected', state: WishState.rejected, votes: 1);

      final lists = WishFiltering.bucketize(
        [
          ownPending,
          otherPending,
          approved,
          inReview,
          planned,
          inProgress,
          completed,
          implemented,
          rejected,
        ],
        currentUserUuid: me,
      );

      expect(idsOf(lists.pending), ['ownPending']);
      expect(
        idsOf(lists.approved).toSet(),
        {'approved', 'inReview', 'planned', 'inProgress'},
      );
      expect(idsOf(lists.completed).toSet(), {'completed', 'implemented'});

      // The three invariants that matter, spelled out so a regression names
      // which one broke.
      expect(idsOf(lists.approved), isNot(contains('ownPending')));
      expect(idsOf(lists.approved), isNot(contains('completed')));
      expect(idsOf(lists.approved), isNot(contains('rejected')));
    });

    test('`all` excludes rejected and other users pending feedback', () {
      final lists = WishFiltering.bucketize(
        [
          makeWish(id: 'rejected', state: WishState.rejected),
          makeWish(id: 'theirs', state: WishState.pending),
          makeWish(id: 'mine', state: WishState.pending, userUuid: me),
          makeWish(id: 'done', state: WishState.completed),
        ],
        currentUserUuid: me,
      );

      expect(idsOf(lists.all).toSet(), {'mine', 'done'});
    });

    test('every bucket is vote-count sorted, descending', () {
      final lists = WishFiltering.bucketize(
        [
          makeWish(id: 'low', votes: 1),
          makeWish(id: 'high', votes: 42),
          makeWish(id: 'mid', votes: 7),
        ],
        currentUserUuid: me,
      );

      expect(idsOf(lists.all), ['high', 'mid', 'low']);
      expect(idsOf(lists.approved), ['high', 'mid', 'low']);
    });
  });

  group('list', () {
    test('returns everything when the segmented control is hidden', () {
      final lists = makeLists();
      final result = WishFiltering.list(
        lists,
        WishFilter.byState(WishState.pending),
        segmentedControlVisible: false,
      );
      expect(idsOf(result), idsOf(lists.all));
    });

    test('open merges your pending with the approved bucket, vote sorted', () {
      // The interesting case: concatenating two already-sorted buckets leaves a
      // 1-vote pending row above a 5-vote approved one. iOS re-sorts, and so
      // does this — otherwise the board's order depends on which tab you are on.
      final pending = makeWish(id: 'pending', state: WishState.pending, userUuid: me, votes: 1);
      final approvedHigh = makeWish(id: 'approvedHigh', votes: 5);
      final approvedLow = makeWish(id: 'approvedLow', votes: 0);
      final completed = makeWish(id: 'completed', state: WishState.completed, votes: 3);

      final lists = WishFilteringLists(
        all: [pending, approvedHigh, approvedLow, completed],
        pending: [pending],
        approved: [approvedHigh, approvedLow],
        completed: [completed],
      );

      final result = WishFiltering.list(
        lists,
        WishFilter.open,
        segmentedControlVisible: true,
      );

      expect(idsOf(result), ['approvedHigh', 'pending', 'approvedLow']);
      expect(idsOf(result), isNot(contains('completed')));
    });

    test('closed is the completed bucket', () {
      final lists = makeLists();
      expect(
        idsOf(WishFiltering.list(lists, WishFilter.closed)),
        idsOf(lists.completed),
      );
    });

    test('all is every visible row', () {
      final lists = makeLists();
      expect(idsOf(WishFiltering.list(lists, WishFilter.all)), idsOf(lists.all));
    });

    test('a grouped raw state maps onto the whole approved bucket', () {
      final lists = makeLists();

      for (final state in const <WishState>[
        WishState.approved,
        WishState.inReview,
        WishState.planned,
        WishState.inProgress,
      ]) {
        expect(
          idsOf(WishFiltering.list(lists, WishFilter.byState(state))),
          idsOf(lists.approved),
          reason: 'iOS cannot express these states finer than the bucket, so a '
              'host that asks for $state gets the whole group.',
        );
      }
    });

    test('a shipped raw state maps onto the completed bucket', () {
      final lists = makeLists();
      for (final state in const <WishState>[WishState.completed, WishState.implemented]) {
        expect(
          idsOf(WishFiltering.list(lists, WishFilter.byState(state))),
          idsOf(lists.completed),
        );
      }
    });

    test('a rejected raw state is empty, not a fallback to all', () {
      final lists = makeLists();
      // Falling back to `all` here would put rejected feedback on screen for
      // any host that opted it in — the exact thing the exclusion prevents.
      expect(
        WishFiltering.list(lists, WishFilter.byState(WishState.rejected)),
        isEmpty,
      );
    });
  });

  group('count', () {
    test('delegates to list, so a badge can never disagree with the rows', () {
      final lists = makeLists();

      for (final filter in <WishFilter>[
        WishFilter.all,
        WishFilter.open,
        WishFilter.closed,
        WishFilter.byState(WishState.planned),
        WishFilter.byState(WishState.rejected),
      ]) {
        expect(
          WishFiltering.count(lists, filter),
          WishFiltering.list(lists, filter).length,
          reason: 'count and list disagree for $filter',
        );
      }

      expect(WishFiltering.count(lists, WishFilter.closed), 1);
      expect(WishFiltering.count(lists, WishFilter.open), 2);
    });

    test('a hidden control counts everything', () {
      final lists = makeLists();
      expect(
        WishFiltering.count(
          lists,
          WishFilter.closed,
          segmentedControlVisible: false,
        ),
        lists.all.length,
      );
    });
  });

  group('segments', () {
    test('defaults to the Open/Closed pair, matching iOS', () {
      expect(WishFiltering.segmentsFor(), [WishFilter.open, WishFilter.closed]);
    });

    test('an empty visibleStates is the default, not an empty board', () {
      // `[]` is what a host gets from reading a config value that was never
      // set. Rendering zero segments would leave the board with no way to switch
      // buckets at all.
      expect(
        WishFiltering.segmentsFor(visibleStates: const []),
        [WishFilter.open, WishFilter.closed],
      );
    });

    test('visibleStates gives one segment per requested state, in order', () {
      final segments = WishFiltering.segmentsFor(
        visibleStates: const [WishState.inProgress, WishState.completed],
      );
      expect(segments, [
        WishFilter.byState(WishState.inProgress),
        WishFilter.byState(WishState.completed),
      ]);
    });

    test('showAllTab prepends All', () {
      final segments = WishFiltering.segmentsFor(
        visibleStates: const [WishState.completed],
        includeAll: true,
      );
      expect(segments.first, WishFilter.all);
      expect(segments.last, WishFilter.byState(WishState.completed));
    });

    test('duplicates are dropped', () {
      final segments = WishFiltering.segmentsFor(
        visibleStates: const [WishState.completed, WishState.completed],
      );
      expect(segments.length, 1);
    });
  });

  group('initialSelection', () {
    test('is Open by default', () {
      expect(
        WishFiltering.initialSelection(),
        WishFilter.open,
        reason: 'iOS opens the board on the tab where the new feedback lands.',
      );
    });

    test('honours a defaultState that is on offer', () {
      expect(
        WishFiltering.initialSelection(
          visibleStates: const [WishState.completed, WishState.inProgress],
          defaultState: WishState.inProgress,
        ),
        WishFilter.byState(WishState.inProgress),
      );
    });

    test('falls back to the first segment for a defaultState that is hidden', () {
      // Leaving the selection on a filter with no tab highlighted makes the
      // board look stuck, so the mismatch resolves in favour of what is shown.
      expect(
        WishFiltering.initialSelection(
          visibleStates: const [WishState.completed],
          defaultState: WishState.inProgress,
        ),
        WishFilter.byState(WishState.completed),
      );
    });
  });

  group('filter identity', () {
    test('synthetic buckets are distinct', () {
      expect(WishFilter.all, isNot(WishFilter.open));
      expect(WishFilter.open.hashCode, isNot(WishFilter.closed.hashCode));
      expect(WishFilter.open, WishFilter.open);
    });

    test('two raw-state buckets for the same state are equal', () {
      // Needed for `segments.contains(_selected)` in the view model to work.
      expect(
        WishFilter.byState(WishState.planned),
        WishFilter.byState(WishState.planned),
      );
      expect(
        WishFilter.byState(WishState.planned),
        isNot(WishFilter.byState(WishState.completed)),
      );
    });

    test('a raw-state bucket is not equal to a synthetic one', () {
      // The failure this guards: a state bucket comparing equal to `all` would
      // make `reconcileSelection` believe a removed tab was still selected.
      expect(
        WishFilter.byState(WishState.completed),
        isNot(WishFilter.closed),
      );
      expect(WishFilter.byState(WishState.completed).isStateBucket, isTrue);
      expect(WishFilter.closed.isStateBucket, isFalse);
      expect(WishFilter.closed.state, isNull);
    });

    test('keys are stable and unique, for widget keys and debug output', () {
      final keys = <String>{
        WishFilter.all.key,
        WishFilter.open.key,
        WishFilter.closed.key,
        for (final state in WishState.values) WishFilter.byState(state).key,
      };
      expect(keys.length, 3 + WishState.values.length);
      expect(WishFilter.byState(WishState.planned).key, 'state:planned');
    });

    test('toString names the bucket', () {
      expect(WishFilter.open.toString(), 'WishFilter.open');
      expect(
        WishFilter.byState(WishState.planned).toString(),
        'WishFilter.byState(planned)',
      );
    });
  });
}

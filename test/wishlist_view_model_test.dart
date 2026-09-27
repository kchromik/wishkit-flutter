import 'package:flutter_test/flutter_test.dart';
import 'package:wishkit/wishkit.dart';

import 'helpers/fake_api.dart';
import 'helpers/fixtures.dart';

/// Port of `WishlistViewModelTests`.
///
/// The view model holds no wish data of its own — it reads the buckets off
/// [WishModel] every time — so these tests need a model with rows in it. Since
/// the model only takes rows from the network, the list is injected through a
/// seeded [FakeWishKitApi] rather than by adding a test-only setter to the
/// model.
void main() {
  final originalConfig = WishKit.config;
  late WishModel model;
  late FakeWishKitApi api;

  setUp(() async {
    WishKit.config = WishKitConfiguration();
    api = FakeWishKitApi();
    model = await seededModel(api, wishes: [
      makeWish(id: 'a', state: WishState.approved),
      makeWish(id: 'b', state: WishState.inReview),
    ]);
  });

  tearDown(() {
    WishKit.config = originalConfig;
    model.dispose();
    UUIDManagerStore.clear();
  });

  group('with the segmented control hidden', () {
    setUp(() {
      WishKit.config.buttons.segmentedControl.display = Display.hide;
    });

    test('the board is one flat list, whatever is selected', () {
      final viewModel = WishlistViewModel(model);

      expect(viewModel.isSegmentedControlVisible, isFalse);
      expect(
        idsOf(viewModel.visibleWishes),
        idsOf(model.all),
        reason: 'a hidden control means the filter is irrelevant',
      );
    });

    test('a host-set defaultState cannot hide rows either', () {
      WishKit.config.visibleStates = [WishState.completed];
      WishKit.config.defaultState = WishState.completed;

      final viewModel = WishlistViewModel(model);
      expect(idsOf(viewModel.visibleWishes), idsOf(model.all));
    });
  });

  group('with the segmented control visible', () {
    setUp(() {
      WishKit.config.buttons.segmentedControl.display = Display.show;
    });

    test('opens on Open', () {
      expect(WishlistViewModel(model).selected, WishFilter.open);
    });

    test('a count uses the bucket, so `planned` shows the whole group', () {
      // iOS's grouping: `planned` cannot be expressed finer than the approved
      // bucket, so asking for it yields the group. The test pins that rather
      // than the friendlier number, so a "fix" has to be deliberate.
      final viewModel = WishlistViewModel(model);
      expect(viewModel.countFor(WishFilter.byState(WishState.planned)), 2);
    });

    test('a count for every segment matches what tapping it produces', () {
      final viewModel = WishlistViewModel(model);

      for (final segment in viewModel.segments) {
        viewModel.select(segment);
        expect(
          viewModel.countFor(segment),
          viewModel.visibleWishes.length,
          reason: 'badge and rows disagree for $segment',
        );
      }
    });

    test('select notifies, and re-selecting the same segment does not', () {
      final viewModel = WishlistViewModel(model);
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.select(WishFilter.closed);
      expect(notifications, 1);
      expect(viewModel.selected, WishFilter.closed);

      viewModel.select(WishFilter.closed);
      expect(
        notifications,
        1,
        reason: 'a no-op rebuild of the whole board is not free',
      );
    });

    test('select is how the board switches buckets', () async {
      // Add a completed wish and verify the closed tab shows it.
      final updated = await seededModel(api, wishes: [
        ...model.all,
        makeWish(id: 'done', state: WishState.completed),
      ]);
      model = updated;

      final viewModel = WishlistViewModel(model);

      // The open bucket has the two approved/inReview wishes from the setup.
      expect(idsOf(viewModel.visibleWishes).toSet(), {'a', 'b'});
      viewModel.select(WishFilter.closed);
      expect(idsOf(viewModel.visibleWishes), ['done']);
    });
  });

  group('reconcileSelection', () {
    test('leaves a still-offered selection alone', () {
      WishKit.config.buttons.segmentedControl.display = Display.show;
      final viewModel = WishlistViewModel(model);

      viewModel.reconcileSelection();
      expect(viewModel.selected, WishFilter.open);
    });

    test('re-points a selection whose tab the host just removed', () {
      // A host that narrows `visibleStates` at runtime would otherwise leave the
      // board filtering a segment with no tab highlighted — visibly stuck.
      WishKit.config.buttons.segmentedControl.display = Display.show;
      // Initial selection defaults to Open; to start on a specific tab the host
      // must also set `defaultState`.
      WishKit.config.visibleStates = [WishState.completed];
      WishKit.config.defaultState = WishState.completed;
      final viewModel = WishlistViewModel(model);

      expect(viewModel.selected, WishFilter.byState(WishState.completed));

      WishKit.config.visibleStates = [WishState.inProgress];
      WishKit.config.defaultState = WishState.inProgress;
      viewModel.reconcileSelection();

      expect(viewModel.segments, contains(viewModel.selected));
      expect(viewModel.selected, WishFilter.byState(WishState.inProgress));
    });

    test('notifies only when it actually moved', () {
      WishKit.config.buttons.segmentedControl.display = Display.show;
      final viewModel = WishlistViewModel(model);
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      viewModel.reconcileSelection();
      expect(notifications, 0);

      WishKit.config.visibleStates = [WishState.inProgress];
      viewModel.reconcileSelection();
      expect(notifications, 1);
    });
  });

  group('config defaults', () {
    test('the Flutter-only opt-ins are off, matching iOS behaviour', () {
      // These are additions, not parity fixes. Asserting the defaults here is
      // what makes "off unless asked" a promise rather than a hope.
      expect(WishKit.config.visibleStates, isNull);
      expect(WishKit.config.showAllTab, isFalse);
      expect(WishKit.config.defaultState, isNull);
      expect(WishKit.config.buttons.segmentedControl.display, Display.show);
    });
  });
}
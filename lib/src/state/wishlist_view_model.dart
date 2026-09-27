import 'package:flutter/foundation.dart';

import '../models/wish.dart';
import '../utilities/wish_filtering.dart';
import '../wishkit.dart' show WishKit;
import 'wish_model.dart';

/// Which bucket the board is showing.
///
/// Port of iOS's `WishlistViewModel`. Owns exactly one piece of state — the
/// selected [WishFilter] — and derives everything else from [WishModel.lists],
/// so a segment badge can never disagree with the list under it.
class WishlistViewModel extends ChangeNotifier {
  final WishModel _wishModel;
  WishFilter _selected;

  WishlistViewModel(this._wishModel)
      : _selected = WishFiltering.initialSelection(
          visibleStates: WishKit.config.visibleStates,
          includeAll: WishKit.config.showAllTab,
          defaultState: WishKit.config.defaultState,
        );

  WishFilter get selected => _selected;

  /// The buckets currently on offer.
  ///
  /// Open/Closed by default, matching iOS. A host that set `visibleStates` gets
  /// one segment per requested raw state instead, and `showAllTab` prepends
  /// All.
  List<WishFilter> get segments => WishFiltering.segmentsFor(
        visibleStates: WishKit.config.visibleStates,
        includeAll: WishKit.config.showAllTab,
      );

  /// Whether the board shows one flat list.
  bool get isSegmentedControlVisible =>
      WishKit.config.buttons.segmentedControl.isVisible;

  /// The wishes under the selected segment.
  List<Wish> get visibleWishes => WishFiltering.list(
        _wishModel.lists,
        _selected,
        segmentedControlVisible: isSegmentedControlVisible,
      );

  /// How many wishes [filter] would show. Reads through the same path as
  /// [visibleWishes] so a badge is never stale.
  int countFor(WishFilter filter) => WishFiltering.count(
        _wishModel.lists,
        filter,
        segmentedControlVisible: isSegmentedControlVisible,
      );

  void select(WishFilter filter) {
    if (_selected == filter) return;
    _selected = filter;
    notifyListeners();
  }

  /// Re-points the selection at whatever [segments] currently offers.
  ///
  /// Called when a host mutates `visibleStates` at runtime. Without this, a
  /// selection the host just removed would keep filtering an invisible segment
  /// and the board would look stuck.
  void reconcileSelection() {
    final available = segments;
    if (available.contains(_selected)) return;
    _selected = available.isEmpty ? WishFilter.open : available.first;
    notifyListeners();
  }
}

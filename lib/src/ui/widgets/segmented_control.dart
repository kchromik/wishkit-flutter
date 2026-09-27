import 'package:flutter/material.dart';

import '../../config/localization.dart';
import '../../state/wishlist_view_model.dart';
import '../../wishkit.dart';

/// The segment row above the board: Open / Closed by default.
///
/// Port of `WishlistSegmentedControlSectionView`, including the per-segment
/// live count. Counts are read through [WishlistViewModel.countFor], the same
/// path `visibleWishes` uses, so a badge can never disagree with the list it
/// sits above.
///
/// Rendered as a horizontally scrollable row of chips rather than a
/// `SegmentedButton` because the Flutter-only `visibleStates` option can put
/// more segments on screen than fit, and a `SegmentedButton` clips instead of
/// scrolling.
class WishlistSegmentedControl extends StatelessWidget {
  const WishlistSegmentedControl({
    super.key,
    required this.viewModel,
  });

  final WishlistViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final segments = viewModel.segments;
    if (segments.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Semantics(
        // One labelled group rather than a bare list of chips, so a screen
        // reader announces what the row is before what each chip says.
        container: true,
        explicitChildNodes: true,
        label: context.l10n.filter,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final segment in segments)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _Segment(
                    label: context.l10n.filterLabelWithCount(
                      segment,
                      viewModel.countFor(segment),
                    ),
                    isSelected: viewModel.selected == segment,
                    onTap: () => viewModel.select(segment),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);
    final unselected = theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: isSelected,
      // The label already carries the localized count; the selected state is
      // announced by `Semantics.selected` rather than baked into the text.
      child: Material(
        color: isSelected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? primary
                    : unselected.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : unselected,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

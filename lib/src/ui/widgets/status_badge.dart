import 'package:flutter/material.dart';

import '../../config/localization.dart';
import '../../config/theme.dart';
import '../../models/wish_state.dart';
import '../../wishkit.dart';

/// A badge that displays the status of a wish.
class StatusBadge extends StatelessWidget {
  final WishState state;

  const StatusBadge({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final badgeTheme = WishKit.theme.badgeTheme;
    final color = _getColor(badgeTheme, brightness);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      // The state name alone is meaningless to a screen reader ("Pending"),
      // so the badge is dropped from the semantics tree and the caller folds
      // the state into the row's own label.
      child: Text(
        context.l10n.stateLabel(state),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Colours per state, ported from `WishView.badgeScheme(for:)`.
  ///
  /// Note that `approved` reuses the in-review colour on iOS rather than
  /// `planned`'s: an approved wish is waiting on a decision, not on a slot.
  Color _getColor(WishKitBadgeTheme badgeTheme, Brightness brightness) {
    return switch (state) {
      WishState.pending => badgeTheme.pending,
      // iOS maps both `approved` and `inReview` onto `badgeColor.inReview`.
      WishState.approved => badgeTheme.inReview,
      WishState.inReview => badgeTheme.inReview,
      WishState.planned => badgeTheme.planned,
      WishState.inProgress => badgeTheme.inProgress,
      WishState.completed => badgeTheme.completed,
      WishState.implemented => badgeTheme.completed,
      WishState.rejected => badgeTheme.rejected,
    }.resolve(brightness);
  }
}

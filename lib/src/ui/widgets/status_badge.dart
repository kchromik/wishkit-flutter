import 'package:flutter/material.dart';
import '../../models/wish_state.dart';
import '../../config/theme.dart';
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
    final localization = WishKit.config.localization;

    final color = _getColor(badgeTheme, brightness);
    final text = _getText(localization);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getColor(WishKitBadgeTheme badgeTheme, Brightness brightness) {
    switch (state) {
      case WishState.pending:
        return badgeTheme.pending.resolve(brightness);
      case WishState.inReview:
        return badgeTheme.inReview.resolve(brightness);
      case WishState.approved:
        return badgeTheme.approved.resolve(brightness);
      case WishState.planned:
        return badgeTheme.planned.resolve(brightness);
      case WishState.inProgress:
        return badgeTheme.inProgress.resolve(brightness);
      case WishState.completed:
        return badgeTheme.completed.resolve(brightness);
      case WishState.implemented:
        return badgeTheme.implemented.resolve(brightness);
      case WishState.rejected:
        return badgeTheme.rejected.resolve(brightness);
    }
  }

  String _getText(localization) {
    switch (state) {
      case WishState.pending:
        return localization.pending;
      case WishState.inReview:
        return localization.inReview;
      case WishState.approved:
        return localization.approved;
      case WishState.planned:
        return localization.planned;
      case WishState.inProgress:
        return localization.inProgress;
      case WishState.completed:
        return localization.completed;
      case WishState.implemented:
        return localization.implemented;
      case WishState.rejected:
        return localization.rejected;
    }
  }
}

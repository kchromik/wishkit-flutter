import 'package:flutter/material.dart';

import '../../config/configuration.dart';
import '../../wishkit.dart';

/// A button for voting on a wish.
///
/// Draws whichever icon `WishKit.config.buttons.voteButton.icon` names, which
/// the Flutter SDK previously ignored and always rendered as a plain arrow.
class VoteButton extends StatelessWidget {
  final int voteCount;
  final bool hasVoted;
  final bool isLoading;
  final VoidCallback? onPressed;

  /// Accessible name for the button, read as "<action>, <n> votes".
  ///
  /// Passed in rather than built here so the caller owns the wording; the
  /// server-provided count is announced alongside the action instead of the
  /// label silently changing when a vote lands.
  final String? semanticsLabel;

  const VoteButton({
    super.key,
    required this.voteCount,
    required this.hasVoted,
    this.isLoading = false,
    this.onPressed,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);
    const votedForegroundColor = Colors.white;
    final unvotedColor = theme.colorScheme.onSurfaceVariant;
    final foreground = hasVoted ? votedForegroundColor : unvotedColor;
    final radius = WishKit.config.resolvedCornerRadius;

    return Semantics(
      button: true,
      enabled: !isLoading && onPressed != null,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        color: hasVoted
            ? primaryColor
            : unvotedColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            width: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: hasVoted
                    ? primaryColor
                    : unvotedColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foreground,
                    ),
                  )
                else
                  Icon(_icon(), size: 18, color: foreground),
                const SizedBox(height: 2),
                Text(
                  voteCount.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maps the configured icon to a Material one.
  ///
  /// iOS lets a host pass an arbitrary SF Symbol name, which has no Flutter
  /// equivalent. The three named cases are honoured, and the map is total so a
  /// future case cannot render nothing.
  IconData _icon() {
    return switch (WishKit.config.buttons.voteButton.icon) {
      WishKitUpvoteIcon.chevronUpIcon => Icons.keyboard_arrow_up,
      WishKitUpvoteIcon.arrowUpIcon => Icons.arrow_upward,
      WishKitUpvoteIcon.thumbUpIcon => Icons.thumb_up,
    };
  }
}

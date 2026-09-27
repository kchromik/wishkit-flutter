import 'package:flutter/material.dart';

import '../../config/localization.dart';
import '../../wishkit.dart';

/// The plan-level "Powered by WishKit" line.
///
/// `shouldShowWatermark` comes from `/wish/list` and is a branding-compliance
/// switch, not a preference: a free plan must show it. The Flutter SDK parsed
/// the field away, so a customer who had paid to remove it still saw it — and,
/// worse, the field was invisible to the host, who had no way to check.
class PoweredByWatermark extends StatelessWidget {
  const PoweredByWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, size: 12, color: primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.l10n.poweredBy,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders the watermark only when the server asked for it.
class ConditionalWatermark extends StatelessWidget {
  /// `true` when `/wish/list` said the watermark must be shown.
  final bool visible;

  /// The list's own bottom padding, so the watermark does not sit under a
  /// floating add button.
  final EdgeInsets padding;

  const ConditionalWatermark({
    super.key,
    required this.visible,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: padding,
      child: const PoweredByWatermark(),
    );
  }
}

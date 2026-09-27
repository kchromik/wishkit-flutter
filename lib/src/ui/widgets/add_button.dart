import 'package:flutter/material.dart';

import '../../config/localization.dart';
import '../../wishkit.dart';

/// Floating action button for adding a new wish.
class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: primary,
      tooltip: context.l10n.createWish,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

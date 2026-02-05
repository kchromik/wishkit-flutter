import 'package:flutter/material.dart';
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
    final primaryColor = WishKit.theme.primaryColor;

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

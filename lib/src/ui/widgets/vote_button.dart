import 'package:flutter/material.dart';
import '../../wishkit.dart';

/// A button for voting on a wish.
class VoteButton extends StatelessWidget {
  final int voteCount;
  final bool hasVoted;
  final bool isLoading;
  final VoidCallback? onPressed;

  const VoteButton({
    super.key,
    required this.voteCount,
    required this.hasVoted,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = WishKit.theme.primaryColor;
    final votedForegroundColor = Colors.white;

    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasVoted ? primaryColor : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasVoted ? primaryColor : Colors.grey.withValues(alpha: 0.3),
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
                  color: hasVoted ? votedForegroundColor : Colors.grey,
                ),
              )
            else
              Icon(
                Icons.arrow_upward,
                size: 18,
                color: hasVoted ? votedForegroundColor : Colors.grey,
              ),
            const SizedBox(height: 2),
            Text(
              voteCount.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hasVoted ? votedForegroundColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

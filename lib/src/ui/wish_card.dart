import 'package:flutter/material.dart';
import '../config/configuration.dart';
import '../models/wish.dart';
import '../wishkit.dart';
import 'widgets/status_badge.dart';
import 'widgets/vote_button.dart';

/// A card displaying a single wish in the list.
class WishCard extends StatelessWidget {
  final Wish wish;
  final bool hasVoted;
  final bool isVoting;
  final VoidCallback? onTap;
  final VoidCallback? onVote;

  const WishCard({
    super.key,
    required this.wish,
    required this.hasVoted,
    this.isVoting = false,
    this.onTap,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final config = WishKit.config;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: config.dropShadow == Display.show ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(config.cornerRadius),
        side: config.dropShadow == Display.hide
            ? BorderSide(color: theme.dividerColor)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(config.cornerRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VoteButton(
                voteCount: wish.voteCount,
                hasVoted: hasVoted,
                isLoading: isVoting,
                onPressed: onVote,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            wish.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (config.statusBadge == Display.show) ...[
                          const SizedBox(width: 8),
                          StatusBadge(state: wish.state),
                        ],
                      ],
                    ),
                    if (wish.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        wish.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        maxLines: config.expandDescriptionInList ? null : 2,
                        overflow: config.expandDescriptionInList
                            ? null
                            : TextOverflow.ellipsis,
                      ),
                    ],
                    if (wish.comments.isNotEmpty &&
                        config.commentSection == Display.show) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${wish.comments.length}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

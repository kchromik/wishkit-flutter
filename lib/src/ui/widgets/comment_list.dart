import 'package:flutter/material.dart';

import '../../config/localization.dart';
import '../../models/comment.dart';
import '../../utilities/date_format.dart';
import '../../wishkit.dart';

/// A wish's comment thread, newest first.
///
/// Port of `CommentListView` + `SingleCommentView`. The section header is
/// dropped entirely when there is nothing to show, matching iOS's
/// `commentList.isEmpty == false` guard — an empty "Comments" heading above no
/// comments reads as a broken screen rather than a quiet one.
class CommentList extends StatelessWidget {
  final List<Comment> comments;
  final String localeName;

  const CommentList({
    super.key,
    required this.comments,
    required this.localeName,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final radius = WishKit.config.resolvedCornerRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            context.l10n.comments,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Column(
              children: [
                for (var i = 0; i < comments.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  CommentRow(
                    comment: comments[i],
                    localeName: localeName,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One comment: who wrote it, when, and what they said.
class CommentRow extends StatelessWidget {
  final Comment comment;
  final String localeName;

  const CommentRow({
    super.key,
    required this.comment,
    required this.localeName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.l10n;
    final caption = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    // An unparseable `createdAt` hides the timestamp rather than printing the
    // epoch; a "1/1/1970" on a comment from today is worse than no date.
    final date = comment.hasKnownDate
        ? WishKitDateFormat.medium(comment.createdAt.toLocal(), localeName)
        : null;
    final author = comment.isAdmin ? strings.admin : strings.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // The admin row is the one the user is looking for, so it gets
              // the accent colour and a bold weight.
              Text(
                author,
                style: comment.isAdmin
                    ? caption?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      )
                    : caption,
              ),
              const Spacer(),
              if (date != null) Text(date, style: caption),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment.description, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// The pinned comment input at the bottom of the detail screen.
///
/// Port of `CommentFieldView`, including the rule that the send button is
/// disabled while the field is empty after trimming — an all-whitespace comment
/// is not a comment.
class CommentComposer extends StatelessWidget {
  final TextEditingController controller;
  final String value;
  final bool isSubmitting;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const CommentComposer({
    super.key,
    required this.controller,
    required this.value,
    required this.isSubmitting,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);
    final canSubmit = value.trim().isNotEmpty && !isSubmitting;

    return Material(
      color: theme.colorScheme.surface,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  enabled: !isSubmitting,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (canSubmit) onSubmit();
                  },
                  decoration: InputDecoration(
                    hintText: context.l10n.writeAComment,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isSubmitting)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: canSubmit ? onSubmit : null,
                  icon: Icon(Icons.arrow_upward, color: primary),
                  // The hint above the field already labels this for a screen
                  // reader, so the icon contributes nothing on its own.
                  tooltip: context.l10n.submitComment,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

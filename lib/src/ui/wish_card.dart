import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/configuration.dart';
import '../config/localization.dart';
import '../models/wish.dart';
import '../models/wish_state.dart';
import '../state/detail_wish_view_model.dart';
import '../state/wish_model.dart';
import '../wishkit.dart';
import 'widgets/status_badge.dart';
import 'widgets/translate_section.dart';
import 'widgets/vote_button.dart';

/// A card displaying a single wish in the list.
///
/// Owns a [DetailWishViewModel] so the optimistic vote count, the vote guards
/// and the translation toggle behave exactly as they do on the detail screen.
/// The old card held a `hasVoted` bool and an `isVoting` bool and refetched the
/// whole board after every vote, which is why a vote on a slow connection looked
/// like it had not registered until the request came back.
class WishCard extends StatefulWidget {
  final Wish wish;

  /// The user id, or `''` before the first fetch resolves.
  final String userUuid;

  final VoidCallback? onTap;

  /// Called when a vote was refused or failed, so the board can show the alert.
  ///
  /// Passes the outcome rather than a message: the copy is localized at the
  /// point of display, and only the board knows the context to display it in.
  final ValueChanged<VoteOutcome>? onVoteRejected;

  const WishCard({
    super.key,
    required this.wish,
    this.userUuid = '',
    this.onTap,
    this.onVoteRejected,
  });

  @override
  State<WishCard> createState() => _WishCardState();
}

class _WishCardState extends State<WishCard> {
  DetailWishViewModel? _viewModel;
  String? _builtForUserUuid;
  String? _builtForLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildIfStale();
  }

  @override
  void didUpdateWidget(covariant WishCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildIfStale();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  /// Rebuilds the view model when any of its inputs changed.
  ///
  /// A new `Wish` object means new server state — someone else's vote, a new
  /// comment. The view model snapshots the wish at construction rather than
  /// watching it, so it is rebuilt instead of patched. A host that hands the
  /// same list instance back unchanged is a no-op here.
  void _rebuildIfStale() {
    final language = context.l10n.languageTag;
    final existing = _viewModel;
    if (existing != null &&
        _builtForUserUuid == widget.userUuid &&
        _builtForLanguage == language &&
        identical(existing.wish, widget.wish)) {
      return;
    }

    existing?.dispose();
    _builtForUserUuid = widget.userUuid;
    _builtForLanguage = language;
    _viewModel = _create();
    setState(() {});
  }

  DetailWishViewModel _create() {
    final model = context.read<WishModel>();
    return DetailWishViewModel.forWish(
      widget.wish,
      model: model,
      appLanguage: _builtForLanguage!,
      appScript: context.l10n.scriptCode,
    );
  }

  Future<void> _vote() async {
    final outcome = await _viewModel!.toggleVote();
    if (outcome != VoteOutcome.success && outcome != VoteOutcome.voteRemoved) {
      widget.onVoteRejected?.call(outcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) return const SizedBox.shrink();

    final config = WishKit.config;
    final theme = Theme.of(context);
    final strings = context.l10n;
    final radius = config.resolvedCornerRadius;
    final showShadow = config.dropShadow == Display.show;
    // Pending always shows its badge even when the host turned badges off: it
    // is how a user recognises their own unapproved feedback in Open. Matches
    // iOS, which renders the badge for `pending` unconditionally.
    final showBadge = config.statusBadge == Display.show ||
        widget.wish.state == WishState.pending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: showShadow ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: showShadow ? BorderSide.none : BorderSide(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VoteButton(
                voteCount: viewModel.voteCount,
                hasVoted: viewModel.hasVoted,
                isLoading: viewModel.isVoting,
                onPressed: _vote,
                semanticsLabel: strings.upvote,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            viewModel.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 8),
                          StatusBadge(state: widget.wish.state),
                        ],
                      ],
                    ),
                    if (viewModel.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      // iOS clamps a list row to a single line unless the host
                      // opted into `expandDescriptionInList`. The Flutter SDK
                      // used two, which made previews a Flutter-only look.
                      Text(
                        viewModel.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        maxLines: config.expandDescriptionInList ? null : 1,
                        overflow: config.expandDescriptionInList
                            ? null
                            : TextOverflow.ellipsis,
                      ),
                    ],
                    if (widget.wish.comments.isNotEmpty &&
                        config.commentSection == Display.show) ...[
                      const SizedBox(height: 8),
                      CommentCount(count: widget.wish.comments.length),
                    ],
                    TranslateSection(viewModel: viewModel),
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

/// "3" with a comment bubble, shown under a card's description.
class CommentCount extends StatelessWidget {
  final int count;

  const CommentCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall;

    return Semantics(
      label: context.l10n.comments,
      // The number is already the whole meaning here; announcing "3" as well
      // would make a screen reader read the count twice.
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 14, color: style?.color),
          const SizedBox(width: 4),
          Text(count.toString(), style: style),
        ],
      ),
    );
  }
}

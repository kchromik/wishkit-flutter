import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/configuration.dart';
import '../config/localization.dart';
import '../models/comment.dart';
import '../models/wish.dart';
import '../models/wish_state.dart';
import '../state/detail_wish_view_model.dart';
import '../state/wish_model.dart';
import '../wishkit.dart';
import 'widgets/comment_list.dart';
import 'widgets/status_badge.dart';
import 'widgets/translate_section.dart';
import 'widgets/vote_button.dart';

/// Detailed view for a single wish.
class DetailWishView extends StatefulWidget {
  final Wish wish;

  const DetailWishView({
    super.key,
    required this.wish,
  });

  @override
  State<DetailWishView> createState() => _DetailWishViewState();
}

class _DetailWishViewState extends State<DetailWishView> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();

  DetailWishViewModel? _viewModel;
  String? _builtForLanguage;

  /// The thread as this screen last saw it.
  ///
  /// Kept separately from the model so a new comment appears immediately after
  /// the server acknowledges it, rather than after a full board refetch that
  /// also re-sorts the list underneath the user.
  List<Comment> _comments = const [];

  @override
  void initState() {
    super.initState();
    _comments = List<Comment>.of(widget.wish.comments);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshComments();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = context.l10n.languageTag;
    if (_viewModel != null && _builtForLanguage == language) return;

    _viewModel?.dispose();
    _builtForLanguage = language;
    _viewModel = DetailWishViewModel.forWish(
      widget.wish,
      model: context.read<WishModel>(),
      appLanguage: language,
      appScript: context.l10n.scriptCode,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  /// Pulls the thread fresh, so a reply that landed since the board's fetch is
  /// not read from a stale snapshot.
  Future<void> _refreshComments() async {
    final fetched = await context.read<WishModel>().fetchComments(widget.wish.id);
    if (!mounted) return;
    // An empty response would wipe a thread the user is reading; the list
    // endpoint can legitimately come back empty for a wish with no comments,
    // which is indistinguishable from a backend that has not shipped the
    // endpoint yet. Only replace when we actually got something.
    if (fetched.isEmpty && _comments.isNotEmpty) return;
    setState(() => _comments = fetched);
  }

  Future<void> _vote() async {
    final outcome = await _viewModel!.toggleVote();
    if (!mounted) return;

    final strings = context.l10n;
    final message = switch (outcome) {
      VoteOutcome.alreadyVoted => strings.youCanOnlyVoteOnce,
      VoteOutcome.completedWish => strings.youCanNotVoteForACompletedWish,
      // See the note in `wishlist_view.dart`: iOS falls through to the own-wish
      // string here, which is a latent bug there.
      VoteOutcome.error => strings.somethingWentWrong,
      VoteOutcome.success || VoteOutcome.voteRemoved => null,
    };
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _submitComment() async {
    final comment = await _viewModel!.submitComment();
    if (!mounted || comment == null) return;

    setState(() => _comments = [comment, ..._comments]);
    _commentController.clear();
    // Let the field read as "sent" without stealing focus back from wherever
    // the user moved to.
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = _viewModel;
    if (viewModel == null) return const SizedBox.shrink();

    final config = WishKit.config;
    final strings = context.l10n;
    final showComments = config.commentSection == Display.show;
    // Pending always shows its badge even when the host turned badges off: it
    // is how a user recognises their own unapproved feedback. Matches iOS.
    final showBadge = config.statusBadge == Display.show ||
        widget.wish.state == WishState.pending;

    return Scaffold(
      appBar: AppBar(title: Text(strings.detail)),
      body: ListView(
        controller: _scrollController,
        // The composer is pinned to the bottom of the Scaffold rather than the
        // end of the list, so it does not scroll away under a long thread.
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        viewModel.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (showBadge) ...[
                      const SizedBox(width: 8),
                      StatusBadge(state: widget.wish.state),
                    ],
                  ],
                ),
                if (viewModel.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // The detail view is the one place a description is never
                  // clamped: the user came here to read it.
                  Text(
                    viewModel.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                TranslateSection(viewModel: viewModel),
                const SizedBox(height: 12),
                Row(
                  children: [
                    VoteButton(
                      voteCount: viewModel.voteCount,
                      hasVoted: viewModel.hasVoted,
                      isLoading: viewModel.isVoting,
                      onPressed: _vote,
                      semanticsLabel: strings.upvote,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      strings.votes,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showComments)
            CommentList(
              comments: _comments,
              localeName: strings.localeName,
            ),
        ],
      ),
      bottomNavigationBar: showComments
          ? CommentComposer(
              controller: _commentController,
              value: viewModel.newComment,
              isSubmitting: viewModel.isLoading,
              onChanged: viewModel.setNewComment,
              onSubmit: _submitComment,
            )
          : null,
    );
  }
}

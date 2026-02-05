import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/configuration.dart';
import '../models/wish.dart';
import '../state/wish_provider.dart';
import '../wishkit.dart';
import 'widgets/status_badge.dart';
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
  bool _isVoting = false;
  bool _isCommenting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _vote() async {
    setState(() => _isVoting = true);

    final provider = context.read<WishProvider>();
    final hasVoted = provider.hasVoted(widget.wish);
    final config = WishKit.config;
    final localization = config.localization;

    VoteResult result;
    if (hasVoted && config.allowUndoVote) {
      result = await provider.removeVote(widget.wish.id);
    } else {
      result = await provider.vote(widget.wish.id);
    }

    if (!mounted) return;

    setState(() => _isVoting = false);

    if (result == VoteResult.alreadyVoted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.alreadyVotedMessage),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (result == VoteResult.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.voteErrorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isCommenting = true);

    final provider = context.read<WishProvider>();
    final localization = WishKit.config.localization;

    final success = await provider.addComment(widget.wish.id, text);

    if (!mounted) return;

    setState(() => _isCommenting = false);

    if (success) {
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.commentErrorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = WishKit.config;
    final localization = config.localization;
    final theme = Theme.of(context);
    final primaryColor = WishKit.theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.featureRequest),
      ),
      body: Consumer<WishProvider>(
        builder: (context, provider, _) {
          // Get updated wish from provider
          final wish = provider.wishes.firstWhere(
            (w) => w.id == widget.wish.id,
            orElse: () => widget.wish,
          );
          final hasVoted = provider.hasVoted(wish);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Vote section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VoteButton(
                          voteCount: wish.voteCount,
                          hasVoted: hasVoted,
                          isLoading: _isVoting,
                          onPressed: _vote,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wish.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (config.statusBadge == Display.show) ...[
                                const SizedBox(height: 8),
                                StatusBadge(state: wish.state),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Description
                    if (wish.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        wish.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],

                    // Comments section
                    if (config.commentSection == Display.show) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        localization.comments,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Comment list
                      if (wish.comments.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              localization.noComments,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        )
                      else
                        ...wish.comments.map((comment) => _CommentItem(
                              comment: comment,
                              localization: localization,
                            )),
                    ],
                  ],
                ),
              ),

              // Comment input
              if (config.commentSection == Display.show)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: localization.commentPlaceholder,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isCommenting ? null : _submitComment,
                          icon: _isCommenting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.send,
                                  color: primaryColor,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final dynamic comment;
  final dynamic localization;

  const _CommentItem({
    required this.comment,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: comment.isAdmin
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  comment.isAdmin ? 'Admin' : 'User',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: comment.isAdmin ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(comment.createdAt),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

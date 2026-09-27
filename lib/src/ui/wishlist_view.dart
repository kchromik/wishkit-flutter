import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/configuration.dart';
import '../config/localization.dart';
import '../models/wish.dart';
import '../state/detail_wish_view_model.dart';
import '../state/wishlist_view_model.dart';
import '../state/wish_model.dart';
import '../wishkit.dart';
import 'chat_view.dart';
import 'create_wish_view.dart';
import 'detail_wish_view.dart';
import 'wish_card.dart';
import 'widgets/add_button.dart';
import 'widgets/chat_button.dart';
import 'widgets/segmented_control.dart';
import 'widgets/skeleton_list.dart';
import 'widgets/watermark.dart';

/// Main wishlist view showing all feature requests.
///
/// Needs a [WishModel] above it in the tree, which is what
/// `WishKit.feedbackListView` installs. A host embedding the board in their own
/// page provides the same.
class WishlistView extends StatefulWidget {
  /// Overrides the app bar title. `null` uses the localized `wishlist` string.
  final String? title;

  const WishlistView({super.key, this.title});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  WishlistViewModel? _viewModel;
  bool _hasUnreadChat = false;

  @override
  void initState() {
    super.initState();
    // Post-frame: `context.read` is not safe in `initState`, and starting the
    // fetch after the first frame means the skeleton is what the user sees
    // rather than an empty flash.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WishModel>().fetchList();
      _checkChatStatus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= WishlistViewModel(context.read<WishModel>());
    // A host that changed `visibleStates` at runtime would otherwise be left
    // filtering a segment it no longer displays.
    _viewModel!.reconcileSelection();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  Future<void> _checkChatStatus() async {
    if (!WishKit.config.showChatButtonInFeedbackView) return;
    final status = await fetchChatStatus();
    if (!mounted) return;
    setState(() => _hasUnreadChat = status?.hasUnread ?? false);
  }

  void _openCreateWish() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CreateWishView()),
    );
  }

  void _openWishDetail(Wish wish) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailWishView(wish: wish)),
    );
  }

  void _openChat() {
    setState(() => _hasUnreadChat = false);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WishKitChatView()),
    );
  }

  /// Shows the exact copy iOS uses for a refused vote.
  ///
  /// A `SnackBar` rather than iOS's `alert`, because a modal over a board the
  /// user is scrolling is heavier than the situation warrants — but the wording
  /// is the bundled translation, so a localized Flutter board reads the same as
  /// a localized iOS one.
  void _showVoteAlert(VoteOutcome outcome) {
    final strings = context.l10n;
    final message = switch (outcome) {
      VoteOutcome.alreadyVoted => strings.youCanOnlyVoteOnce,
      VoteOutcome.completedWish => strings.youCanNotVoteForACompletedWish,
      // iOS's generic alert reason falls through to the "your own wish" string,
      // which is a latent bug there: a server error told the user they could
      // not vote for their own feedback. `somethingWentWrong` is the honest
      // string, and it is what the key is for.
      VoteOutcome.error => strings.somethingWentWrong,
      VoteOutcome.success || VoteOutcome.voteRemoved => null,
    };
    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WishModel>();
    final viewModel = _viewModel;
    final config = WishKit.config;
    final strings = context.l10n;

    if (viewModel == null) return const SizedBox.shrink();

    final addButton = config.buttons.addButton;
    final showAddButton = addButton.display == Display.show;
    final showFloatingAdd =
        showAddButton && addButton.location == AddButtonLocation.floating;
    final bottomPadding =
        showFloatingAdd ? addButton.listBottomPadding : 24.0;

    return Scaffold(
      appBar: AppBar(
        // iOS titles the board `featureWishlist`; `wishlist` is the Flutter
        // string that has always shipped here. Both are bundled, so a host
        // that wants the iOS wording overrides one key.
        title: Text(widget.title ?? strings.wishlist),
        actions: [
          if (showAddButton &&
              addButton.location == AddButtonLocation.navigationBar)
            IconButton(
              onPressed: _openCreateWish,
              icon: const Icon(Icons.add),
              tooltip: strings.createWish,
            ),
        ],
      ),
        body: Column(
          children: [
            if (viewModel.isSegmentedControlVisible)
              WishlistSegmentedControl(viewModel: viewModel),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (model.isLoading && !model.hasFetched) {
                    return const WishlistSkeleton();
                  }

                  final wishes = viewModel.visibleWishes;
                  if (wishes.isEmpty) {
                    return _emptyState(viewModel, model);
                  }

                  return RefreshIndicator(
                    onRefresh: model.fetchList,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 4, bottom: bottomPadding),
                      itemCount: wishes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == wishes.length) {
                          return ConditionalWatermark(
                            visible: model.shouldShowWatermark,
                            padding: EdgeInsets.only(top: bottomPadding),
                          );
                        }

                        final wish = wishes[index];
                        return WishCard(
                          // Keyed by wish id so a segment switch reuses the
                          // existing card state — including an in-flight vote —
                          // instead of rebuilding every card from scratch.
                          key: ValueKey(wish.id),
                          wish: wish,
                          userUuid: model.currentUserUuid ?? '',
                          onTap: () => _openWishDetail(wish),
                          onVoteRejected: _showVoteAlert,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _floatingActions(showAddButton, showFloatingAdd),
    );
  }

  /// The chat button floats above the add button.
  ///
  /// Both are in the same slot rather than one being pinned with a `Stack`, so
  /// the Scaffold keeps owning the bottom inset and neither button can end up
  /// under a keyboard or a home indicator.
  Widget? _floatingActions(bool showAddButton, bool showFloatingAdd) {
    final actions = <Widget>[
      if (WishKit.config.showChatButtonInFeedbackView)
        FeedbackChatButton(
          onPressed: _openChat,
          hasUnread: _hasUnreadChat,
        ),
      if (showFloatingAdd) AddButton(onPressed: _openCreateWish),
    ];
    if (actions.isEmpty) return null;
    if (actions.length == 1) return actions.single;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [actions.first, const SizedBox(height: 16), actions.last],
    );
  }

  /// What the board shows when the selected bucket has nothing in it.
  ///
  /// iOS prints `"<Bucket>: <no feature requests>"`. When the segmented
  /// control is on and the *other* bucket does have rows, the useful thing to
  /// say is the `activateToSwitchFilter` prompt rather than "there is nothing
  /// here": the user is one tap from content.
  Widget _emptyState(WishlistViewModel viewModel, WishModel model) {
    final strings = context.l10n;
    final theme = Theme.of(context);

    final otherSegmentHasRows = viewModel.segments
        .where((segment) => segment != viewModel.selected)
        .any((segment) => viewModel.countFor(segment) > 0);

    final String message;
    if (viewModel.isSegmentedControlVisible && otherSegmentHasRows) {
      message = strings.activateToSwitchFilter;
    } else {
      // `<Bucket>: <noFeatureRequests>` — the same shape as iOS, and composed
      // from two keys so a host who overrides either half still gets their own
      // words in the right order.
      message = '${strings.filterLabel(viewModel.selected)}: '
          '${strings.noFeatureRequests}';
    }

    // Scrollable on purpose: `RefreshIndicator` needs a scrollable, and without
    // one a failed fetch leaves no way to retry but the add button.
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.4,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ),
        ConditionalWatermark(visible: model.shouldShowWatermark),
      ],
    );
  }
}

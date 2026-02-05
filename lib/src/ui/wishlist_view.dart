import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/configuration.dart';
import '../models/wish_state.dart';
import '../state/wish_provider.dart';
import '../wishkit.dart';
import 'create_wish_view.dart';
import 'detail_wish_view.dart';
import 'wish_card.dart';
import 'widgets/add_button.dart';

/// Main wishlist view showing all feature requests.
class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  WishState? _selectedState;
  String? _votingWishId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishProvider>().fetchList();
    });
  }

  void _openCreateWish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<WishProvider>(),
          child: const CreateWishView(),
        ),
      ),
    );
  }

  void _openWishDetail(wish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<WishProvider>(),
          child: DetailWishView(wish: wish),
        ),
      ),
    );
  }

  Future<void> _vote(String wishId) async {
    setState(() => _votingWishId = wishId);

    final provider = context.read<WishProvider>();
    final localization = WishKit.config.localization;

    final result = await provider.vote(wishId);

    if (!mounted) return;

    setState(() => _votingWishId = null);

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

  @override
  Widget build(BuildContext context) {
    final config = WishKit.config;
    final localization = config.localization;

    return Consumer<WishProvider>(
      builder: (context, provider, _) {
        final wishes = provider.getByState(_selectedState);

        Widget body;
        if (provider.isLoading && !provider.hasFetched) {
          body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(localization.loading),
              ],
            ),
          );
        } else if (provider.error != null && !provider.hasFetched) {
          body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(localization.errorLoading),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: provider.fetchList,
                  child: Text(localization.retry),
                ),
              ],
            ),
          );
        } else if (wishes.isEmpty) {
          body = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 48,
                  color: Theme.of(context).disabledColor,
                ),
                const SizedBox(height: 16),
                Text(
                  localization.noWishes,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        } else {
          body = RefreshIndicator(
            onRefresh: provider.fetchList,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: wishes.length,
              itemBuilder: (context, index) {
                final wish = wishes[index];
                return WishCard(
                  wish: wish,
                  hasVoted: provider.hasVoted(wish),
                  isVoting: _votingWishId == wish.id,
                  onTap: () => _openWishDetail(wish),
                  onVote: () => _vote(wish.id),
                );
              },
            ),
          );
        }

        return Column(
          children: [
            if (config.buttons.segmentedControl.display == Display.show)
              _SegmentedControl(
                selectedState: _selectedState,
                onChanged: (state) => setState(() => _selectedState = state),
                localization: localization,
              ),
            Expanded(
              child: Stack(
                children: [
                  body,
                  if (config.buttons.addButton.display == Display.show &&
                      config.buttons.addButton.location ==
                          AddButtonLocation.floating)
                    Positioned(
                      right: 16,
                      bottom: _getAddButtonPadding(
                          config.buttons.addButton.bottomPadding),
                      child: AddButton(onPressed: _openCreateWish),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double _getAddButtonPadding(ButtonPadding padding) {
    switch (padding) {
      case ButtonPadding.small:
        return 8;
      case ButtonPadding.medium:
        return 16;
      case ButtonPadding.large:
        return 24;
    }
  }
}

/// Segmented control for filtering wishes by state.
class _SegmentedControl extends StatelessWidget {
  final WishState? selectedState;
  final ValueChanged<WishState?> onChanged;
  final dynamic localization;

  const _SegmentedControl({
    required this.selectedState,
    required this.onChanged,
    required this.localization,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = WishKit.theme.primaryColor;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(
            label: localization.all,
            isSelected: selectedState == null,
            onTap: () => onChanged(null),
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: localization.tabPending,
            isSelected: selectedState == WishState.pending,
            onTap: () => onChanged(WishState.pending),
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: localization.tabInReview,
            isSelected: selectedState == WishState.inReview,
            onTap: () => onChanged(WishState.inReview),
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: localization.tabPlanned,
            isSelected: selectedState == WishState.planned,
            onTap: () => onChanged(WishState.planned),
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: localization.tabInProgress,
            isSelected: selectedState == WishState.inProgress,
            onTap: () => onChanged(WishState.inProgress),
            primaryColor: primaryColor,
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: localization.tabCompleted,
            isSelected: selectedState == WishState.completed,
            onTap: () => onChanged(WishState.completed),
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Wishlist page with Scaffold and AppBar.
class WishlistPage extends StatelessWidget {
  final String? title;

  const WishlistPage({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final config = WishKit.config;
    final localization = config.localization;

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? localization.featureRequest),
        actions: [
          if (config.buttons.addButton.display == Display.show &&
              config.buttons.addButton.location == AddButtonLocation.navigationBar)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: context.read<WishProvider>(),
                      child: const CreateWishView(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: const WishlistView(),
    );
  }
}

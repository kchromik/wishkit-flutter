import 'package:flutter/material.dart';

import '../../api/chat_api.dart';
import '../../config/localization.dart';
import '../../models/chat_message.dart';
import '../../utilities/logger.dart';
import '../../wishkit.dart';

/// The floating chat button shown on the feedback board.
///
/// Port of `FeedbackChatButton`.
///
/// The button removes itself when `/chat/status` reports the chat unavailable,
/// and it *fails closed*: an unreachable status endpoint hides the button rather
/// than showing a dead one. Availability is re-checked each time the button is
/// built, which is one cheap request against a plan-level flag.
class FeedbackChatButton extends StatefulWidget {
  /// Called when the user taps the button.
  ///
  /// The board pushes the chat route itself rather than this widget owning a
  /// navigator, so the same button works inside a host's own page and inside
  /// [WishKit.feedbackPage].
  final VoidCallback onPressed;

  /// Whether an admin replied while the chat was closed.
  final bool hasUnread;

  const FeedbackChatButton({
    super.key,
    required this.onPressed,
    this.hasUnread = false,
  });

  @override
  State<FeedbackChatButton> createState() => _FeedbackChatButtonState();
}

class _FeedbackChatButtonState extends State<FeedbackChatButton> {
  /// `null` means "not checked yet", which renders nothing. Drawing the button
  /// optimistically and hiding it a moment later is a visible flicker on every
  /// board open for every customer who does not have chat.
  bool? _available;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    if (!WishKit.isConfigured) return;
    final status = await fetchChatStatus();
    if (!mounted) return;
    setState(() => _available = status?.chatAvailable ?? false);
  }

  @override
  Widget build(BuildContext context) {
    if (!WishKit.config.showChatButtonInFeedbackView) {
      return const SizedBox.shrink();
    }
    if (_available != true) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final primary =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);

    return Semantics(
      button: true,
      label: context.l10n.chat,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: primary,
            shape: const CircleBorder(),
            elevation: 6,
            child: InkWell(
              onTap: widget.onPressed,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.chat_bubble,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          if (widget.hasUnread)
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Runs the one-off chat status check and reports the result.
///
/// Extracted so the board can decide whether to reserve space and a host can
/// badge its own chat entry point via [WishKit.chatStatus], without either
/// duplicating the endpoint. Returns `null` on any failure.
Future<ChatStatusResponse?> fetchChatStatus() async {
  if (!WishKit.isConfigured) return null;
  final result = await ChatApi(WishKit.apiClient).fetchStatus();
  if (!result.isSuccess) {
    WishKitLogger.log('chat status unavailable: ${result.error}');
    return null;
  }
  return result.data;
}

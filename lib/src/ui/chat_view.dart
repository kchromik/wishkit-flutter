import 'package:flutter/material.dart';

import '../config/localization.dart';
import '../models/chat_message.dart';
import '../state/chat_provider.dart';
import '../wishkit.dart';

/// The support conversation between your app's users and you.
///
/// Port of `ChatScreenView`. Polls every five seconds while visible and in the
/// foreground, and not at all in the background. The poll is a battery cost, so
/// it is driven by [ChatProvider]'s lifecycle observer rather than left running
/// behind a pushed route.
///
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const WishKitChatView()));
/// ```
///
/// The board also shows a floating chat button by default; see
/// `WishKit.config.showChatButtonInFeedbackView`.
class WishKitChatView extends StatefulWidget {
  const WishKitChatView({super.key});

  @override
  State<WishKitChatView> createState() => _WishKitChatViewState();
}

class _WishKitChatViewState extends State<WishKitChatView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  ChatProvider? _chat;

  @override
  void initState() {
    super.initState();
    // `context.read` is not safe in `initState`, so the provider is built after
    // the first frame. That also means the first paint is a spinner rather than
    // an empty thread, which is what iOS does too.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _chat != null) return;
      final chat = ChatProvider(apiClient: WishKit.apiClient);
      chat.startPolling();
      chat.markRead();
      setState(() => _chat = chat);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _chat?.dispose();
    super.dispose();
  }

  /// Truncates to the server's limit, as iOS does on change.
  ///
  /// Client-side so an over-long message fails immediately instead of after a
  /// round-trip, and so the send button is never enabled for text the server
  /// will reject.
  void _onChanged(String value) {
    if (value.length <= ChatProvider.maxMessageLength) return;
    _textController.text = value.substring(0, ChatProvider.maxMessageLength);
    _textController.selection = TextSelection.collapsed(
      offset: _textController.text.length,
    );
  }

  void _send() {
    final chat = _chat;
    if (chat == null) return;
    if (chat.send(_textController.text)) _textController.clear();
  }

  void _scrollToLatest(int count) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients || count == 0) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = _chat;
    if (chat == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.chat)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.chat)),
      body: ListenableBuilder(
        listenable: chat,
        builder: (context, _) {
          final messages = chat.messages;
          _scrollToLatest(messages.length);

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    if (messages.isNotEmpty)
                      ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) => _Bubble(
                          message: messages[index],
                          // Same-sender bubbles stay tight; a sender change gets
                          // double the air, so a change of speaker is visible
                          // without a divider.
                          topPadding: index == 0
                              ? 0
                              : messages[index - 1].sender ==
                                      messages[index].sender
                                  ? 6
                                  : 12,
                          onRetry: () => chat.retry(messages[index]),
                        ),
                      ),
                    if (!chat.hasLoaded)
                      const Center(child: CircularProgressIndicator())
                    else if (!chat.hasLoadedSuccessfully)
                      // The backend is unreachable or has no chat; polling keeps
                      // retrying underneath and this clears itself on success.
                      _CenteredMessage(context.l10n.somethingWentWrong)
                    else if (messages.isEmpty)
                      _CenteredMessage(context.l10n.chatEmptyState),
                  ],
                ),
              ),
              // The composer is hidden entirely when the server turns chat off,
              // rather than shown disabled: a permanently dead input bar reads
              // as a bug in the app, not as a feature that is switched off.
              if (chat.chatAvailable && chat.hasLoadedSuccessfully)
                _InputBar(
                  controller: _textController,
                  onChanged: _onChanged,
                  onSend: _send,
                  isSending: chat.isSending,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;

  const _CenteredMessage(this.message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

/// One message bubble, aligned to the side of its sender.
class _Bubble extends StatelessWidget {
  final ChatDisplayMessage message;
  final double topPadding;
  final VoidCallback onRetry;

  const _Bubble({
    required this.message,
    required this.topPadding,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);
    final isMine = message.isMine;
    final isFailed = message.status == ChatMessageStatus.failed;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Opacity(
                  // A pending message is visible but clearly provisional, so a
                  // slow send does not look like a frozen screen.
                  opacity: message.status == ChatMessageStatus.pending ? 0.5 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isMine
                          ? primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      message.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isMine ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                if (isFailed)
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      onTap: onRetry,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          context.l10n.failedToSendTapToRetry,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The message input at the bottom of the chat.
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool isSending;

  const _InputBar({
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary =
        WishKit.theme.resolvePrimaryColor(theme.colorScheme.primary);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              // An all-whitespace message is not a message, and sending one
              // would create a bubble the user cannot see the contents of.
              final canSend =
                  value.text.trim().isNotEmpty && !isSending;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      enabled: !isSending,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        if (canSend) onSend();
                      },
                      decoration: InputDecoration(
                        hintText: context.l10n.writeAMessage,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: canSend ? onSend : null,
                    icon: Icon(Icons.arrow_upward, color: primary),
                    tooltip: context.l10n.send,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

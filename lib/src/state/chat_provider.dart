import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../api/chat_api.dart';
import '../models/chat_message.dart';
import '../utilities/logger.dart';

/// Drives the support chat.
///
/// Port of iOS's `ChatViewModel`, with the same three behaviours that matter:
///
/// * **Optimistic send.** A message appears immediately as
///   [ChatMessageStatus.pending] and is reconciled when the server
///   acknowledges it. Waiting for a round-trip to draw the user's own words
///   makes the chat feel broken on a slow connection.
/// * **A poll cursor that only polls move.** [lastServerMessageId] is advanced
///   *only* by poll responses. If a send response advanced it, an admin reply
///   that landed between the send request and its response would fall into the
///   gap and never be fetched.
/// * **Silent failure.** A failed poll does not surface an error; the next tick
///   tries again. A failed *send* does, because the user is looking at their
///   message and needs to know it did not go out.
class ChatProvider extends ChangeNotifier with WidgetsBindingObserver {
  /// Longest message the server accepts.
  ///
  /// Matches iOS. Enforced client-side so an over-long message fails
  /// immediately rather than after a round-trip.
  static const int maxMessageLength = 2000;

  /// How often to poll for new messages while visible.
  static const Duration pollInterval = Duration(seconds: 5);

  final ChatApi _api;
  final Uuid _uuid;

  final List<ChatDisplayMessage> _messages = [];
  final Set<String> _seenServerMessageIds = {};

  /// Only ever written by [_fetchNewMessages].
  String? _lastServerMessageId;

  Timer? _pollTimer;
  bool _hasLoaded = false;
  bool _isSending = false;

  /// True once any fetch has succeeded.
  ///
  /// While this is false after the first attempt the view shows an error state
  /// rather than an inviting empty chat, and polling keeps retrying underneath.
  bool _hasLoadedSuccessfully = false;

  /// Server-controlled kill switch; the composer hides when false.
  bool _chatAvailable = true;

  /// Whether a fetch is in flight, so overlapping polls cannot stack up.
  bool _isFetching = false;

  bool _isVisible = true;

  ChatProvider({
    required ApiClient apiClient,
    Uuid? uuid,
  })  : _api = ChatApi(apiClient),
        _uuid = uuid ?? const Uuid();

  /// The conversation, oldest first.
  List<ChatDisplayMessage> get messages => List.unmodifiable(_messages);

  /// Whether the first fetch has finished, successfully or not. Drives the
  /// spinner-versus-error decision.
  bool get hasLoaded => _hasLoaded;

  /// Whether a fetch has ever succeeded.
  bool get hasLoadedSuccessfully => _hasLoadedSuccessfully;

  bool get isSending => _isSending;

  /// Whether the server currently allows messaging.
  bool get chatAvailable => _chatAvailable;

  /// Whether any admin message arrived during this session while the chat was
  /// closed. Drawn as a dot on the board's chat button.
  bool get hasUnread => _unreadCount > 0;

  int _unreadCount = 0;

  /// Number of admin messages that arrived while the chat was not visible.
  int get unreadCount => _unreadCount;

  // -----------------------------------------------------------------------
  // Polling
  // -----------------------------------------------------------------------

  /// Starts polling. Safe to call repeatedly; the previous timer is cancelled.
  ///
  /// A first fetch happens immediately rather than after [pollInterval], so
  /// opening the chat shows a conversation rather than five seconds of nothing.
  void startPolling() {
    stopPolling();
    WidgetsBinding.instance.addObserver(this);
    _isVisible = true;
    unawaited(_fetchNewMessages());
    _pollTimer = Timer.periodic(pollInterval, (_) => _fetchNewMessages());
  }

  /// Stops polling and detaches the lifecycle observer.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isVisible = true;
        // Catch up on everything that arrived while the app was away in one
        // request rather than replaying five seconds of empty polls.
        unawaited(_fetchNewMessages());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _isVisible = false;
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Sending
  // -----------------------------------------------------------------------

  /// Queues [text] and delivers it.
  ///
  /// Returns immediately; watch [messages] for the result. Returns `false` when
  /// the text was empty, too long, or a send is already in flight — the last of
  /// which keeps a double-tap from posting the message twice.
  bool send(String text) {
    final body = text.trim();
    if (body.isEmpty || _isSending) return false;

    final truncated = body.length > maxMessageLength
        ? body.substring(0, maxMessageLength)
        : body;

    final localId = _uuid.v4();
    _messages.add(ChatDisplayMessage(
      id: localId,
      sender: ChatSender.user,
      body: truncated,
      status: ChatMessageStatus.pending,
    ));
    notifyListeners();

    unawaited(_deliver(localId: localId, body: truncated));
    return true;
  }

  /// Retries a failed message.
  void retry(ChatDisplayMessage message) {
    if (message.status != ChatMessageStatus.failed) return;

    final index = _indexOf(message.id);
    if (index < 0) return;

    _messages[index] = _messages[index]
        .copyWith(status: ChatMessageStatus.pending);
    notifyListeners();

    unawaited(_deliver(localId: message.id, body: message.body));
  }

  /// Clears the unread badge, called when the chat view opens.
  void markRead() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Private
  // -----------------------------------------------------------------------

  Future<void> _fetchNewMessages() async {
    // A slow response must not queue up behind the next tick; skipping this
    // round is better than fetching the same window five times.
    if (_isFetching) return;
    _isFetching = true;

    try {
      final result = await _api.fetchMessages(after: _lastServerMessageId);

      if (result.isSuccess) {
        final response = result.data!;
        _chatAvailable = response.chatAvailable;
        _hasLoadedSuccessfully = true;
        _appendNewMessages(response.messages);
      } else {
        // Silent. The next tick retries, and the view keeps showing the last
        // known conversation rather than an error over the user's messages.
        WishKitLogger.log('chat poll failed: ${result.error}');
      }
    } finally {
      _isFetching = false;
      _hasLoaded = true;
      notifyListeners();
    }
  }

  void _appendNewMessages(List<ChatMessage> serverMessages) {
    var appended = false;

    for (final message in serverMessages) {
      if (!_seenServerMessageIds.add(message.id)) continue;
      _messages.add(ChatDisplayMessage(
        id: message.id,
        sender: message.sender,
        body: message.body,
        status: ChatMessageStatus.sent,
      ));
      appended = true;

      if (message.sender == ChatSender.admin && !_isVisible) {
        _unreadCount++;
      }
    }

    if (appended) notifyListeners();

    // Advanced only here, never from a send response — see the class docs.
    if (serverMessages.isNotEmpty) {
      _lastServerMessageId = serverMessages.last.id;
    }
  }

  Future<void> _deliver({required String localId, required String body}) async {
    _isSending = true;
    notifyListeners();

    try {
      final result = await _api.sendMessage(body);

      if (result.isSuccess) {
        final serverMessage = result.data!;
        // Record the id so the next poll does not append the same message a
        // second time, now that the local copy is taking the server's place.
        _seenServerMessageIds.add(serverMessage.id);

        final index = _indexOf(localId);
        if (index >= 0) {
          _messages[index] = ChatDisplayMessage(
            id: serverMessage.id,
            sender: ChatSender.user,
            body: serverMessage.body,
            status: ChatMessageStatus.sent,
          );
        }
      } else {
        WishKitLogger.error('chat send failed: ${result.error}');
        _markFailed(localId);
      }
    } on Object catch (error) {
      WishKitLogger.error('chat send threw: $error');
      _markFailed(localId);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void _markFailed(String localId) {
    final index = _indexOf(localId);
    if (index < 0) return;
    _messages[index] =
        _messages[index].copyWith(status: ChatMessageStatus.failed);
  }

  int _indexOf(String id) =>
      _messages.indexWhere((message) => message.id == id);
}

/// Who sent a chat message.
enum ChatSender {
  user,
  admin;

  /// Parses a raw sender value.
  ///
  /// An unrecognised value becomes [admin] rather than throwing. The server
  /// may add a sender kind — a bot, a system notice — without coordinating with
  /// SDK releases, and a shipped client that throws on an unknown string turns
  /// one new server value into a blank chat screen for every user.
  static ChatSender fromString(String value) => switch (value.trim()) {
        'user' => user,
        _ => admin,
      };
}

/// One message in the support conversation between a user and the app's team.
class ChatMessage {
  final String id;
  final ChatSender sender;
  final String body;

  /// ISO-8601 timestamp, kept as the server's string.
  ///
  /// Not parsed into a `DateTime`: the chat renders newest-last with no
  /// timestamps (iOS does the same), and a parse failure on a cosmetic field
  /// should not be able to hide a message.
  final String createdAt;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: (json['id'] ?? '').toString(),
        sender: ChatSender.fromString((json['sender'] ?? 'admin').toString()),
        body: (json['body'] ?? '').toString(),
        createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      );
}

/// The `/chat/status` response.
class ChatStatusResponse {
  /// Server-controlled kill switch. When false the composer is hidden.
  final bool chatAvailable;

  /// Whether the user has unread admin messages.
  final bool hasUnread;

  const ChatStatusResponse({
    required this.chatAvailable,
    required this.hasUnread,
  });

  factory ChatStatusResponse.fromJson(Map<String, dynamic> json) =>
      ChatStatusResponse(
        // Default to available: a malformed status response should not silently
        // remove the chat from a paying customer's app.
        chatAvailable: json['chatAvailable'] as bool? ?? true,
        hasUnread: json['hasUnread'] as bool? ?? false,
      );
}

/// The `/chat/messages` response.
class ChatMessagesResponse {
  final bool chatAvailable;
  final List<ChatMessage> messages;

  const ChatMessagesResponse({
    required this.chatAvailable,
    required this.messages,
  });

  factory ChatMessagesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['messages'] as List<dynamic>? ?? const [];
    return ChatMessagesResponse(
      chatAvailable: json['chatAvailable'] as bool? ?? true,
      messages: raw
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList(growable: false),
    );
  }
}

/// Delivery state of a message in the UI.
enum ChatMessageStatus {
  /// Confirmed by the server.
  sent,

  /// Shown optimistically, request in flight.
  pending,

  /// The request failed. Tapping retries.
  failed,
}

/// A message in the UI, which is either on the wire or on its way there.
class ChatDisplayMessage {
  /// Stable identity.
  ///
  /// Server ids for delivered messages, a locally generated UUID for messages
  /// that have not been acknowledged yet, so a message never changes identity
  /// under the user's finger between optimistic render and confirmation.
  final String id;

  final ChatSender sender;
  final String body;
  final ChatMessageStatus status;

  const ChatDisplayMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.status,
  });

  /// Whether this is the user's own message, which decides the bubble side.
  bool get isMine => sender == ChatSender.user;

  ChatDisplayMessage copyWith({
    String? id,
    ChatSender? sender,
    String? body,
    ChatMessageStatus? status,
  }) =>
      ChatDisplayMessage(
        id: id ?? this.id,
        sender: sender ?? this.sender,
        body: body ?? this.body,
        status: status ?? this.status,
      );
}

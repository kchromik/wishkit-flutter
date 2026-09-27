import '../models/chat_message.dart';
import 'api_client.dart';

/// API methods for the support chat.
///
/// Port of iOS's `ChatService`. Endpoints:
/// * `GET  /chat/status` — is the chat available, is anything unread
/// * `GET  /chat/messages` — the full thread, or `?after=<id>` for newer only
/// * `POST /chat/message`
class ChatApi {
  static const String _base = '/chat';

  final ApiClient _client;

  ChatApi(this._client);

  /// Whether the chat exists at all for this customer, and whether there is
  /// anything unread. Used to draw the unread dot on the board's chat button.
  Future<ApiResult<ChatStatusResponse>> fetchStatus() {
    return _client.get<ChatStatusResponse>(
      '$_base/status',
      (json) => ChatStatusResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Fetches messages.
  ///
  /// Without [after] this returns the whole thread; with it, only messages newer
  /// than that id. The `after` cursor exists so a long conversation does not
  /// re-download itself every five seconds.
  Future<ApiResult<ChatMessagesResponse>> fetchMessages({String? after}) {
    final query = after == null || after.isEmpty ? '' : '?after=$after';
    return _client.get<ChatMessagesResponse>(
      '$_base/messages$query',
      (json) => ChatMessagesResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Sends a message and returns the server's copy.
  Future<ApiResult<ChatMessage>> sendMessage(String body) {
    return _client.post<ChatMessage>(
      '$_base/message',
      {'body': body},
      (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );
  }
}

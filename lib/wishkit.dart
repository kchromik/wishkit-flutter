/// WishKit Flutter SDK
///
/// Collect user feedback and feature requests from inside your app, and read
/// and reply to them from the wishkit.io dashboard.
///
/// ```dart
/// void main() {
///   WishKit.configure(apiKey: 'your-api-key');
///   runApp(const MyApp());
/// }
///
/// // somewhere in your app
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => WishKit.feedbackPage()),
/// );
/// ```
library wishkit;

// Main entry point
export 'src/wishkit.dart';

// Models
export 'src/models/wish.dart';
export 'src/models/user.dart';
export 'src/models/comment.dart';
export 'src/models/wish_state.dart';
export 'src/models/payment.dart';
export 'src/models/chat_message.dart';

// Configuration
export 'src/config/configuration.dart';
export 'src/config/theme.dart';
export 'src/config/localization.dart';

// Utilities worth exposing: hosts that render their own feedback UI need the
// same filtering, validation and language detection the SDK uses internally.
export 'src/utilities/wish_filtering.dart';
export 'src/utilities/validation.dart';
export 'src/utilities/detected_language.dart';
export 'src/utilities/feedback_language.dart';
export 'src/utilities/translator.dart';
export 'src/utilities/date_format.dart';

// State management
export 'src/state/wish_model.dart';
export 'src/state/wishlist_view_model.dart';
export 'src/state/create_wish_view_model.dart';
export 'src/state/detail_wish_view_model.dart';
export 'src/state/chat_provider.dart';

// Networking, for hosts that proxy or instrument the API
export 'src/api/api_client.dart';
export 'src/api/wish_api.dart';
export 'src/api/comment_api.dart';
export 'src/api/chat_api.dart';

// UI components
export 'src/ui/wishlist_view.dart';
export 'src/ui/wish_card.dart';
export 'src/ui/detail_wish_view.dart';
export 'src/ui/create_wish_view.dart';
export 'src/ui/chat_view.dart';
export 'src/ui/widgets/add_button.dart';
export 'src/ui/widgets/chat_button.dart';
export 'src/ui/widgets/comment_list.dart';
export 'src/ui/widgets/segmented_control.dart';
export 'src/ui/widgets/skeleton_list.dart';
export 'src/ui/widgets/status_badge.dart';
export 'src/ui/widgets/translate_section.dart';
export 'src/ui/widgets/vote_button.dart';
export 'src/ui/widgets/watermark.dart';

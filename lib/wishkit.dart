/// WishKit Flutter SDK
///
/// A Flutter package for collecting user feedback and feature requests.
library wishkit;

// Main entry point
export 'src/wishkit.dart';

// Models
export 'src/models/wish.dart';
export 'src/models/user.dart';
export 'src/models/comment.dart';
export 'src/models/wish_state.dart';
export 'src/models/payment.dart';

// Configuration
export 'src/config/configuration.dart';
export 'src/config/theme.dart';
export 'src/config/localization.dart';

// State Management
export 'src/state/wish_provider.dart';

// UI Components
export 'src/ui/wishlist_view.dart';
export 'src/ui/wish_card.dart';
export 'src/ui/detail_wish_view.dart';
export 'src/ui/create_wish_view.dart';

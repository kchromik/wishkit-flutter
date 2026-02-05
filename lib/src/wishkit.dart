import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'api/user_api.dart';
import 'config/configuration.dart';
import 'config/theme.dart';
import 'models/payment.dart';
import 'models/user.dart';
import 'state/wish_provider.dart';
import 'ui/wishlist_view.dart';

/// Main entry point for the WishKit SDK.
class WishKit {
  static WishKit? _instance;
  static String? _apiKey;
  static ApiClient? _apiClient;

  /// Theme configuration.
  static WishKitTheme theme = const WishKitTheme();

  /// SDK configuration.
  static WishKitConfiguration config = WishKitConfiguration();

  /// User information for tracking.
  static final UserInfo _userInfo = UserInfo();

  WishKit._();

  /// Configures the SDK with your API key.
  ///
  /// Call this method before using any WishKit features, typically in your
  /// app's main() function or in initState() of your root widget.
  ///
  /// ```dart
  /// void main() {
  ///   WishKit.configure(apiKey: 'your-api-key');
  ///   runApp(MyApp());
  /// }
  /// ```
  static void configure({
    required String apiKey,
    String? appName,
    String? baseUrl,
  }) {
    _apiKey = apiKey;
    _apiClient = ApiClient(
      apiKey: apiKey,
      appName: appName,
      baseUrl: baseUrl,
    );
    _instance = WishKit._();
  }

  /// Gets the singleton instance.
  static WishKit get instance {
    if (_instance == null) {
      throw StateError(
        'WishKit has not been configured. Call WishKit.configure() first.',
      );
    }
    return _instance!;
  }

  /// Gets the API client.
  static ApiClient get apiClient {
    if (_apiClient == null) {
      throw StateError(
        'WishKit has not been configured. Call WishKit.configure() first.',
      );
    }
    return _apiClient!;
  }

  /// Checks if WishKit has been configured.
  static bool get isConfigured => _instance != null && _apiKey != null;

  /// Updates the user's custom ID.
  static Future<void> updateUserCustomId(String customId) async {
    _userInfo.customId = customId;
    await _updateUser();
  }

  /// Updates the user's email.
  static Future<void> updateUserEmail(String email) async {
    _userInfo.email = email;
    await _updateUser();
  }

  /// Updates the user's name.
  static Future<void> updateUserName(String name) async {
    _userInfo.name = name;
    await _updateUser();
  }

  /// Updates the user's payment information.
  static Future<void> updateUserPayment(Payment payment) async {
    _userInfo.paymentPerMonth = payment.monthlyAmountInCents;
    await _updateUser();
  }

  static Future<void> _updateUser() async {
    if (_apiClient == null) return;
    final userApi = UserApi(_apiClient!);
    await userApi.update(_userInfo);
  }

  /// Creates a WishProvider for state management.
  static WishProvider createProvider() {
    return WishProvider(apiClient: apiClient);
  }

  /// Returns the feedback list view wrapped with the necessary providers.
  ///
  /// This is the main widget to display the feature request list.
  ///
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(builder: (_) => WishKit.feedbackListView()),
  /// );
  /// ```
  static Widget feedbackListView() {
    return ChangeNotifierProvider(
      create: (_) => createProvider(),
      child: const WishlistView(),
    );
  }

  /// Returns the feedback list view with a Scaffold and AppBar.
  ///
  /// Use this for easy integration as a full page.
  ///
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(builder: (_) => WishKit.feedbackPage()),
  /// );
  /// ```
  static Widget feedbackPage({String? title}) {
    return ChangeNotifierProvider(
      create: (_) => createProvider(),
      child: WishlistPage(title: title),
    );
  }
}

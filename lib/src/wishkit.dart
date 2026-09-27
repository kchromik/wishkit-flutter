import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/api_client.dart';
import 'api/chat_api.dart';
import 'api/user_api.dart';
import 'config/configuration.dart';
import 'config/theme.dart';
import 'models/chat_message.dart';
import 'models/payment.dart';
import 'models/user.dart';
import 'state/wish_model.dart';
import 'ui/chat_view.dart';
import 'ui/wishlist_view.dart';
import 'utilities/translator.dart';

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
  /// Call this before using any WishKit feature, typically in `main()` or in
  /// `initState` of your root widget.
  ///
  /// ```dart
  /// void main() {
  ///   WishKit.configure(apiKey: 'your-api-key');
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// ## Translation
  ///
  /// Pass [translator] to switch on the in-app "See translation" affordance.
  /// WishKit deliberately ships no translation engine: on iOS it is Apple's
  /// on-device `Translation` framework, which has no Flutter equivalent, and a
  /// cloud service would mean the user's feedback leaving the device. So the
  /// host supplies the engine, and WishKit handles detection, the toggle and
  /// the localization around it.
  ///
  /// ```dart
  /// WishKit.configure(
  ///   apiKey: 'your-api-key',
  ///   translator: (request) async {
  ///     return const WishKitTranslation.unchanged();
  ///   },
  /// );
  /// ```
  ///
  /// See [WishKitConfiguration.translateButton] for when the button appears.
  ///
  /// ## Privacy
  ///
  /// [appId] — the app's bundle id — is sent as `x-wishkit-sdk-bundle-id` in
  /// release builds only, matching iOS's `AppEnvironment.isProduction` guard.
  /// A bundle id identifies an app precisely, and a developer debugging against
  /// production does not need to identify themselves that way in their own
  /// traffic.
  static void configure({
    required String apiKey,
    String? appName,
    String? appId,
    String? baseUrl,
    WishKitTranslator? translator,
  }) {
    _apiKey = apiKey;
    _apiClient = ApiClient(
      apiKey: apiKey,
      appName: appName,
      appId: appId,
      baseUrl: baseUrl,
    );
    if (translator != null) config.translator = translator;
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

  /// Whether WishKit has been configured.
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
    await UserApi(_apiClient!).update(_userInfo);
  }

  /// Creates the [WishModel] that backs every WishKit screen.
  ///
  /// The write actions are injectable, so a test or a host that proxies the API
  /// can observe or replace them:
  ///
  /// ```dart
  /// WishModel(
  ///   apiClient: WishKit.apiClient,
  ///   createWishAction: (request) => myBackend.create(request),
  /// );
  /// ```
  static WishModel createProvider() => WishModel(apiClient: apiClient);

  /// The feedback board, with the [WishModel] it needs installed above it.
  ///
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(builder: (_) => WishKit.feedbackListView()),
  /// );
  /// ```
  static Widget feedbackListView() {
    return ChangeNotifierProvider<WishModel>(
      create: (_) => createProvider(),
      child: const WishlistView(),
    );
  }

  /// The feedback board as a full page with its own navigation bar.
  ///
  /// ```dart
  /// Navigator.push(
  ///   context,
  ///   MaterialPageRoute(builder: (_) => WishKit.feedbackPage()),
  /// );
  /// ```
  static Widget feedbackPage({String? title}) {
    return ChangeNotifierProvider<WishModel>(
      create: (_) => createProvider(),
      child: WishlistView(title: title),
    );
  }

  /// Chat between your app's users and you. Place it anywhere:
  /// `WishKit.ChatView()`.
  ///
  /// The feedback board also shows a floating chat button by default; see
  /// [WishKitConfiguration.showChatButtonInFeedbackView].
  ///
  /// Named in PascalCase on purpose so the Flutter call site reads exactly like
  /// the Swift one, which is the point of the port.
  // ignore: non_constant_identifier_names
  static Widget ChatView() => const WishKitChatView();

  /// Whether chat is available and the user has unread replies.
  ///
  /// Lets a host badge its own chat entry point. Call it whenever it fits — for
  /// example on foreground — the SDK does not poll this itself. Returns
  /// `null` when the SDK is unconfigured or the check failed, which is distinct
  /// from "available, nothing unread".
  static Future<ChatStatusResponse?> chatStatus() async {
    if (!isConfigured) return null;
    final result = await ChatApi(apiClient).fetchStatus();
    return result.isSuccess ? result.data : null;
  }
}

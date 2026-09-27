# WishKit Flutter SDK

A Flutter package for collecting user feedback and feature requests in your app — now with **full parity to the WishKit iOS SDK**.

## What's New (v1.0.0 — iOS Parity Release)

This release ports every major feature from the [WishKit iOS SDK](https://github.com/wishkit/wishkit-ios):

| Feature | Status |
|---------|--------|
| **In-app translation** | ✅ Host-provided callback, no cloud dependency |
| **Language detection** | ✅ 17 scripts, hand-rolled, privacy-preserving |
| **Localization** | ✅ 17 languages via `flutter gen-l10n` + ARB |
| **Chat** | ✅ Optimistic send, 5s polling, retry on failure |
| **Vote guards** | ✅ Completed/implemented blocked, `allowUndoVote` toggle |
| **Segmented control** | ✅ Open/Closed + per-state (`visibleStates`) |
| **Watermark** | ✅ Plan-level `shouldShowWatermark` from server |
| **Full test coverage** | ✅ 157 tests mirroring iOS test suite |

---

## Installation

```yaml
dependencies:
  wishkit:
    git:
      url: https://github.com/<your-github-account>/wishkit-flutter.git
```

---

## Quick Start

### 1. Configure the SDK

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wishkit/wishkit.dart';

void main() {
  WishKit.configure(apiKey: 'your-api-key');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        ...WishKitLocalizations.localizationsDelegates,
        ...GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: WishKitLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
```

### 2. Show the Feedback View

```dart
// Full page with navigation bar
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => WishKit.feedbackPage()),
);

// Or embed the list directly
WishKit.feedbackListView()
```

### 3. Enable Translation (Optional)

```dart
// In main() after configure()
WishKit.config.translator = (requests) async {
  // Use ML Kit, Google Translate, on-device model, etc.
  final results = <WishKitTranslation>[];
  for (final request in requests) {
    final translated = await yourEngine.translate(
      request.sourceText,
      from: request.sourceLanguage,
      to: request.targetLanguage,
    );
    results.add(WishKitTranslation(
      sourceText: request.sourceText,
      targetText: translated,
      clientIdentifier: request.clientIdentifier,
    ));
  }
  return results;
};

// Configure when the button appears
WishKit.config.translateButton = TranslateButton.automatic; // hide | always | automatic
```

---

## Configuration

### Theme

```dart
WishKit.theme = WishKitTheme(
  primaryColor: Colors.blue,      // nullable — null uses system primary
  cornerRadius: 12.0,             // nullable — default 8
  dropShadow: Display.show,       // show | hide
  badgeTheme: BadgeTheme(
    pending: ColorScheme(light: Colors.orange, dark: Colors.orangeAccent),
    completed: ColorScheme(light: Colors.green, dark: Colors.greenAccent),
  ),
);
```

### Core Configuration

```dart
WishKit.config = WishKitConfiguration(
  // UI visibility
  statusBadge: Display.show,           // show | hide
  commentSection: Display.show,        // show | hide
  emailField: EmailField.optional,     // none | optional | required
  allowUndoVote: true,                 // let users take back their vote

  // Translation
  translateButton: TranslateButton.automatic, // hide | always | automatic
  translator: null,                    // set to enable translation

  // Segmented control (Open/Closed by default)
  visibleStates: null,                 // null = Open/Closed; or [WishState.planned, ...]
  showAllTab: false,                   // prepend "All" tab
  defaultState: null,                  // which tab opens first

  // Chat
  showChatButtonInFeedbackView: true,  // floating chat button on the board

  // Debug / compliance
  showDebugLogs: false,                // logs API traffic
  shouldShowWatermark: null,           // server-controlled, read from fetch
);
```

### Button Configuration

```dart
WishKit.config.buttons = ButtonsConfiguration(
  addButton: AddButtonConfiguration(
    display: Display.show,
    location: AddButtonLocation.floating, // floating | navigationBar
    listBottomPadding: 80.0,              // space above FAB
  ),
  segmentedControl: SegmentedControlConfiguration(
    display: Display.show,
  ),
  voteButton: VoteButtonConfiguration(
    icon: Icons.thumb_up,          // custom vote icon
  ),
  doneButton: DoneButtonConfiguration(
    display: Display.show,         // show Done in nav bar
  ),
);
```

### Localization

All 60 iOS strings + 4 Flutter-only strings are bundled in 17 languages.
Override any key:

```dart
WishKit.config.localization = WishKitLocalization(
  open: 'Open Requests',
  closed: 'Shipped',
  upvote: 'Upvote',
  somethingWentWrong: 'Oops, something failed',
  // Flutter-only (English until you override):
  removeVoteButton: 'Remove Vote',
  noComments: 'No comments yet',
  emailPlaceholder: 'your@email.com',
  descriptionPlaceholder: 'Describe the feature…',
);

// Pin to a specific locale regardless of app language:
WishKit.config.localization = WishKitLocalization.en();
WishKit.config.localization = WishKitLocalization.de();
```

---

## User Tracking

```dart
await WishKit.updateUserCustomId('user-123');
await WishKit.updateUserEmail('user@example.com');
await WishKit.updateUserName('John Doe');
await WishKit.updateUserPayment(Payment.monthly(9.99));
```

---

## Chat

```dart
// Show chat anywhere in your app
WishKit.ChatView()

// Badge your own chat entry point
final status = await WishKit.chatStatus();
if (status?.hasUnread == true) showBadge();
```

---

## API Reference

### WishKit

| Method | Description |
|--------|-------------|
| `configure({apiKey, appName, appId, baseUrl, translator})` | Initialize SDK |
| `feedbackListView()` | Embeddable list widget |
| `feedbackPage({title})` | Full page with AppBar |
| `ChatView()` | Chat screen widget |
| `chatStatus()` | Returns `{chatAvailable, hasUnread}` or `null` |
| `isConfigured` | Whether SDK is initialized |
| `apiClient` | Access the underlying `ApiClient` |
| `updateUserCustomId/Email/Name/Payment` | User tracking |

### Configuration Enums

| Enum | Values |
|------|--------|
| `Display` | `show` \| `hide` |
| `EmailField` | `none` \| `optional` \| `required` |
| `TranslateButton` | `hide` \| `always` \| `automatic` |
| `AddButtonLocation` | `floating` \| `navigationBar` |
| `WishState` | `pending` \| `inReview` \| `planned` \| `inProgress` \| `completed` \| `implemented` \| `rejected` |
| `WishFilter` | `all` \| `open` \| `closed` \| `byState(WishState)` |

### WishState Descriptions

| State | Description |
|-------|-------------|
| `pending` | New request awaiting review |
| `inReview` | Currently being evaluated |
| `planned` | Scheduled for development |
| `inProgress` | Currently being developed |
| `completed` | Feature has been released |
| `implemented` | Released (alias for completed in Closed tab) |
| `rejected` | Request was declined (hidden by default) |

---

## Migration from Pre-1.0

| Old | New |
|-----|-----|
| `WishProvider` | `WishModel` (alias `WishProvider = WishModel` kept for compatibility) |
| `localization.xxx` | `context.l10n.xxx` (via `WishKitLocalizations.delegate`) |
| `VoteWishRequest` constructor | Unchanged |
| `createWish()` returning `Future<void>` | Now `Future<bool>` |
| `addComment()` | Renamed to `createComment()` returning `Future<Comment?>` |
| `DetailWishViewModel.toggleVote()` | Now returns `Future<VoteOutcome>` |

---

## Example App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wishkit/wishkit.dart';

void main() {
  WishKit.configure(
    apiKey: 'your-api-key',
    appId: 'com.myapp.flutter',      // sent as x-wishkit-sdk-bundle-id in release
    translator: myTranslationEngine, // optional
  );

  WishKit.theme = WishKitTheme(primaryColor: Colors.indigo);
  WishKit.config = WishKitConfiguration(
    emailField: EmailField.required,
    translateButton: TranslateButton.automatic,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        ...WishKitLocalizations.localizationsDelegates,
        ...GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: WishKitLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WishKit.feedbackPage()),
          ),
          child: const Text('Give Feedback'),
        ),
      ),
    );
  }
}
```

---

## Supported Locales

17 languages (matching iOS):

`en`, `da`, `de`, `es`, `fi`, `fr`, `it`, `ja`, `ko`, `nb`, `nl`, `pl`, `pt`, `pt_BR`, `sv`, `tr`, `zh`, `zh_Hans`, `zh_Hant`

---

## Privacy

- **No cloud dependencies**: Translation runs on a host-provided callback
- **No analytics**: Only the API calls you configure
- **App ID only in release**: `x-wishkit-sdk-bundle-id` header sent only outside debug builds
- **Local UUID**: Stored in `SharedPreferences`, never leaves device

See [`PRIVACY.md`](PRIVACY.md) for the full privacy manifest.

---

## License

MIT License — see [LICENSE](LICENSE) for details.
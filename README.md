# WishKit Flutter SDK

A Flutter package for collecting user feedback and feature requests in your app.

## Installation

Add WishKit to your `pubspec.yaml`:

```yaml
dependencies:
  wishkit:
    git:
      url: https://github.com/wishkit/wishkit-flutter.git
```

## Quick Start

### 1. Configure the SDK

Configure WishKit in your app's `main()` function:

```dart
import 'package:wishkit/wishkit.dart';

void main() {
  WishKit.configure(apiKey: 'your-api-key');
  runApp(MyApp());
}
```

### 2. Show the Feedback View

Navigate to the feedback page:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => WishKit.feedbackPage()),
);
```

Or use the view directly in your widget tree:

```dart
WishKit.feedbackListView()
```

## Configuration

### Theme

Customize the appearance:

```dart
WishKit.theme = WishKitTheme(
  primaryColor: Colors.blue,
  badgeTheme: BadgeTheme(
    pending: ColorScheme(light: Colors.orange, dark: Colors.orangeAccent),
    completed: ColorScheme(light: Colors.green, dark: Colors.greenAccent),
  ),
);
```

### Configuration Options

```dart
WishKit.config = WishKitConfiguration(
  statusBadge: Display.show,
  emailField: EmailField.optional,
  commentSection: Display.show,
  allowUndoVote: false,
  cornerRadius: 16,
  expandDescriptionInList: false,
);
```

### Localization

Customize all text strings:

```dart
WishKit.config.localization = WishKitLocalization(
  featureRequest: 'Feature Request',
  pending: 'Pending',
  completed: 'Completed',
  noWishes: 'No feature requests yet',
  // ... and many more
);
```

### Button Configuration

```dart
WishKit.config.buttons = ButtonsConfiguration(
  addButton: AddButtonConfiguration(
    display: Display.show,
    location: AddButtonLocation.floating,
    bottomPadding: Padding.medium,
  ),
  segmentedControl: SegmentedControlConfiguration(
    display: Display.show,
  ),
);
```

## User Tracking

Track user information for better insights:

```dart
// Set custom user ID
await WishKit.updateUserCustomId('user-123');

// Set user email
await WishKit.updateUserEmail('user@example.com');

// Set user name
await WishKit.updateUserName('John Doe');

// Track payment info
await WishKit.updateUserPayment(Payment.monthly(9.99));
```

## API Reference

### WishKit

| Method | Description |
|--------|-------------|
| `configure(apiKey:)` | Initialize the SDK with your API key |
| `feedbackListView()` | Returns the main feedback list widget |
| `feedbackPage()` | Returns a full page with AppBar |
| `updateUserCustomId(id)` | Set custom user identifier |
| `updateUserEmail(email)` | Set user email |
| `updateUserName(name)` | Set user display name |
| `updateUserPayment(payment)` | Set payment tracking info |

### Payment Types

| Type | Example |
|------|---------|
| `Payment.weekly(amount)` | `Payment.weekly(2.99)` |
| `Payment.monthly(amount)` | `Payment.monthly(9.99)` |
| `Payment.yearly(amount)` | `Payment.yearly(99.99)` |

### WishState

| State | Description |
|-------|-------------|
| `pending` | New request awaiting review |
| `inReview` | Currently being evaluated |
| `planned` | Scheduled for development |
| `inProgress` | Currently being developed |
| `completed` | Feature has been released |
| `rejected` | Request was declined |

## Example

```dart
import 'package:flutter/material.dart';
import 'package:wishkit/wishkit.dart';

void main() {
  WishKit.configure(apiKey: 'your-api-key');

  // Optional: customize theme
  WishKit.theme = WishKitTheme(
    primaryColor: Colors.indigo,
  );

  // Optional: customize config
  WishKit.config = WishKitConfiguration(
    statusBadge: Display.show,
    emailField: EmailField.required,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WishKit.feedbackPage(title: 'Feature Requests'),
              ),
            );
          },
          child: Text('Give Feedback'),
        ),
      ),
    );
  }
}
```

## License

MIT License - see LICENSE file for details.

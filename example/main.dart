import 'package:flutter/material.dart';
import 'package:wishkit/wishkit.dart';

void main() {
  // Configure WishKit with your API key
  WishKit.configure(apiKey: 'your-api-key-here');

  // Optional: Customize the theme
  WishKit.theme = WishKitTheme(
    primaryColor: Colors.indigo,
    badgeTheme: WishKitBadgeTheme(
      pending: WishKitColorScheme(
        light: Colors.orange,
        dark: Colors.orangeAccent,
      ),
      completed: WishKitColorScheme(
        light: Colors.green,
        dark: Colors.greenAccent,
      ),
    ),
  );

  // Optional: Customize the configuration
  WishKit.config = WishKitConfiguration(
    statusBadge: Display.show,
    emailField: EmailField.optional,
    commentSection: Display.show,
    allowUndoVote: true,
    cornerRadius: 12,
  );

  // Optional: Customize localization
  WishKit.config.localization = WishKitLocalization(
    featureRequest: 'Feature Requests',
    noWishes: 'No requests yet. Be the first!',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WishKit Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WishKit Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to WishKit Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Collect user feedback with ease',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WishKit.feedbackPage(
                      title: 'Feature Requests',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Open Feature Requests'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                // Example: Set user info for tracking
                await WishKit.updateUserCustomId('user-123');
                await WishKit.updateUserEmail('demo@example.com');
                await WishKit.updateUserName('Demo User');
                await WishKit.updateUserPayment(Payment.monthly(9.99));

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User info updated!')),
                  );
                }
              },
              child: const Text('Set User Info'),
            ),
          ],
        ),
      ),
    );
  }
}

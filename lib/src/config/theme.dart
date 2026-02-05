import 'package:flutter/material.dart';

/// Theme configuration for WishKit.
class WishKitTheme {
  /// Primary color used for buttons, highlights, etc.
  final Color primaryColor;

  /// Secondary color used for cards, text fields.
  final WishKitColorScheme? secondaryColor;

  /// Tertiary color used for backgrounds.
  final WishKitColorScheme? tertiaryColor;

  /// Text color for titles and descriptions.
  final WishKitColorScheme? textColor;

  /// Badge colors for different states.
  final WishKitBadgeTheme badgeTheme;

  const WishKitTheme({
    this.primaryColor = Colors.green,
    this.secondaryColor,
    this.tertiaryColor,
    this.textColor,
    this.badgeTheme = const WishKitBadgeTheme(),
  });

  /// Creates a copy with modified values.
  WishKitTheme copyWith({
    Color? primaryColor,
    WishKitColorScheme? secondaryColor,
    WishKitColorScheme? tertiaryColor,
    WishKitColorScheme? textColor,
    WishKitBadgeTheme? badgeTheme,
  }) {
    return WishKitTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
      textColor: textColor ?? this.textColor,
      badgeTheme: badgeTheme ?? this.badgeTheme,
    );
  }
}

/// Color scheme for light and dark mode.
class WishKitColorScheme {
  final Color light;
  final Color dark;

  const WishKitColorScheme({
    required this.light,
    required this.dark,
  });

  /// Gets the appropriate color based on brightness.
  Color resolve(Brightness brightness) {
    return brightness == Brightness.light ? light : dark;
  }
}

/// Theme configuration for status badges.
class WishKitBadgeTheme {
  final WishKitColorScheme pending;
  final WishKitColorScheme inReview;
  final WishKitColorScheme planned;
  final WishKitColorScheme inProgress;
  final WishKitColorScheme completed;
  final WishKitColorScheme rejected;
  final WishKitColorScheme approved;
  final WishKitColorScheme implemented;

  const WishKitBadgeTheme({
    this.pending = const WishKitColorScheme(
      light: Color(0xFFFFA726),
      dark: Color(0xFFFFB74D),
    ),
    this.inReview = const WishKitColorScheme(
      light: Color(0xFF42A5F5),
      dark: Color(0xFF64B5F6),
    ),
    this.planned = const WishKitColorScheme(
      light: Color(0xFF7E57C2),
      dark: Color(0xFF9575CD),
    ),
    this.inProgress = const WishKitColorScheme(
      light: Color(0xFF26A69A),
      dark: Color(0xFF4DB6AC),
    ),
    this.completed = const WishKitColorScheme(
      light: Color(0xFF66BB6A),
      dark: Color(0xFF81C784),
    ),
    this.rejected = const WishKitColorScheme(
      light: Color(0xFFEF5350),
      dark: Color(0xFFE57373),
    ),
    this.approved = const WishKitColorScheme(
      light: Color(0xFF66BB6A),
      dark: Color(0xFF81C784),
    ),
    this.implemented = const WishKitColorScheme(
      light: Color(0xFF66BB6A),
      dark: Color(0xFF81C784),
    ),
  });

  /// Creates a copy with modified values.
  WishKitBadgeTheme copyWith({
    WishKitColorScheme? pending,
    WishKitColorScheme? inReview,
    WishKitColorScheme? planned,
    WishKitColorScheme? inProgress,
    WishKitColorScheme? completed,
    WishKitColorScheme? rejected,
    WishKitColorScheme? approved,
    WishKitColorScheme? implemented,
  }) {
    return WishKitBadgeTheme(
      pending: pending ?? this.pending,
      inReview: inReview ?? this.inReview,
      planned: planned ?? this.planned,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
      rejected: rejected ?? this.rejected,
      approved: approved ?? this.approved,
      implemented: implemented ?? this.implemented,
    );
  }
}

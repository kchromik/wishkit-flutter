import 'dart:ui' show Color;

import 'localization.dart';
import '../models/wish_state.dart';
import '../utilities/translator.dart';
import '../utilities/wish_filtering.dart';

/// Display mode for optional UI elements.
enum Display {
  show,
  hide,
}

/// Email field requirement mode.
enum EmailField {
  none,
  optional,
  required,
}

/// Location of the add button.
enum AddButtonLocation {
  floating,
  navigationBar,
}

/// Padding size options.
enum ButtonPadding {
  small,
  medium,
  large,
}

/// When to offer the "See translation" affordance.
///
/// Port of iOS's `ConfigurationTranslateButton`.
///
/// The affordance only appears at all when [WishKitConfiguration.translator]
/// is set, because WishKit ships no translation engine of its own — that is
/// the same user-visible outcome as iOS on a system older than iOS 18, where
/// Apple's Translation framework is unavailable.
enum TranslateButton {
  /// Offer it only when the feedback's detected language differs from the app's
  /// language. The default, and the only setting that is useful for most apps:
  /// the button is a distraction for everyone whose feedback is already in
  /// their own language.
  automatic,

  /// Always offer it. Covers feedback too short for reliable detection, and
  /// languages WishKit has no way to recognise.
  always,

  /// Never offer it.
  hide,
}

/// Icon drawn on the vote button.
enum WishKitUpvoteIcon {
  /// A chevron. iOS's default, and the lightest visual weight.
  chevronUpIcon,

  /// An upward-pointing arrow in a circle.
  arrowUpIcon,

  /// A thumbs-up.
  thumbUpIcon,
}

/// Configuration for WishKit.
class WishKitConfiguration {
  /// Whether to show status badges on wish cards.
  Display statusBadge;

  /// Host overrides for WishKit's own strings. See [WishKitLocalization].
  WishKitLocalization localization;

  /// Whether to expand description in list view.
  bool expandDescriptionInList;

  /// Whether to show drop shadow on cards.
  ///
  /// Flutter-only: iOS uses the platform's own card elevation, so there is
  /// nothing there to configure.
  Display dropShadow;

  /// Corner radius for cards.
  ///
  /// `null` means 8, which is the iOS pre-26 baseline. iOS raises it to 24 on
  /// iOS 26+ and visionOS to 36, but a Flutter board renders in the host app's
  /// own layout where a 24pt radius on a 4-inch-wide card looks like a pill, so
  /// the conservative value is the default here.
  double? cornerRadius;

  /// The effective corner radius.
  double get resolvedCornerRadius => cornerRadius ?? 8;

  /// Email field mode in create wish form.
  EmailField emailField;

  /// Whether to show the comment section.
  Display commentSection;

  /// Whether to allow users to undo their votes.
  bool allowUndoVote;

  /// Button configurations.
  ButtonsConfiguration buttons;

  /// When to offer the "See translation" affordance.
  TranslateButton translateButton;

  /// Translates a wish into the app's language.
  ///
  /// `null` — the default — disables the translation UI entirely. WishKit
  /// deliberately ships no translation engine: an on-device model would add
  /// megabytes to every host app, and a cloud call would ship users' feedback
  /// text to a third party. Wire up ML Kit, Google Translate or your own
  /// service instead:
  ///
  /// ```dart
  /// WishKit.config.translator = (requests) async { ... };
  /// ```
  ///
  /// See [WishKitTranslator] for the contract.
  WishKitTranslator? translator;

  /// Prints internal debug output — requests, decode failures, submit errors —
  /// to the console.
  ///
  /// Off by default so consumer apps stay quiet in production. Unlike the
  /// previous behaviour this is *not* stripped from release builds: the logs
  /// themselves are, but the flag keeps working, so a crash reporter or a
  /// support session can turn them on without a debug build. iOS made the same
  /// change.
  bool showDebugLogs;

  /// Shows the floating chat button in the feedback board.
  ///
  /// The button additionally hides itself when the server reports the chat is
  /// unavailable, so this is only about the initial presentation.
  bool showChatButtonInFeedbackView;

  // -----------------------------------------------------------------------
  // Flutter-only controls
  //
  // iOS has no equivalents: its segmented control is always the Open/Closed
  // pair, and a host that wants a different set of tabs implements its own
  // view. These stay as opt-in extensions.
  // -----------------------------------------------------------------------

  /// Which states to show in the segmented control.
  ///
  /// `null` — the default — shows the Open/Closed pair, matching iOS.
  /// Note that a raw state maps onto a whole bucket, so `planned` and
  /// `inProgress` produce two identical segments; see
  /// [WishFiltering.stateFilters].
  List<WishState>? visibleStates;

  /// Whether to show the "All" tab in the segmented control.
  bool showAllTab;

  /// Which segment is selected when the board opens.
  ///
  /// `null` — the default — selects Open, matching iOS.
  WishState? defaultState;

  WishKitConfiguration({
    this.statusBadge = Display.hide,
    this.localization = const WishKitLocalization(),
    this.expandDescriptionInList = false,
    this.dropShadow = Display.show,
    this.cornerRadius,
    this.emailField = EmailField.none,
    this.commentSection = Display.show,
    this.allowUndoVote = false,
    ButtonsConfiguration? buttons,
    this.translateButton = TranslateButton.automatic,
    this.translator,
    this.showDebugLogs = false,
    this.showChatButtonInFeedbackView = true,
    this.visibleStates,
    this.showAllTab = false,
    this.defaultState,
  }) : buttons = buttons ?? ButtonsConfiguration();

  /// Creates a copy with modified values.
  WishKitConfiguration copyWith({
    Display? statusBadge,
    WishKitLocalization? localization,
    bool? expandDescriptionInList,
    Display? dropShadow,
    double? cornerRadius,
    EmailField? emailField,
    Display? commentSection,
    bool? allowUndoVote,
    ButtonsConfiguration? buttons,
    TranslateButton? translateButton,
    WishKitTranslator? translator,
    bool? showDebugLogs,
    bool? showChatButtonInFeedbackView,
    List<WishState>? visibleStates,
    bool? showAllTab,
    WishState? defaultState,
  }) {
    return WishKitConfiguration(
      statusBadge: statusBadge ?? this.statusBadge,
      localization: localization ?? this.localization,
      expandDescriptionInList:
          expandDescriptionInList ?? this.expandDescriptionInList,
      dropShadow: dropShadow ?? this.dropShadow,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      emailField: emailField ?? this.emailField,
      commentSection: commentSection ?? this.commentSection,
      allowUndoVote: allowUndoVote ?? this.allowUndoVote,
      buttons: buttons ?? this.buttons,
      translateButton: translateButton ?? this.translateButton,
      translator: translator ?? this.translator,
      showDebugLogs: showDebugLogs ?? this.showDebugLogs,
      showChatButtonInFeedbackView:
          showChatButtonInFeedbackView ?? this.showChatButtonInFeedbackView,
      visibleStates: visibleStates ?? this.visibleStates,
      showAllTab: showAllTab ?? this.showAllTab,
      defaultState: defaultState ?? this.defaultState,
    );
  }
}

/// Configuration for the segmented control.
///
/// The sub-configurations are deliberately mutable, so a host can flip a switch
/// after `WishKit.configure` and have every screen pick it up on its next
/// build. That rules out `const` constructors, which is why
/// [WishKitConfiguration.buttons] is resolved in an initialiser list rather
/// than as a default parameter value.
class ButtonsConfiguration {
  /// Segmented control configuration.
  SegmentedControlConfiguration segmentedControl;

  /// Add button configuration.
  AddButtonConfiguration addButton;

  /// Vote button configuration.
  VoteButtonConfiguration voteButton;

  /// Done button configuration.
  DoneButtonConfiguration doneButton;

  ButtonsConfiguration({
    SegmentedControlConfiguration? segmentedControl,
    AddButtonConfiguration? addButton,
    VoteButtonConfiguration? voteButton,
    DoneButtonConfiguration? doneButton,
  })  : segmentedControl = segmentedControl ?? SegmentedControlConfiguration(),
        addButton = addButton ?? AddButtonConfiguration(),
        voteButton = voteButton ?? VoteButtonConfiguration(),
        doneButton = doneButton ?? DoneButtonConfiguration();

  ButtonsConfiguration copyWith({
    SegmentedControlConfiguration? segmentedControl,
    AddButtonConfiguration? addButton,
    VoteButtonConfiguration? voteButton,
    DoneButtonConfiguration? doneButton,
  }) {
    return ButtonsConfiguration(
      segmentedControl: segmentedControl ?? this.segmentedControl,
      addButton: addButton ?? this.addButton,
      voteButton: voteButton ?? this.voteButton,
      doneButton: doneButton ?? this.doneButton,
    );
  }
}

/// Configuration for segmented control.
class SegmentedControlConfiguration {
  Display display;

  SegmentedControlConfiguration({
    this.display = Display.show,
  });

  /// Hiding the control also collapses the board to a single unfiltered list.
  bool get isVisible => display == Display.show;
}

/// Configuration for add button.
class AddButtonConfiguration {
  Display display;
  AddButtonLocation location;
  ButtonPadding bottomPadding;

  AddButtonConfiguration({
    this.display = Display.show,
    this.location = AddButtonLocation.floating,
    this.bottomPadding = ButtonPadding.medium,
  });

  /// Clears the list under the floating button.
  ///
  /// Material's own `FloatingActionButton` padding, plus room for the bottom
  /// inset, so the list's last row is never trapped underneath it.
  double get listBottomPadding {
    const base = <ButtonPadding, double>{
      ButtonPadding.small: 72,
      ButtonPadding.medium: 88,
      ButtonPadding.large: 104,
    };
    return base[bottomPadding]!;
  }
}

/// Configuration for vote button.
class VoteButtonConfiguration {
  /// Which icon to draw.
  WishKitUpvoteIcon icon;

  VoteButtonConfiguration({
    this.icon = WishKitUpvoteIcon.chevronUpIcon,
  });
}

/// Configuration for done button.
class DoneButtonConfiguration {
  /// Off by default, matching iOS. The host app already has a dismiss affordance
  /// in its own navigation bar, and two "Done" buttons on one screen reads as
  /// a bug.
  Display display;

  /// Overrides the resolved theme colour when set.
  Color? textColor;

  DoneButtonConfiguration({
    this.display = Display.hide,
    this.textColor,
  });
}

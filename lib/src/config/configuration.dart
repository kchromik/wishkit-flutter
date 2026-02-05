import 'localization.dart';
import '../models/wish_state.dart';

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

/// Configuration for WishKit.
class WishKitConfiguration {
  /// Whether to show status badges on wish cards.
  Display statusBadge;

  /// Localization strings.
  WishKitLocalization localization;

  /// Whether to expand description in list view.
  bool expandDescriptionInList;

  /// Whether to show drop shadow on cards.
  Display dropShadow;

  /// Corner radius for cards.
  double cornerRadius;

  /// Email field mode in create wish form.
  EmailField emailField;

  /// Whether to show the comment section.
  Display commentSection;

  /// Whether to allow users to undo their votes.
  bool allowUndoVote;

  /// Button configurations.
  ButtonsConfiguration buttons;

  /// Which states to show in the segmented control.
  /// If null, all states are shown.
  List<WishState>? visibleStates;

  /// Whether to show the "All" tab in the segmented control.
  bool showAllTab;

  /// Default selected state when opening the wishlist.
  WishState? defaultState;

  WishKitConfiguration({
    this.statusBadge = Display.hide,
    WishKitLocalization? localization,
    this.expandDescriptionInList = false,
    this.dropShadow = Display.show,
    this.cornerRadius = 16,
    this.emailField = EmailField.optional,
    this.commentSection = Display.show,
    this.allowUndoVote = false,
    ButtonsConfiguration? buttons,
    this.visibleStates,
    this.showAllTab = true,
    this.defaultState,
  })  : localization = localization ?? WishKitLocalization(),
        buttons = buttons ?? ButtonsConfiguration();

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
    List<WishState>? visibleStates,
    bool? showAllTab,
    WishState? defaultState,
  }) {
    return WishKitConfiguration(
      statusBadge: statusBadge ?? this.statusBadge,
      localization: localization ?? this.localization,
      expandDescriptionInList: expandDescriptionInList ?? this.expandDescriptionInList,
      dropShadow: dropShadow ?? this.dropShadow,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      emailField: emailField ?? this.emailField,
      commentSection: commentSection ?? this.commentSection,
      allowUndoVote: allowUndoVote ?? this.allowUndoVote,
      buttons: buttons ?? this.buttons,
      visibleStates: visibleStates ?? this.visibleStates,
      showAllTab: showAllTab ?? this.showAllTab,
      defaultState: defaultState ?? this.defaultState,
    );
  }
}

/// Configuration for buttons.
class ButtonsConfiguration {
  /// Segmented control configuration.
  SegmentedControlConfiguration segmentedControl;

  /// Add button configuration.
  AddButtonConfiguration addButton;

  /// Vote button configuration.
  VoteButtonConfiguration voteButton;

  /// Save button configuration.
  SaveButtonConfiguration saveButton;

  /// Done button configuration.
  DoneButtonConfiguration doneButton;

  ButtonsConfiguration({
    SegmentedControlConfiguration? segmentedControl,
    AddButtonConfiguration? addButton,
    VoteButtonConfiguration? voteButton,
    SaveButtonConfiguration? saveButton,
    DoneButtonConfiguration? doneButton,
  })  : segmentedControl = segmentedControl ?? SegmentedControlConfiguration(),
        addButton = addButton ?? AddButtonConfiguration(),
        voteButton = voteButton ?? VoteButtonConfiguration(),
        saveButton = saveButton ?? SaveButtonConfiguration(),
        doneButton = doneButton ?? DoneButtonConfiguration();
}

/// Configuration for segmented control.
class SegmentedControlConfiguration {
  Display display;

  SegmentedControlConfiguration({
    this.display = Display.show,
  });
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
}

/// Configuration for vote button.
class VoteButtonConfiguration {
  VoteButtonConfiguration();
}

/// Configuration for save button.
class SaveButtonConfiguration {
  SaveButtonConfiguration();
}

/// Configuration for done button.
class DoneButtonConfiguration {
  Display display;

  DoneButtonConfiguration({
    this.display = Display.show,
  });
}

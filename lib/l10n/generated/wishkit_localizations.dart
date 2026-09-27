import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'wishkit_localizations_da.dart';
import 'wishkit_localizations_de.dart';
import 'wishkit_localizations_en.dart';
import 'wishkit_localizations_es.dart';
import 'wishkit_localizations_fi.dart';
import 'wishkit_localizations_fr.dart';
import 'wishkit_localizations_it.dart';
import 'wishkit_localizations_ja.dart';
import 'wishkit_localizations_ko.dart';
import 'wishkit_localizations_nb.dart';
import 'wishkit_localizations_nl.dart';
import 'wishkit_localizations_pl.dart';
import 'wishkit_localizations_pt.dart';
import 'wishkit_localizations_sv.dart';
import 'wishkit_localizations_tr.dart';
import 'wishkit_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of WishKitLocalizations
/// returned by `WishKitLocalizations.of(context)`.
///
/// Applications need to include `WishKitLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/wishkit_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: WishKitLocalizations.localizationsDelegates,
///   supportedLocales: WishKitLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the WishKitLocalizations.supportedLocales
/// property.
abstract class WishKitLocalizations {
  WishKitLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static WishKitLocalizations of(BuildContext context) {
    return Localizations.of<WishKitLocalizations>(
        context, WishKitLocalizations)!;
  }

  static const LocalizationsDelegate<WishKitLocalizations> delegate =
      _WishKitLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fi'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('sv'),
    Locale('tr'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @requested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get requested;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @implemented.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get implemented;

  /// No description provided for @inReview.
  ///
  /// In en, this message translates to:
  /// **'In Review'**
  String get inReview;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Feature Requests'**
  String get wishlist;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get save;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @upvote.
  ///
  /// In en, this message translates to:
  /// **'Upvote'**
  String get upvote;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @youCanOnlyVoteOnce.
  ///
  /// In en, this message translates to:
  /// **'You can only vote once.'**
  String get youCanOnlyVoteOnce;

  /// No description provided for @youCanNotVoteForACompletedWish.
  ///
  /// In en, this message translates to:
  /// **'You can\'t vote for a feature that is already completed.'**
  String get youCanNotVoteForACompletedWish;

  /// No description provided for @youCanNotVoteForYourOwnWish.
  ///
  /// In en, this message translates to:
  /// **'You cannot vote for your own feature request.'**
  String get youCanNotVoteForYourOwnWish;

  /// No description provided for @poweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by'**
  String get poweredBy;

  /// No description provided for @successfullyCreated.
  ///
  /// In en, this message translates to:
  /// **'Successfully submitted'**
  String get successfullyCreated;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail View'**
  String get detail;

  /// No description provided for @featureWishlist.
  ///
  /// In en, this message translates to:
  /// **'Feature Requests'**
  String get featureWishlist;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @titleOfWish.
  ///
  /// In en, this message translates to:
  /// **'Title of the feature..'**
  String get titleOfWish;

  /// No description provided for @titleDescriptionCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Title/Description cannot be empty.'**
  String get titleDescriptionCannotBeEmpty;

  /// No description provided for @votes.
  ///
  /// In en, this message translates to:
  /// **'Votes'**
  String get votes;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @createWish.
  ///
  /// In en, this message translates to:
  /// **'New Feature Request'**
  String get createWish;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'required'**
  String get required;

  /// No description provided for @emailRequiredText.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get emailRequiredText;

  /// No description provided for @emailFormatWrongText.
  ///
  /// In en, this message translates to:
  /// **'Wrong email format.'**
  String get emailFormatWrongText;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @writeAComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment..'**
  String get writeAComment;

  /// No description provided for @submitComment.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get submitComment;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @noFeatureRequests.
  ///
  /// In en, this message translates to:
  /// **'No feature requests, yet ✨'**
  String get noFeatureRequests;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email (required)'**
  String get emailRequired;

  /// No description provided for @discardEnteredInformation.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardEnteredInformation;

  /// No description provided for @addButtonInNavigationBar.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get addButtonInNavigationBar;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing..'**
  String get refreshing;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again later.'**
  String get somethingWentWrong;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @notSupported.
  ///
  /// In en, this message translates to:
  /// **'Not Supported'**
  String get notSupported;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @activateToSwitchFilter.
  ///
  /// In en, this message translates to:
  /// **'Activate to switch filter.'**
  String get activateToSwitchFilter;

  /// No description provided for @seeTranslation.
  ///
  /// In en, this message translates to:
  /// **'See translation'**
  String get seeTranslation;

  /// No description provided for @seeOriginal.
  ///
  /// In en, this message translates to:
  /// **'See original'**
  String get seeOriginal;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get chat;

  /// No description provided for @writeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message…'**
  String get writeAMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @chatEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Questions or feedback? Send us a message.'**
  String get chatEmptyState;

  /// No description provided for @failedToSendTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Failed to send. Tap to retry.'**
  String get failedToSendTapToRetry;
}

class _WishKitLocalizationsDelegate
    extends LocalizationsDelegate<WishKitLocalizations> {
  const _WishKitLocalizationsDelegate();

  @override
  Future<WishKitLocalizations> load(Locale locale) {
    return SynchronousFuture<WishKitLocalizations>(
        lookupWishKitLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'da',
        'de',
        'en',
        'es',
        'fi',
        'fr',
        'it',
        'ja',
        'ko',
        'nb',
        'nl',
        'pl',
        'pt',
        'sv',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_WishKitLocalizationsDelegate old) => false;
}

WishKitLocalizations lookupWishKitLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return WishKitLocalizationsZhHans();
          case 'Hant':
            return WishKitLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return WishKitLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return WishKitLocalizationsDa();
    case 'de':
      return WishKitLocalizationsDe();
    case 'en':
      return WishKitLocalizationsEn();
    case 'es':
      return WishKitLocalizationsEs();
    case 'fi':
      return WishKitLocalizationsFi();
    case 'fr':
      return WishKitLocalizationsFr();
    case 'it':
      return WishKitLocalizationsIt();
    case 'ja':
      return WishKitLocalizationsJa();
    case 'ko':
      return WishKitLocalizationsKo();
    case 'nb':
      return WishKitLocalizationsNb();
    case 'nl':
      return WishKitLocalizationsNl();
    case 'pl':
      return WishKitLocalizationsPl();
    case 'pt':
      return WishKitLocalizationsPt();
    case 'sv':
      return WishKitLocalizationsSv();
    case 'tr':
      return WishKitLocalizationsTr();
    case 'zh':
      return WishKitLocalizationsZh();
  }

  throw FlutterError(
      'WishKitLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

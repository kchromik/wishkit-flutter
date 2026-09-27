import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../../l10n/generated/wishkit_localizations.dart';
import '../models/wish_state.dart';
import '../utilities/wish_filtering.dart';
import '../wishkit.dart';

/// Host-supplied overrides for WishKit's own strings.
///
/// ## What changed
///
/// This used to be a bag of non-nullable English (and `.de()`) defaults that
/// WishKit rendered verbatim, so a host had to override *every* string to
/// localise anything, and a host that wanted one word translated had to
/// rebuild all 60. Every field is now nullable and means "use the bundled
/// translation for the current app locale".
///
/// The bundled translations are the 17 `.strings` files from the iOS SDK,
/// converted to ARB by `tool/strings_to_arb.dart` and compiled to
/// `WishKitLocalizations` by `flutter gen-l10n`. Add
/// `WishKitLocalizations.delegate` to your app's `localizationsDelegates` and
/// the whole board localises itself:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: const [
///     ...WishKitLocalizations.localizationsDelegates,
///     ...GlobalMaterialLocalizations.delegate,
///   ],
///   supportedLocales: WishKitLocalizations.supportedLocales,
/// );
/// ```
///
/// Overrides still win, key by key:
///
/// ```dart
/// WishKit.config.localization = WishKitLocalization(voteButton: 'Upvote!', title: 'Betreff');
/// ```
///
/// A host that genuinely wants to pin the language regardless of the app
/// locale can use [WishKitLocalization.en] or [WishKitLocalization.de], which
/// behave like the old factories.
class WishKitLocalization {
  final String? requested;
  final String? pending;
  final String? approved;
  final String? implemented;
  final String? inReview;
  final String? planned;
  final String? inProgress;
  final String? completed;
  final String? open;
  final String? closed;
  final String? wishlist;
  final String? save;
  final String? title;
  final String? description;
  final String? upvote;
  final String? info;
  final String? youCanOnlyVoteOnce;
  final String? youCanNotVoteForACompletedWish;
  final String? youCanNotVoteForYourOwnWish;
  final String? poweredBy;
  final String? successfullyCreated;
  final String? done;
  final String? detail;
  final String? featureWishlist;
  final String? confirm;
  final String? cancel;
  final String? ok;
  final String? titleOfWish;
  final String? titleDescriptionCannotBeEmpty;
  final String? votes;
  final String? close;
  final String? createWish;
  final String? optional;
  final String? required;
  final String? emailRequiredText;
  final String? emailFormatWrongText;
  final String? comments;
  final String? writeAComment;
  final String? submitComment;
  final String? admin;
  final String? user;
  final String? noFeatureRequests;
  final String? emailOptional;
  final String? emailRequired;
  final String? discardEnteredInformation;
  final String? addButtonInNavigationBar;
  final String? refresh;
  final String? refreshing;
  final String? somethingWentWrong;
  final String? all;
  final String? notSupported;
  final String? filter;
  final String? activateToSwitchFilter;
  final String? seeTranslation;
  final String? seeOriginal;
  final String? chat;
  final String? writeAMessage;
  final String? send;
  final String? chatEmptyState;
  final String? failedToSendTapToRetry;

  // -----------------------------------------------------------------------
  // Flutter-only strings
  //
  // These have no iOS counterpart, so no translation exists for them. They
  // stay English-only until a host overrides them — deliberately not machine
  // translated, because an unreviewed string in a language the vendor does not
  // speak is worse than an honest English one.
  // -----------------------------------------------------------------------

  /// Label for the button that takes a vote back.
  final String? removeVoteButton;

  /// Shown when a wish has no comments yet.
  final String? noComments;

  /// Placeholder inside the create-wish email field.
  final String? emailPlaceholder;

  /// Placeholder inside the create-wish description field.
  final String? descriptionPlaceholder;

  /// Pins resolution to one bundled locale, ignoring the app's locale.
  ///
  /// `null` — the default — resolves against the widget's locale. Set through
  /// [WishKitLocalization.en] / [WishKitLocalization.de] or directly.
  final Locale? locale;

  const WishKitLocalization({
    this.requested,
    this.pending,
    this.approved,
    this.implemented,
    this.inReview,
    this.planned,
    this.inProgress,
    this.completed,
    this.open,
    this.closed,
    this.wishlist,
    this.save,
    this.title,
    this.description,
    this.upvote,
    this.info,
    this.youCanOnlyVoteOnce,
    this.youCanNotVoteForACompletedWish,
    this.youCanNotVoteForYourOwnWish,
    this.poweredBy,
    this.successfullyCreated,
    this.done,
    this.detail,
    this.featureWishlist,
    this.confirm,
    this.cancel,
    this.ok,
    this.titleOfWish,
    this.titleDescriptionCannotBeEmpty,
    this.votes,
    this.close,
    this.createWish,
    this.optional,
    this.required,
    this.emailRequiredText,
    this.emailFormatWrongText,
    this.comments,
    this.writeAComment,
    this.submitComment,
    this.admin,
    this.user,
    this.noFeatureRequests,
    this.emailOptional,
    this.emailRequired,
    this.discardEnteredInformation,
    this.addButtonInNavigationBar,
    this.refresh,
    this.refreshing,
    this.somethingWentWrong,
    this.all,
    this.notSupported,
    this.filter,
    this.activateToSwitchFilter,
    this.seeTranslation,
    this.seeOriginal,
    this.chat,
    this.writeAMessage,
    this.send,
    this.chatEmptyState,
    this.failedToSendTapToRetry,
    this.removeVoteButton,
    this.noComments,
    this.emailPlaceholder,
    this.descriptionPlaceholder,
    this.locale,
  });

  /// Pins WishKit's strings to English, whatever the app's locale is.
  factory WishKitLocalization.en() =>
      const WishKitLocalization(locale: Locale('en'));

  /// Pins WishKit's strings to German, whatever the app's locale is.
  ///
  /// The only bundled language besides English that this factory has ever
  /// offered. For any other language, let the app's locale decide.
  factory WishKitLocalization.de() =>
      const WishKitLocalization(locale: Locale('de'));

  /// Creates a copy with modified values.
  ///
  /// A `null` argument means "leave as is", so there is no way to *clear* an
  /// override through `copyWith`. Assign a fresh [WishKitLocalization] instead.
  WishKitLocalization copyWith({
    String? requested,
    String? pending,
    String? approved,
    String? implemented,
    String? inReview,
    String? planned,
    String? inProgress,
    String? completed,
    String? open,
    String? closed,
    String? wishlist,
    String? save,
    String? title,
    String? description,
    String? upvote,
    String? info,
    String? youCanOnlyVoteOnce,
    String? youCanNotVoteForACompletedWish,
    String? youCanNotVoteForYourOwnWish,
    String? poweredBy,
    String? successfullyCreated,
    String? done,
    String? detail,
    String? featureWishlist,
    String? confirm,
    String? cancel,
    String? ok,
    String? titleOfWish,
    String? titleDescriptionCannotBeEmpty,
    String? votes,
    String? close,
    String? createWish,
    String? optional,
    String? required,
    String? emailRequiredText,
    String? emailFormatWrongText,
    String? comments,
    String? writeAComment,
    String? submitComment,
    String? admin,
    String? user,
    String? noFeatureRequests,
    String? emailOptional,
    String? emailRequired,
    String? discardEnteredInformation,
    String? addButtonInNavigationBar,
    String? refresh,
    String? refreshing,
    String? somethingWentWrong,
    String? all,
    String? notSupported,
    String? filter,
    String? activateToSwitchFilter,
    String? seeTranslation,
    String? seeOriginal,
    String? chat,
    String? writeAMessage,
    String? send,
    String? chatEmptyState,
    String? failedToSendTapToRetry,
    String? removeVoteButton,
    String? noComments,
    String? emailPlaceholder,
    String? descriptionPlaceholder,
    Locale? locale,
  }) {
    return WishKitLocalization(
      requested: requested ?? this.requested,
      pending: pending ?? this.pending,
      approved: approved ?? this.approved,
      implemented: implemented ?? this.implemented,
      inReview: inReview ?? this.inReview,
      planned: planned ?? this.planned,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
      open: open ?? this.open,
      closed: closed ?? this.closed,
      wishlist: wishlist ?? this.wishlist,
      save: save ?? this.save,
      title: title ?? this.title,
      description: description ?? this.description,
      upvote: upvote ?? this.upvote,
      info: info ?? this.info,
      youCanOnlyVoteOnce: youCanOnlyVoteOnce ?? this.youCanOnlyVoteOnce,
      youCanNotVoteForACompletedWish:
          youCanNotVoteForACompletedWish ?? this.youCanNotVoteForACompletedWish,
      youCanNotVoteForYourOwnWish:
          youCanNotVoteForYourOwnWish ?? this.youCanNotVoteForYourOwnWish,
      poweredBy: poweredBy ?? this.poweredBy,
      successfullyCreated: successfullyCreated ?? this.successfullyCreated,
      done: done ?? this.done,
      detail: detail ?? this.detail,
      featureWishlist: featureWishlist ?? this.featureWishlist,
      confirm: confirm ?? this.confirm,
      cancel: cancel ?? this.cancel,
      ok: ok ?? this.ok,
      titleOfWish: titleOfWish ?? this.titleOfWish,
      titleDescriptionCannotBeEmpty:
          titleDescriptionCannotBeEmpty ?? this.titleDescriptionCannotBeEmpty,
      votes: votes ?? this.votes,
      close: close ?? this.close,
      createWish: createWish ?? this.createWish,
      optional: optional ?? this.optional,
      required: required ?? this.required,
      emailRequiredText: emailRequiredText ?? this.emailRequiredText,
      emailFormatWrongText: emailFormatWrongText ?? this.emailFormatWrongText,
      comments: comments ?? this.comments,
      writeAComment: writeAComment ?? this.writeAComment,
      submitComment: submitComment ?? this.submitComment,
      admin: admin ?? this.admin,
      user: user ?? this.user,
      noFeatureRequests: noFeatureRequests ?? this.noFeatureRequests,
      emailOptional: emailOptional ?? this.emailOptional,
      emailRequired: emailRequired ?? this.emailRequired,
      discardEnteredInformation:
          discardEnteredInformation ?? this.discardEnteredInformation,
      addButtonInNavigationBar:
          addButtonInNavigationBar ?? this.addButtonInNavigationBar,
      refresh: refresh ?? this.refresh,
      refreshing: refreshing ?? this.refreshing,
      somethingWentWrong: somethingWentWrong ?? this.somethingWentWrong,
      all: all ?? this.all,
      notSupported: notSupported ?? this.notSupported,
      filter: filter ?? this.filter,
      activateToSwitchFilter: activateToSwitchFilter ?? this.activateToSwitchFilter,
      seeTranslation: seeTranslation ?? this.seeTranslation,
      seeOriginal: seeOriginal ?? this.seeOriginal,
      chat: chat ?? this.chat,
      writeAMessage: writeAMessage ?? this.writeAMessage,
      send: send ?? this.send,
      chatEmptyState: chatEmptyState ?? this.chatEmptyState,
      failedToSendTapToRetry:
          failedToSendTapToRetry ?? this.failedToSendTapToRetry,
      removeVoteButton: removeVoteButton ?? this.removeVoteButton,
      noComments: noComments ?? this.noComments,
      emailPlaceholder: emailPlaceholder ?? this.emailPlaceholder,
      descriptionPlaceholder:
          descriptionPlaceholder ?? this.descriptionPlaceholder,
      locale: locale ?? this.locale,
    );
  }

  /// The overrides, keyed exactly as [_bundleGetters] is.
  ///
  /// Only non-null fields appear, so the resolver can do a single map lookup and
  /// fall through to the bundle.
  Map<String, String> get overrides {
    final result = <String, String>{};
    void put(String key, String? value) {
      if (value != null) result[key] = value;
    }

    put('requested', requested);
    put('pending', pending);
    put('approved', approved);
    put('implemented', implemented);
    put('inReview', inReview);
    put('planned', planned);
    put('inProgress', inProgress);
    put('completed', completed);
    put('open', open);
    put('closed', closed);
    put('wishlist', wishlist);
    put('save', save);
    put('title', title);
    put('description', description);
    put('upvote', upvote);
    put('info', info);
    put('youCanOnlyVoteOnce', youCanOnlyVoteOnce);
    put('youCanNotVoteForACompletedWish', youCanNotVoteForACompletedWish);
    put('youCanNotVoteForYourOwnWish', youCanNotVoteForYourOwnWish);
    put('poweredBy', poweredBy);
    put('successfullyCreated', successfullyCreated);
    put('done', done);
    put('detail', detail);
    put('featureWishlist', featureWishlist);
    put('confirm', confirm);
    put('cancel', cancel);
    put('ok', ok);
    put('titleOfWish', titleOfWish);
    put('titleDescriptionCannotBeEmpty', titleDescriptionCannotBeEmpty);
    put('votes', votes);
    put('close', close);
    put('createWish', createWish);
    put('optional', optional);
    put('required', required);
    put('emailRequiredText', emailRequiredText);
    put('emailFormatWrongText', emailFormatWrongText);
    put('comments', comments);
    put('writeAComment', writeAComment);
    put('submitComment', submitComment);
    put('admin', admin);
    put('user', user);
    put('noFeatureRequests', noFeatureRequests);
    put('emailOptional', emailOptional);
    put('emailRequired', emailRequired);
    put('discardEnteredInformation', discardEnteredInformation);
    put('addButtonInNavigationBar', addButtonInNavigationBar);
    put('refresh', refresh);
    put('refreshing', refreshing);
    put('somethingWentWrong', somethingWentWrong);
    put('all', all);
    put('notSupported', notSupported);
    put('filter', filter);
    put('activateToSwitchFilter', activateToSwitchFilter);
    put('seeTranslation', seeTranslation);
    put('seeOriginal', seeOriginal);
    put('chat', chat);
    put('writeAMessage', writeAMessage);
    put('send', send);
    put('chatEmptyState', chatEmptyState);
    put('failedToSendTapToRetry', failedToSendTapToRetry);
    put('removeVoteButton', removeVoteButton);
    put('noComments', noComments);
    put('emailPlaceholder', emailPlaceholder);
    put('descriptionPlaceholder', descriptionPlaceholder);
    return result;
  }
}

/// One bundled string, as a getter on the generated class.
///
/// Referencing the getter rather than a key string is what makes a renamed
/// `WishKitLocalizations` member a compile error instead of a silent fall-back
/// to English. A key typo in either direction is caught by
/// `test/localization_test.dart`, which asserts the map and the override bag
/// have identical key sets.
typedef _BundleGetter = String Function(WishKitLocalizations);

/// Key-to-bundle mapping. The single source of truth for which strings exist.
final Map<String, _BundleGetter> _bundleGetters = <String, _BundleGetter>{
  'requested': (l) => l.requested,
  'pending': (l) => l.pending,
  'approved': (l) => l.approved,
  'implemented': (l) => l.implemented,
  'inReview': (l) => l.inReview,
  'planned': (l) => l.planned,
  'inProgress': (l) => l.inProgress,
  'completed': (l) => l.completed,
  'open': (l) => l.open,
  'closed': (l) => l.closed,
  'wishlist': (l) => l.wishlist,
  'save': (l) => l.save,
  'title': (l) => l.title,
  'description': (l) => l.description,
  'upvote': (l) => l.upvote,
  'info': (l) => l.info,
  'youCanOnlyVoteOnce': (l) => l.youCanOnlyVoteOnce,
  'youCanNotVoteForACompletedWish':
      (l) => l.youCanNotVoteForACompletedWish,
  'youCanNotVoteForYourOwnWish': (l) => l.youCanNotVoteForYourOwnWish,
  'poweredBy': (l) => l.poweredBy,
  'successfullyCreated': (l) => l.successfullyCreated,
  'done': (l) => l.done,
  'detail': (l) => l.detail,
  'featureWishlist': (l) => l.featureWishlist,
  'confirm': (l) => l.confirm,
  'cancel': (l) => l.cancel,
  'ok': (l) => l.ok,
  'titleOfWish': (l) => l.titleOfWish,
  'titleDescriptionCannotBeEmpty':
      (l) => l.titleDescriptionCannotBeEmpty,
  'votes': (l) => l.votes,
  'close': (l) => l.close,
  'createWish': (l) => l.createWish,
  'optional': (l) => l.optional,
  'required': (l) => l.required,
  'emailRequiredText': (l) => l.emailRequiredText,
  'emailFormatWrongText': (l) => l.emailFormatWrongText,
  'comments': (l) => l.comments,
  'writeAComment': (l) => l.writeAComment,
  'submitComment': (l) => l.submitComment,
  'admin': (l) => l.admin,
  'user': (l) => l.user,
  'noFeatureRequests': (l) => l.noFeatureRequests,
  'emailOptional': (l) => l.emailOptional,
  'emailRequired': (l) => l.emailRequired,
  'discardEnteredInformation': (l) => l.discardEnteredInformation,
  'addButtonInNavigationBar': (l) => l.addButtonInNavigationBar,
  'refresh': (l) => l.refresh,
  'refreshing': (l) => l.refreshing,
  'somethingWentWrong': (l) => l.somethingWentWrong,
  'all': (l) => l.all,
  'notSupported': (l) => l.notSupported,
  'filter': (l) => l.filter,
  'activateToSwitchFilter': (l) => l.activateToSwitchFilter,
  'seeTranslation': (l) => l.seeTranslation,
  'seeOriginal': (l) => l.seeOriginal,
  'chat': (l) => l.chat,
  'writeAMessage': (l) => l.writeAMessage,
  'send': (l) => l.send,
  'chatEmptyState': (l) => l.chatEmptyState,
  'failedToSendTapToRetry': (l) => l.failedToSendTapToRetry,
};

/// The Flutter-only strings, which have no bundled translation.
///
/// See [WishKitLocalization]'s section on them.
const Map<String, String> _flutterOnly = <String, String>{
  'removeVoteButton': 'Remove Vote',
  'noComments': 'No comments yet',
  'emailPlaceholder': 'your@email.com',
  'descriptionPlaceholder': 'Describe the feature you would like to see...',
};

/// Every key WishKit can resolve, bundled and Flutter-only.
Set<String> get wishKitStringKeys => <String>{
      ..._bundleGetters.keys,
      ..._flutterOnly.keys,
    };

/// Resolves WishKit's strings for one place in the tree.
///
/// Built once per [BuildContext] and cheap to read, so widgets just do
/// `context.l10n.voteButton` rather than threading a strings object through
/// their constructors. Resolution happens at build time, which is what lets a
/// single mounted board re-render in a new language when the app's locale
/// changes.
///
/// Resolution order for a key:
///
/// 1. the host's [WishKitLocalization] override, if any;
/// 2. the bundled translation for the widget's locale;
/// 3. English.
///
/// Step 3 is the reason [lookupWishKitLocalizations] is used as a fallback
/// rather than a hard error: a host that has not added
/// `WishKitLocalizations.delegate` to its `localizationsDelegates` — the
/// default state of an existing app upgrading the SDK — must still build a
/// working, English board.
class WishKitStrings {
  /// The host's overrides, already flattened to a map.
  final Map<String, String> overrides;

  /// The bundle resolved for [locale].
  final WishKitLocalizations bundle;

  /// The locale everything is rendered in, used for date formatting and for
  /// language detection.
  final Locale locale;

  WishKitStrings._({
    required this.overrides,
    required this.bundle,
    required this.locale,
  });

  /// Resolves the strings visible at [context].
  factory WishKitStrings.of(
    BuildContext context, {
    required WishKitLocalization localization,
  }) {
    final pinned = localization.locale;
    if (pinned != null) {
      return WishKitStrings._(
        overrides: localization.overrides,
        bundle: _lookupSafely(pinned),
        locale: pinned,
      );
    }

    // `Localizations.of` returns null when the host app has not registered the
    // delegate. Falling back to the platform locale keeps an app that has not
    // opted into `gen-l10n` fully functional in the user's language.
    final bundle =
        Localizations.of<WishKitLocalizations>(context, WishKitLocalizations);
    if (bundle == null) {
      // `Localizations.localeOf` throws without a `Localizations` ancestor,
      // which is exactly the situation this branch handles, so read the
      // platform locale directly instead.
      final fallback = PlatformDispatcher.instance.locale;
      return WishKitStrings._(
        overrides: localization.overrides,
        bundle: _lookupSafely(fallback),
        locale: fallback,
      );
    }

    return WishKitStrings._(
      overrides: localization.overrides,
      bundle: bundle,
      locale: Locale(bundle.localeName),
    );
  }

  /// Resolves the strings for [locale] without a [BuildContext].
  ///
  /// Same order as [WishKitStrings.of], for the places a context does not
  /// exist: composing a notification body or an analytics label in a
  /// `const` context, a background isolate, and the parity test that walks
  /// every bundled locale. Outside a `Localizations` scope there is no
  /// ancestor to ask, so [locale] is authoritative.
  factory WishKitStrings.forLocale(
    Locale locale, {
    WishKitLocalization localization = const WishKitLocalization(),
  }) {
    return WishKitStrings._(
      overrides: localization.overrides,
      bundle: _lookupSafely(locale),
      locale: locale,
    );
  }

  static WishKitLocalizations _lookupSafely(Locale locale) =>
      lookupWishKitLocalizations(locale);

  /// The string for [key].
  ///
  /// Unknown keys return the key itself, which is the ARB key, so a missing
  /// translation is obvious in a screenshot instead of rendering as an empty
  /// gap. The key set is closed and covered by a test, so this is unreachable
  /// in practice.
  String t(String key) {
    final override = overrides[key];
    if (override != null) return override;

    final getter = _bundleGetters[key];
    if (getter != null) return getter(bundle);

    return _flutterOnly[key] ?? key;
  }

  // -----------------------------------------------------------------------
  // Bundled strings
  // -----------------------------------------------------------------------

  String get requested => t('requested');
  String get pending => t('pending');
  String get approved => t('approved');
  String get implemented => t('implemented');
  String get inReview => t('inReview');
  String get planned => t('planned');
  String get inProgress => t('inProgress');
  String get completed => t('completed');
  String get open => t('open');
  String get closed => t('closed');
  String get wishlist => t('wishlist');
  String get save => t('save');
  String get title => t('title');
  String get description => t('description');
  String get upvote => t('upvote');
  String get info => t('info');
  String get youCanOnlyVoteOnce => t('youCanOnlyVoteOnce');
  String get youCanNotVoteForACompletedWish =>
      t('youCanNotVoteForACompletedWish');
  String get youCanNotVoteForYourOwnWish => t('youCanNotVoteForYourOwnWish');
  String get poweredBy => t('poweredBy');
  String get successfullyCreated => t('successfullyCreated');
  String get done => t('done');
  String get detail => t('detail');
  String get featureWishlist => t('featureWishlist');
  String get confirm => t('confirm');
  String get cancel => t('cancel');
  String get ok => t('ok');
  String get titleOfWish => t('titleOfWish');
  String get titleDescriptionCannotBeEmpty =>
      t('titleDescriptionCannotBeEmpty');
  String get votes => t('votes');
  String get close => t('close');
  String get createWish => t('createWish');
  String get optional => t('optional');
  String get required => t('required');
  String get emailRequiredText => t('emailRequiredText');
  String get emailFormatWrongText => t('emailFormatWrongText');
  String get comments => t('comments');
  String get writeAComment => t('writeAComment');
  String get submitComment => t('submitComment');
  String get admin => t('admin');
  String get user => t('user');
  String get noFeatureRequests => t('noFeatureRequests');
  String get emailOptional => t('emailOptional');
  String get emailRequired => t('emailRequired');
  String get discardEnteredInformation => t('discardEnteredInformation');
  String get addButtonInNavigationBar => t('addButtonInNavigationBar');
  String get refresh => t('refresh');
  String get refreshing => t('refreshing');
  String get somethingWentWrong => t('somethingWentWrong');
  String get all => t('all');
  String get notSupported => t('notSupported');
  String get filter => t('filter');
  String get activateToSwitchFilter => t('activateToSwitchFilter');
  String get seeTranslation => t('seeTranslation');
  String get seeOriginal => t('seeOriginal');
  String get chat => t('chat');
  String get writeAMessage => t('writeAMessage');
  String get send => t('send');
  String get chatEmptyState => t('chatEmptyState');
  String get failedToSendTapToRetry => t('failedToSendTapToRetry');

  // -----------------------------------------------------------------------
  // Flutter-only strings
  // -----------------------------------------------------------------------

  String get removeVoteButton => t('removeVoteButton');
  String get noComments => t('noComments');
  String get emailPlaceholder => t('emailPlaceholder');
  String get descriptionPlaceholder => t('descriptionPlaceholder');

  // -----------------------------------------------------------------------
  // Composed labels
  //
  // Not standalone keys: iOS composes these from two existing ones, and so
  // does this, so a host overriding `open` or `pending` still gets the
  // composed text in their own words.
  // -----------------------------------------------------------------------

  /// The label for a raw [WishState], i.e. iOS's `WishState.description`.
  ///
  /// `rejected` renders as "not supported". The bundle has no `rejected` key
  /// because rejected feedback is excluded from every bucket and therefore
  /// never labelled in the normal flow; a host that opted `rejected` into
  /// `visibleStates` gets the closest honest string rather than a key name.
  String stateLabel(WishState state) => switch (state) {
        WishState.pending => pending,
        WishState.approved => approved,
        WishState.implemented => implemented,
        WishState.inReview => inReview,
        WishState.planned => planned,
        WishState.inProgress => inProgress,
        WishState.completed => completed,
        WishState.rejected => notSupported,
      };

  /// The label for a board segment, i.e. iOS's `LocalWishState.description`.
  String filterLabel(WishFilter filter) => switch (filter) {
        WishFilter.all => all,
        WishFilter.open => open,
        WishFilter.closed => closed,
        final byState => byState.state == null
            ? all
            : stateLabel(byState.state!),
      };

  /// The segment label with its live count, as iOS renders it: `Open (12)`.
  String filterLabelWithCount(WishFilter filter, int count) =>
      '${filterLabel(filter)} ($count)';

  /// The locale's BCP-47 tag, e.g. `de`, `pt-BR`, `zh-Hans`.
  String get languageTag => locale.toLanguageTag();

  /// The `intl` locale name these strings resolved to, e.g. `de_DE`.
  ///
  /// Passed to [WishKitDateFormat] rather than reusing [languageTag], because
  /// `intl` keys its locale data by underscore form and falls back to `en_US`
  /// for a tag it does not recognise — a silent English date inside an
  /// otherwise German thread.
  String get localeName =>
      locale.toString().replaceAll('-', '_');

  /// The locale's script subtag, e.g. `Hans`, `Hant`, or `null`.
  ///
  /// Feeds `FeedbackLanguage.matches`, which is script-aware: a `zh-Hant` app
  /// does not consider `zh-Hans` feedback to be in its own language, and
  /// therefore does offer a translation for it. `null` for a scriptless locale
  /// such as `zh`, which matches both, matching iOS.
  String? get scriptCode {
    final script = locale.scriptCode;
    return script == null || script.isEmpty ? null : script;
  }
}

/// Makes the strings reachable from any widget: `context.l10n.voteButton`.
///
/// Reads [WishKit.config]'s localization, so a host that swaps it out at
/// runtime is picked up on the next build.
extension WishKitStringsContext on BuildContext {
  WishKitStrings get l10n => WishKitStrings.of(
        this,
        localization: WishKit.config.localization,
      );
}

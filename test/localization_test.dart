import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wishkit/l10n/generated/wishkit_localizations.dart';
import 'package:wishkit/wishkit.dart';

/// Every bundled locale, so a key that went missing from one ARB file is caught
/// rather than silently falling back to English for that language only.
const List<Locale> _allLocales = <Locale>[
  Locale('en'),
  Locale('da'),
  Locale('de'),
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
  Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
];

/// A localization with every one of its 64 fields filled in.
///
/// Used to prove the override bag covers every resolvable key. If a field is
/// added to [WishKitLocalization] and forgotten in [_allFieldsSet] *or* in the
/// resolver, this fails — which is the drift that the iOS test guards against
/// for `ConfigurationLocalization`.
WishKitLocalization _allFieldsSet() {
  const prefix = 'ov:';
  return const WishKitLocalization(
    requested: '${prefix}requested',
    pending: '${prefix}pending',
    approved: '${prefix}approved',
    implemented: '${prefix}implemented',
    inReview: '${prefix}inReview',
    planned: '${prefix}planned',
    inProgress: '${prefix}inProgress',
    completed: '${prefix}completed',
    open: '${prefix}open',
    closed: '${prefix}closed',
    wishlist: '${prefix}wishlist',
    save: '${prefix}save',
    title: '${prefix}title',
    description: '${prefix}description',
    upvote: '${prefix}upvote',
    info: '${prefix}info',
    youCanOnlyVoteOnce: '${prefix}youCanOnlyVoteOnce',
    youCanNotVoteForACompletedWish: '${prefix}youCanNotVoteForACompletedWish',
    youCanNotVoteForYourOwnWish: '${prefix}youCanNotVoteForYourOwnWish',
    poweredBy: '${prefix}poweredBy',
    successfullyCreated: '${prefix}successfullyCreated',
    done: '${prefix}done',
    detail: '${prefix}detail',
    featureWishlist: '${prefix}featureWishlist',
    confirm: '${prefix}confirm',
    cancel: '${prefix}cancel',
    ok: '${prefix}ok',
    titleOfWish: '${prefix}titleOfWish',
    titleDescriptionCannotBeEmpty: '${prefix}titleDescriptionCannotBeEmpty',
    votes: '${prefix}votes',
    close: '${prefix}close',
    createWish: '${prefix}createWish',
    optional: '${prefix}optional',
    required: '${prefix}required',
    emailRequiredText: '${prefix}emailRequiredText',
    emailFormatWrongText: '${prefix}emailFormatWrongText',
    comments: '${prefix}comments',
    writeAComment: '${prefix}writeAComment',
    submitComment: '${prefix}submitComment',
    admin: '${prefix}admin',
    user: '${prefix}user',
    noFeatureRequests: '${prefix}noFeatureRequests',
    emailOptional: '${prefix}emailOptional',
    emailRequired: '${prefix}emailRequired',
    discardEnteredInformation: '${prefix}discardEnteredInformation',
    addButtonInNavigationBar: '${prefix}addButtonInNavigationBar',
    refresh: '${prefix}refresh',
    refreshing: '${prefix}refreshing',
    somethingWentWrong: '${prefix}somethingWentWrong',
    all: '${prefix}all',
    notSupported: '${prefix}notSupported',
    filter: '${prefix}filter',
    activateToSwitchFilter: '${prefix}activateToSwitchFilter',
    seeTranslation: '${prefix}seeTranslation',
    seeOriginal: '${prefix}seeOriginal',
    chat: '${prefix}chat',
    writeAMessage: '${prefix}writeAMessage',
    send: '${prefix}send',
    chatEmptyState: '${prefix}chatEmptyState',
    failedToSendTapToRetry: '${prefix}failedToSendTapToRetry',
    removeVoteButton: '${prefix}removeVoteButton',
    noComments: '${prefix}noComments',
    emailPlaceholder: '${prefix}emailPlaceholder',
    descriptionPlaceholder: '${prefix}descriptionPlaceholder',
  );
}

void main() {
  final originalConfig = WishKit.config;

  tearDown(() => WishKit.config = originalConfig);

  group('key parity', () {
    test('the override bag covers every resolvable key', () {
      expect(
        _allFieldsSet().overrides.keys.toSet(),
        wishKitStringKeys,
        reason: 'WishKitLocalization gained or lost a field relative to the '
            'string resolver. A new field that nothing can read is dead copy; '
            'a new key with no field is unreachable for a host to override.',
      );
    });

    test('there are exactly 64 keys: 60 from iOS plus 4 Flutter-only', () {
      // Hard-coded so a well-meaning addition has to be a deliberate edit of
      // this line, where the reviewer can see there is no translation for it.
      expect(wishKitStringKeys.length, 64);
    });

    test('an unset bag is empty', () {
      expect(const WishKitLocalization().overrides, isEmpty);
    });

    test('a key that resolves to nothing returns the key, not an empty string',
        () {
      // Unreachable in practice — the set is closed and covered above — but the
      // failure mode it guards is a blank gap in the UI, which is worse to
      // debug than a visible key name.
      final strings = WishKitStrings.forLocale(
        const Locale('en'),
        localization: const WishKitLocalization(),
      );
      expect(strings.t('definitelyNotAKey'), 'definitelyNotAKey');
    });
  });

  group('bundled translations', () {
    test('every locale resolves every key to a translated value', () {
      final keys = wishKitStringKeys.toList()..sort();

      // `optional` and `required` are fragments the create form appends to the
      // email label, and their English text *is* the word. They are the only
      // two keys whose English value equals the key, so they are exempt from
      // the fall-back check below.
      const selfValued = <String>{'optional', 'required'};

      for (final locale in _allLocales) {
        final strings = WishKitStrings.forLocale(locale);
        for (final key in keys) {
          final value = strings.t(key);
          if (!selfValued.contains(key)) {
            expect(
              value,
              isNot(key),
              reason: 'WishKit fell back to the key for "$key" in $locale, '
                  'which means the ARB entry is missing or empty.',
            );
          }
          expect(
            value.trim(),
            isNotEmpty,
            reason: 'The "$key" translation in $locale is blank.',
          );
        }
      }
    });

    test('every ARB file carries exactly the English key set', () {
      // `supportedLocales` and the loop above only prove the files *loaded*:
      // `gen-l10n` fills a key missing from a translation with the English
      // text, so a gap shows up as a silent English string in a Japanese board
      // rather than as a visible key. Reading the ARB files themselves is the
      // only way to see the gap.
      const arbDirectory = 'lib/l10n';
      final files = Directory(arbDirectory)
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      expect(files, isNotEmpty, reason: 'no ARB files found in $arbDirectory');

      // `files` is sorted, so the English template is read explicitly rather
      // than assumed to be first.
      final englishFile = files.firstWhere(
        (file) => file.path.endsWith('wishkit_en.arb'),
      );
      final englishKeys = (jsonDecode(englishFile.readAsStringSync())
              as Map<String, dynamic>)
          .keys
          .where((key) => !key.startsWith('@'))
          .toSet();
      expect(englishKeys, isNotEmpty);

      for (final file in files) {
        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final keys = json.keys.where((key) => !key.startsWith('@')).toSet();

        expect(
          keys.difference(englishKeys),
          isEmpty,
          reason: '${file.path} has keys English does not: '
              '${keys.difference(englishKeys)}',
        );
        expect(
          englishKeys.difference(keys),
          isEmpty,
          reason: '${file.path} is missing keys: '
              '${englishKeys.difference(keys)}',
        );

        for (final key in englishKeys) {
          expect(
            (json[key] as String).trim(),
            isNotEmpty,
            reason: '${file.path} has a blank value for "$key"',
          );
        }
      }
    });

    test('every locale is translated, not a copy of the English file', () {
      // Catches an ARB that was regenerated but never translated: the key sets
      // would all match, and the "not the key" loop above would pass, because
      // an untranslated copy is still a real string.
      final english = WishKitStrings.forLocale(const Locale('en'));

      for (final locale in _allLocales) {
        if (locale.languageCode == 'en') continue;
        final strings = WishKitStrings.forLocale(locale);
        final differing = wishKitStringKeys
            .where((key) => strings.t(key) != english.t(key))
            .length;
        expect(
          differing,
          greaterThan(0),
          reason: '$locale resolves every key to the English text, so its '
              'ARB is either English or missing.',
        );
      }
    });

    test('English values are real words, not key names', () {
      // The iOS test asserts this for six keys; the loop above now covers all
      // of them for all 19 bundles, so this only pins the ones a board shows
      // on first paint.
      final strings = WishKitStrings.forLocale(const Locale('en'));
      expect(strings.open, isNot('open'));
      expect(strings.open, isNotEmpty);
      expect(strings.pending, isNot('pending'));
      expect(strings.closed, isNot('closed'));
      expect(strings.somethingWentWrong, isNot('somethingWentWrong'));
      expect(strings.activateToSwitchFilter, isNot('activateToSwitchFilter'));
    });

    test('German differs from English, so the two bundles are not the same file',
        () {
      final en = WishKitStrings.forLocale(const Locale('en'));
      final de = WishKitStrings.forLocale(const Locale('de'));
      expect(de.open, isNot(en.open));
      expect(de.comments, isNot(en.comments));
    });

    test('a scriptless zh locale resolves to the plain zh bundle', () {
      final plain = WishKitStrings.forLocale(const Locale('zh'));
      expect(plain.scriptCode, isNull);
      expect(plain.t('wishlist'), isNotEmpty);
    });

    test('a scripted zh locale exposes its script to language detection', () {
      final hans = WishKitStrings.forLocale(
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      );
      final hant = WishKitStrings.forLocale(
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      );
      expect(hans.scriptCode, 'Hans');
      expect(hant.scriptCode, 'Hant');
    });
  });

  group('locale metadata', () {
    test('languageTag is BCP-47 with a dash', () {
      expect(
        WishKitStrings.forLocale(const Locale('pt', 'BR')).languageTag,
        'pt-BR',
      );
      expect(WishKitStrings.forLocale(const Locale('de')).languageTag, 'de');
    });

    test('localeName uses underscores, which is what intl keys on', () {
      expect(
        WishKitStrings.forLocale(const Locale('pt', 'BR')).localeName,
        'pt_BR',
      );
      expect(WishKitStrings.forLocale(const Locale('de')).localeName, 'de');
    });
  });

  group('composed labels', () {
    test('a filter label composes from the bucket key, not a separate string',
        () {
      final strings = WishKitStrings.forLocale(
        const Locale('en'),
        localization: const WishKitLocalization(open: 'In flight'),
      );
      expect(strings.filterLabel(WishFilter.open), 'In flight');
      expect(strings.filterLabelWithCount(WishFilter.open, 12), 'In flight (12)');
    });

    test('a raw-state filter label reuses the state label', () {
      final strings = WishKitStrings.forLocale(
        const Locale('en'),
        localization: const WishKitLocalization(planned: 'On the roadmap'),
      );
      expect(
        strings.filterLabel(WishFilter.byState(WishState.planned)),
        'On the roadmap',
      );
    });

    test('rejected has no key of its own and falls back to notSupported', () {
      // iOS's `WishState+Description.swift` maps rejected to "not supported".
      // The bundle has no `rejected` key because rejected feedback is excluded
      // from every bucket, so this is the label a host that opted `rejected`
      // into `visibleStates` gets.
      final strings = WishKitStrings.forLocale(const Locale('en'));
      expect(strings.stateLabel(WishState.rejected), strings.notSupported);
      expect(strings.stateLabel(WishState.rejected), isNot('rejected'));
    });

    test('all eight states have a label and none of them is a key name', () {
      final strings = WishKitStrings.forLocale(const Locale('en'));
      for (final state in WishState.values) {
        expect(strings.stateLabel(state), isNot(state.name));
        expect(strings.stateLabel(state).trim(), isNotEmpty);
      }
    });
  });

  group('resolution order', () {
    Future<WishKitStrings> pump(
      WidgetTester tester, {
      required Locale locale,
      required bool withDelegate,
      WishKitLocalization localization = const WishKitLocalization(),
    }) async {
      late WishKitStrings resolved;
      final probe = Builder(
        builder: (context) {
          resolved = WishKitStrings.of(context, localization: localization);
          return const SizedBox.shrink();
        },
      );

      if (!withDelegate) {
        // No `Localizations` ancestor at all, which is what an app that never
        // registered the delegate looks like — a bare `Directionality` is the
        // closest a widget test gets to that.
        await tester.pumpWidget(
          Directionality(textDirection: TextDirection.ltr, child: probe),
        );
        return resolved;
      }

      await tester.pumpWidget(
        Localizations(
          locale: locale,
          delegates: const <LocalizationsDelegate<Object>>[
            // `Localizations` insists on a `WidgetsLocalizations` delegate;
            // `WishKitLocalizations` is a plain delegate and does not provide
            // one, so a host needs `DefaultWidgetsLocalizations` alongside it
            // unless it uses `MaterialApp`.
            DefaultWidgetsLocalizations.delegate,
            WishKitLocalizations.delegate,
          ],
          child: probe,
        ),
      );
      return resolved;
    }

    testWidgets('a host override beats the bundle', (tester) async {
      final strings = await pump(
        tester,
        locale: const Locale('de'),
        withDelegate: true,
        localization: const WishKitLocalization(open: 'Offen (custom)'),
      );
      expect(strings.open, 'Offen (custom)');
      // An untouched key still comes from the German bundle.
      expect(strings.open, isNot(WishKitStrings.forLocale(const Locale('de')).open));
      expect(strings.closed, WishKitStrings.forLocale(const Locale('de')).closed);
    });

    testWidgets('the bundle is used when there is no override', (tester) async {
      final strings = await pump(
        tester,
        locale: const Locale('de'),
        withDelegate: true,
      );
      expect(strings.open, WishKitStrings.forLocale(const Locale('de')).open);
    });

    testWidgets('a missing delegate degrades to English instead of throwing',
        (tester) async {
      // The default state of an existing app that upgrades the SDK without
      // touching its `localizationsDelegates`. A board that cannot build is a
      // crash on the host's feature screen, which is a much worse outcome than
      // English.
      final strings = await pump(
        tester,
        locale: const Locale('de'),
        withDelegate: false,
      );
      expect(strings.open, isNotEmpty);
      expect(strings.open, isNot('open'));
    });

    testWidgets('a pinned locale ignores the app locale', (tester) async {
      final strings = await pump(
        tester,
        locale: const Locale('ja'),
        withDelegate: true,
        localization: WishKitLocalization.de(),
      );
      expect(strings.locale.languageCode, 'de');
      expect(strings.open, WishKitStrings.forLocale(const Locale('de')).open);
      expect(strings.open, isNot(WishKitStrings.forLocale(const Locale('ja')).open));
    });

    test('the .en() and .de() factories still pin, as they always have', () {
      expect(WishKitLocalization.en().locale, const Locale('en'));
      expect(WishKitLocalization.de().locale, const Locale('de'));
    });

    test('copyWith keeps the other fields and cannot clear one', () {
      final base = const WishKitLocalization(open: 'A', closed: 'B');
      final copy = base.copyWith(open: 'C');

      expect(copy.open, 'C');
      expect(copy.closed, 'B');
      // Documented: a null argument means "leave as is", so an override can be
      // replaced but only by assigning a whole new bag.
      expect(base.copyWith().open, 'A');
    });
  });

  group('Flutter-only strings', () {
    test('they resolve to English until a host overrides them', () {
      final strings = WishKitStrings.forLocale(
        const Locale('de'),
        localization: const WishKitLocalization(),
      );
      // Not machine-translated on purpose — see the note in
      // `WishKitLocalization`. A German board shows these in English rather
      // than in an unreviewed translation.
      expect(strings.noComments, 'No comments yet');
      expect(strings.removeVoteButton, 'Remove Vote');
    });

    test('a host override reaches them like any other key', () {
      final strings = WishKitStrings.forLocale(
        const Locale('de'),
        localization: const WishKitLocalization(noComments: 'Noch keine Kommentare'),
      );
      expect(strings.noComments, 'Noch keine Kommentare');
    });
  });
}

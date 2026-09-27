import 'package:flutter_test/flutter_test.dart';
import 'package:wishkit/src/utilities/detected_language.dart';
import 'package:wishkit/src/utilities/feedback_language.dart';

void main() {
  group('minimum length', () {
    test('text below the threshold is never detected', () {
      // "Dark Mode" is 9 characters.
      expect(FeedbackLanguage.dominantLanguage('Dark Mode'), isNull);
    });

    test('text at the threshold is considered', () {
      expect(
        FeedbackLanguage.dominantLanguage('Dark mode please!'),
        isNotNull,
      );
    });
  });

  group('Han marker sets', () {
    test('simplified and traditional markers are disjoint', () {
      final overlap = FeedbackLanguage.simplifiedMarkers
          .intersection(FeedbackLanguage.traditionalMarkers);
      expect(
        overlap,
        isEmpty,
        reason: 'a character in both sets would break zh-Hans/zh-Hant '
            'discrimination: ${overlap.map((r) => String.fromCharCode(r))}',
      );
    });

    test('every marker is a CJK unified ideograph', () {
      bool inRange(int rune) => rune >= 0x4E00 && rune <= 0x9FFF;
      expect(FeedbackLanguage.simplifiedMarkers.where(inRange).length,
          FeedbackLanguage.simplifiedMarkers.length);
      expect(FeedbackLanguage.traditionalMarkers.where(inRange).length,
          FeedbackLanguage.traditionalMarkers.length);
    });

    test('the sets are large enough to be useful', () {
      // A truncated list would silently degrade every Han detection to plain
      // `zh`, so pin a floor rather than letting it drift to nothing.
      expect(FeedbackLanguage.simplifiedMarkers.length, greaterThan(900));
      expect(FeedbackLanguage.traditionalMarkers.length, greaterThan(900));
    });
  });

  group('non-Latin scripts', () {
    test('identifies Japanese by kana', () {
      final detected = FeedbackLanguage.dominantLanguage('ダークモードを追加してほしい');
      expect(detected?.languageCode, 'ja');
    });

    test('identifies Korean by hangul', () {
      final detected = FeedbackLanguage.dominantLanguage('다크모드를 추가해주세요');
      expect(detected?.languageCode, 'ko');
    });

    test('identifies Russian by cyrillic', () {
      final detected = FeedbackLanguage.dominantLanguage('Добавьте тёмную тему');
      expect(detected?.languageCode, 'ru');
    });

    test('identifies Arabic', () {
      final detected = FeedbackLanguage.dominantLanguage('أضف الوضع الليلي من فضلك');
      expect(detected?.languageCode, 'ar');
    });

    test('identifies Greek', () {
      final detected = FeedbackLanguage.dominantLanguage('Προσθέστε σκοτεινό θέμα');
      expect(detected?.languageCode, 'el');
    });

    test('identifies Hebrew', () {
      final detected = FeedbackLanguage.dominantLanguage('הוסיפו מצב לילי בבקשה');
      expect(detected?.languageCode, 'he');
    });

    test('identifies Hindi', () {
      final detected = FeedbackLanguage.dominantLanguage('कृपया डार्क मोड जोड़ें');
      expect(detected?.languageCode, 'hi');
    });

    test('identifies Thai', () {
      final detected = FeedbackLanguage.dominantLanguage('กรุณาเพิ่มโหมดมืด');
      expect(detected?.languageCode, 'th');
    });
  });

  group('Han script discrimination', () {
    test('simplified text is reported as zh-Hans', () {
      final detected =
          FeedbackLanguage.dominantLanguage('请添加一个深色模式的应用功能');
      expect(detected?.languageCode, 'zh');
      expect(detected?.scriptCode, 'Hans');
    });

    test('traditional text is reported as zh-Hant', () {
      final detected =
          FeedbackLanguage.dominantLanguage('請添加一個深色模式的應用功能');
      expect(detected?.languageCode, 'zh');
      expect(detected?.scriptCode, 'Hant');
    });

    test('Han text without marker characters still yields zh', () {
      final detected = FeedbackLanguage.dominantLanguage('一二三四五六七八九十一');
      expect(detected?.languageCode, 'zh');
      expect(detected?.scriptCode, isNull);
    });
  });

  group('Latin function-word scoring', () {
    const cases = <String, String>{
      'en': 'Please add a dark mode toggle to the app',
      'de': 'Bitte fügen Sie einen Dunkelmodus hinzu',
      'es': 'Por favor añade un modo oscuro a la app',
      'fr': 'Veuillez ajouter un mode sombre à cette application',
      'it': 'Per favore aggiungi una modalità scura alla app',
      'nl': 'Ik wil graag een donkere modus toevoegen aan de app',
      'pt': 'Por favor adicione um modo escuro ao aplicativo',
      'sv': 'Jag vill gärna ha ett mörkt läge i appen tack',
      'da': 'Vil du venligst tilføje en mørk tilstand tak',
      'nb': 'Vennligst legg til en mørk modus i appen takk',
      'fi': 'Haluaisin lisätä tumman tilan sovellukseen kiitos',
      'pl': 'Proszę dodać tryb ciemny do aplikacji',
      'tr': 'Lütfen uygulamaya karanlık mod ekleyin teşekkür',
      'id': 'Tolong tambahkan mode gelap ke aplikasi terima kasih',
      'vi': 'Xin hãy thêm chế độ tối vào ứng dụng cảm ơn',
    };

    cases.forEach((expected, text) {
      test('detects $expected', () {
        final detected = FeedbackLanguage.dominantLanguage(text);
        expect(detected?.languageCode, expected);
      });
    });

    test('returns null for text with no known function words', () {
      // Latin script, long enough, but no language table matches.
      expect(
        FeedbackLanguage.dominantLanguage('Zzyzx Qwghlm Brrrr Xyzzy Plugh'),
        isNull,
      );
    });

    test('returns null when two languages score identically', () {
      // Danish and Norwegian are close enough that a short sample ties. Guessing
      // wrong here would hide the translate button from a user who needs it.
      expect(
        FeedbackLanguage.dominantLanguage('Det er en mørk app med meget'),
        isNull,
      );
    });

    test('digits and punctuation do not dilute the score', () {
      final detected =
          FeedbackLanguage.dominantLanguage('!!! the app is not the same ??? 1 2 3');
      expect(detected?.languageCode, 'en');
    });
  });

  group('differsFromAppLanguage', () {
    const german = 'Bitte fügen Sie einen Dunkelmodus hinzu';
    const english = 'Please add a dark mode toggle to the app';

    test('false for text in the app language', () {
      expect(
        FeedbackLanguage.differsFromAppLanguage(german, appLanguage: 'de'),
        isFalse,
      );
    });

    test('true for text in another language', () {
      expect(
        FeedbackLanguage.differsFromAppLanguage(english, appLanguage: 'de'),
        isTrue,
      );
    });

    test('false when detection is not confident', () {
      expect(
        FeedbackLanguage.differsFromAppLanguage(
          'Dark Mode',
          appLanguage: 'de',
        ),
        isFalse,
      );
    });

    test('a zh-Hant app does not match simplified feedback', () {
      // Mirrors iOS's `FeedbackLanguage.matches`: a script only breaks the
      // match when the app language carries one too.
      expect(
        FeedbackLanguage.differsFromAppLanguage(
          '请添加一个深色模式的应用功能',
          appLanguage: 'zh',
          appScript: 'Hant',
        ),
        isTrue,
      );
      expect(
        FeedbackLanguage.differsFromAppLanguage(
          '請添加一個深色模式的應用功能',
          appLanguage: 'zh',
          appScript: 'Hant',
        ),
        isFalse,
      );
    });

    test('a scriptless zh app matches feedback in either script', () {
      for (final text in <String>[
        '请添加一个深色模式的应用功能',
        '請添加一個深色模式的應用功能',
      ]) {
        expect(
          FeedbackLanguage.differsFromAppLanguage(text, appLanguage: 'zh'),
          isFalse,
        );
      }
    });

    test('a German app is flagged for Japanese feedback', () {
      expect(
        FeedbackLanguage.differsFromAppLanguage(
          'ダークモードを追加してほしい',
          appLanguage: 'de',
        ),
        isTrue,
      );
    });
  });

  group('matches', () {
    test('compares language code only when no script is given', () {
      const detected = DetectedLanguage(languageCode: 'zh', scriptCode: 'Hant');
      expect(FeedbackLanguage.matches(detected, 'zh'), isTrue);
    });

    test('compares script when both sides have one', () {
      const hans = DetectedLanguage(languageCode: 'zh', scriptCode: 'Hans');
      const hant = DetectedLanguage(languageCode: 'zh', scriptCode: 'Hant');
      expect(FeedbackLanguage.matches(hans, 'zh', 'Hant'), isFalse);
      expect(FeedbackLanguage.matches(hant, 'zh', 'Hant'), isTrue);
    });
  });
}

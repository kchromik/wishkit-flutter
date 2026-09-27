// One-off migration helper: converts the iOS `Localizable.strings` bundles into
// Flutter ARB files so the 17 languages stay byte-identical across SDKs.
//
//   dart tool/strings_to_arb.dart <ios-resources-dir> <arb-out-dir>
//
// Safe to re-run; it overwrites the generated ARB files.

import 'dart:convert';
import 'dart:io';

/// Matches `"key" = "value";` lines, ignoring `/* ... */` comment lines.
final _line = RegExp(r'^\s*"([^"]+)"\s*=\s*"(.*)"\s*;\s*$');

/// Catches `{count}`-style placeholders. None of the current keys use one (iOS
/// does its numeric formatting in code), but if a future key does we need real
/// ICU `placeholders` metadata rather than a silent passthrough.
final _placeholder = RegExp(r'\{(\w+)\}');

/// iOS bundle name -> ARB locale. The bundled script variants keep their script
/// subtag so `gen-l10n` treats Simplified/Traditional as distinct translations.
const _localeMap = <String, String>{
  'en': 'en',
  'de': 'de',
  'es': 'es',
  'fr': 'fr',
  'it': 'it',
  'nl': 'nl',
  'da': 'da',
  'nb': 'nb',
  'fi': 'fi',
  'pl': 'pl',
  'pt-BR': 'pt_BR',
  'sv': 'sv',
  'tr': 'tr',
  'ja': 'ja',
  'ko': 'ko',
  'zh-Hans': 'zh_Hans',
  'zh-Hant': 'zh_Hant',
};

/// `gen-l10n` demands a script-less base locale whenever a script/country
/// subtag is present. iOS gets these implicitly from its own locale matching;
/// for Flutter we emit them from the closest regional bundle.
const _baseFallbacks = <String, String>{
  'pt': 'pt-BR',
  'zh': 'zh-Hans',
};

/// The informal-address notes iOS keeps in each bundle as a leading comment.
const _notes = <String, String>{
  'de': 'Informal address (Du) by design.',
  'es': 'Informal address (tú) by design.',
  'fr': 'Informal address (tu) by design.',
  'it': 'Informal address (tu) by design.',
  'nl': 'Informal address (je) by design.',
  'da': 'Informal address (du) by design.',
  'nb': 'Informal address (du) by design.',
  'fi': 'Informal address (sinä) by design.',
  'pl': 'Informal address (ty) by design.',
  'pt_BR': 'Informal address (você) by design.',
  'sv': 'Informal address (du) by design.',
  'tr': 'Informal address (sen) by design.',
  'ja': 'Standard polite forms (です/ます) by design.',
  'ko': 'Polite informal style (해요체) by design.',
};

String _unescape(String value) =>
    value.replaceAll(r'\"', '"').replaceAll(r'\\', r'\').replaceAll(r'\n', '\n');

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('usage: dart tool/strings_to_arb.dart <resources> <out>');
    exitCode = 64;
    return;
  }

  final resources = Directory(args[0]);
  final out = Directory(args[1])..createSync(recursive: true);

  Map<String, String> parse(String bundle) {
    final file = File('${resources.path}/$bundle.lproj/Localizable.strings');
    if (!file.existsSync()) throw StateError('missing ${file.path}');
    final result = <String, String>{};
    for (final raw in file.readAsLinesSync()) {
      final match = _line.firstMatch(raw);
      if (match == null) continue;
      result[match.group(1)!] = _unescape(match.group(2)!);
    }
    return result;
  }

  final english = parse('en');
  for (final entry in english.entries) {
    final found = _placeholder.firstMatch(entry.value);
    if (found != null) {
      throw StateError(
        'key "${entry.key}" uses placeholder ${found.group(0)}; add ICU '
        'metadata to this script before converting.',
      );
    }
  }

  var written = 0;
  for (final bundle in _localeMap.keys) {
    final locale = _localeMap[bundle]!;
    final strings = bundle == 'en' ? english : parse(bundle);

    final missing = english.keys.where((k) => !strings.containsKey(k)).toList();
    final extra = strings.keys.where((k) => !english.containsKey(k)).toList();
    if (missing.isNotEmpty || extra.isNotEmpty) {
      throw StateError('$bundle key mismatch: missing=$missing extra=$extra');
    }

    // Emit in English key order so diffs between locales stay reviewable.
    final arb = <String, dynamic>{'@@locale': locale};
    final note = _notes[locale];
    for (final key in english.keys) {
      if (note != null) arb['@$key'] = <String, dynamic>{'description': note};
      arb[key] = strings[key];
    }

    File('${out.path}/wishkit_$locale.arb').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(arb)}\n',
    );
    written++;
  }

  for (final MapEntry(key: base, value: source) in _baseFallbacks.entries) {
    final strings = parse(source);
    final arb = <String, dynamic>{
      '@@locale': base,
      '@@fallback': source,
    };
    final note = _notes[_localeMap[source]!];
    for (final key in english.keys) {
      if (note != null) arb['@$key'] = <String, dynamic>{'description': note};
      arb[key] = strings[key];
    }
    File('${out.path}/wishkit_$base.arb').writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(arb)}\n',
    );
    written++;
  }

  stdout.writeln('wrote $written ARB files, ${english.length} keys each');
}

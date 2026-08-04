import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards every Dart source under `lib/` against mojibake — UTF-8 bytes that
/// were once decoded as Latin-1 and re-encoded, so `·` (U+00B7) becomes `Â·`,
/// `ç` becomes `Ã§`, and so on.
///
/// Regression: `payables_receivables_ledger_widgets` shipped `' Â· '` as the
/// separator of the payables card subtitle, so every row read
/// "9/1 Â· Moradia > Luz Â· Scheduled". The corruption is invisible in a diff
/// review because the round-tripped text still looks like plausible source.
void main() {
  // Every mojibake sequence starts with whatever the original UTF-8 lead byte
  // decodes to under Latin-1:
  //   0xC2 -> Â   (` `, `·`, `°`, `»` …)
  //   0xC3 -> Ã   (accented Latin letters: ç é ã õ …)
  //   0xE2 -> â   (punctuation: — – “ ” ‘ ’ …, always as `â€`)
  // The first guard only looked for Â/Ã, which misses the em dash — by far
  // the most common non-ASCII character in this codebase's doc comments.
  final mojibakeLead = RegExp('[ÂÃ]|â€');

  // The only intentional standalone uses: the chat's Portuguese-diacritic
  // detector enumerates accented letters, so it legitimately contains `Â`
  // and `Ã` as isolated characters.
  const allowedFiles = {'lib/features/chat/presentation/bloc/chat_bloc.dart'};

  test('no source or translation under lib/ contains mojibake', () {
    final offenders = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File) continue;
      // Translations matter most: they are the strings the user reads, and a
      // corrupted one ships straight to the UI. They reach `lib/gen/` only
      // after `dart run slang`, so guarding the .dart output alone is late.
      final isSource = entity.path.endsWith('.dart');
      final isTranslation = entity.path.endsWith('.i18n.json');
      if (!isSource && !isTranslation) continue;
      final relativePath = entity.path.replaceAll(r'\', '/');
      if (allowedFiles.contains(relativePath)) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (mojibakeLead.hasMatch(lines[i])) {
          offenders.add('$relativePath:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'Mojibake found — these lines hold UTF-8 text that was decoded as '
          'Latin-1 and saved back. Retype the affected characters:\n'
          '${offenders.join('\n')}',
    );
  });
}

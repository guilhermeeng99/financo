import 'package:financo/gen/i18n/strings.g.dart';

/// Handler interface for a chat action type (account, category, transaction,
/// transfer, bill, budget). Each implementation owns:
///
/// - `preflight` — runs BEFORE the action card is shown. Returns a
///   user-friendly error string when the action is doomed (e.g. category
///   missing, account ambiguous); the chat then surfaces the rejection
///   instead of a confirm card. Return `null` to let the card through.
///
/// - `handle` — runs AFTER the user taps Confirm. Performs the actual
///   write through its injected use cases and returns the result text
///   that appears as the next assistant bubble.
///
/// Both receive a `locale` — the [AppLocale] of the **conversation**, not
/// necessarily the app UI locale. The chat is bilingual (Gemini mirrors
/// the user's typed language), so success/rejection bubbles must follow
/// the conversation language. Use `locale.translations.x.y` for strings
/// and `locale.intlTag` for date/currency formatting.
abstract class ChatActionHandler {
  Future<String?> preflight({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  });

  Future<String> handle({
    required String userId,
    required Map<String, dynamic> meta,
    required AppLocale locale,
  });
}

/// Intl-style locale tag (`pt_BR`, `en`) for use with `DateFormat`/`intl`.
/// Slang's [AppLocale] exposes `languageTag` ("pt-BR") but `intl` prefers
/// the underscore form, so do the swap once here.
extension AppLocaleIntl on AppLocale {
  String get intlTag {
    if (countryCode == null) return languageCode;
    return '${languageCode}_$countryCode';
  }
}

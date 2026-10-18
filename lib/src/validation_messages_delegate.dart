import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart' show Locale, LocalizationsDelegate;

import 'form_validators.dart';
import 'validation_messages.dart';

/// A [LocalizationsDelegate] that switches the validators' messages to the
/// app's current locale.
///
/// Add it to `MaterialApp.localizationsDelegates`. Whenever the locale
/// changes, it calls `FormValidators.configure` with the messages for the
/// new locale, so you don't need to call `configure` yourself:
///
/// ```dart
/// MaterialApp(
///   locale: locale,
///   supportedLocales: const [Locale('en'), Locale('ar')],
///   localizationsDelegates: const [
///     FormValidators.delegate,
///     ...GlobalMaterialLocalizations.delegates,
///   ],
/// );
/// ```
///
/// By default it uses the built-in messages from
/// [ValidationMessages.forLanguage], so any locale without built-in messages
/// gets English. Pass [messagesFor] to choose the messages yourself:
///
/// ```dart
/// ValidationMessages appMessages(Locale locale) =>
///     locale.languageCode == 'ar'
///         ? const AppArabicMessages()
///         : const AppEnglishMessages();
///
/// const ValidationMessagesDelegate(messagesFor: appMessages);
/// ```
///
/// Pass a top-level or static function, not a closure created in `build`,
/// so the messages are not reloaded on every rebuild.
class ValidationMessagesDelegate
    extends LocalizationsDelegate<ValidationMessages> {
  /// Creates a delegate. [messagesFor] returns the messages for a locale;
  /// when null, the built-in messages for the locale's language are used.
  const ValidationMessagesDelegate({this.messagesFor});

  /// Returns the messages to use for a locale, or null to use the built-in
  /// messages.
  final ValidationMessages Function(Locale locale)? messagesFor;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<ValidationMessages> load(Locale locale) {
    final messages =
        messagesFor?.call(locale) ??
        ValidationMessages.forLanguage(locale.languageCode);
    FormValidators.configure(messages: messages);
    return SynchronousFuture<ValidationMessages>(messages);
  }

  @override
  bool shouldReload(ValidationMessagesDelegate old) =>
      old.messagesFor != messagesFor;
}

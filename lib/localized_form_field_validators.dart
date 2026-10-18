/// `TextFormField` validators with built-in translations and messages that
/// can be overridden globally or per call.
///
/// - [FormValidators] builds the validators and holds the app-wide
///   configuration.
/// - [ValidationMessages] holds the error messages, in English by default.
///   [ValidationMessagesAr] holds the built-in Arabic messages. Extend either
///   to use your own.
/// - [ValidationMessagesDelegate] switches the messages to the app's locale.
/// - [ValidationRules] holds the patterns and the password policy.
/// - [ArabCountry] lists Arab countries with phone and national ID rules,
///   and [PhonePatterns] holds their mobile phone patterns.
///
/// ```dart
/// import 'package:localized_form_field_validators/localized_form_field_validators.dart';
///
/// void main() {
///   FormValidators.configure(languageCode: 'ar'); // Optional. Default: 'en'.
///   runApp(const MyApp());
/// }
///
/// TextFormField(
///   decoration: const InputDecoration(labelText: 'Email'),
///   validator: FormValidators.email(),
/// );
/// ```
library;

export 'src/arab_country.dart' show ArabCountry;
export 'src/form_validators.dart' show FormValidators;
export 'src/password_check.dart' show PasswordCheck;
export 'src/l10n/validation_messages_ar.dart' show ValidationMessagesAr;
export 'src/phone_patterns.dart' show PhonePatterns;
export 'src/validation_messages.dart' show ValidationMessages;
export 'src/validation_messages_delegate.dart' show ValidationMessagesDelegate;
export 'src/validation_rules.dart' show ValidationRules;

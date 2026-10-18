/// `TextFormField` validators with built-in translations and messages that
/// can be overridden globally or per call.
///
/// - [FormValidators] builds the validators and holds the app-wide
///   configuration.
/// - [ValidationMessages] holds the error messages, in English by default.
///   Pick a built-in translation by language code, or extend it to use your
///   own.
/// - [ValidationMessagesAr], [ValidationMessagesDe], [ValidationMessagesEs],
///   [ValidationMessagesFr] and [ValidationMessagesTr] are the built-in
///   translations.
/// - [ValidationRules] holds the patterns and the password policy.
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

export 'src/form_validators.dart' show FormValidators;
export 'src/l10n/validation_messages_ar.dart' show ValidationMessagesAr;
export 'src/l10n/validation_messages_de.dart' show ValidationMessagesDe;
export 'src/l10n/validation_messages_es.dart' show ValidationMessagesEs;
export 'src/l10n/validation_messages_fr.dart' show ValidationMessagesFr;
export 'src/l10n/validation_messages_tr.dart' show ValidationMessagesTr;
export 'src/validation_messages.dart' show ValidationMessages;
export 'src/validation_rules.dart' show ValidationRules;

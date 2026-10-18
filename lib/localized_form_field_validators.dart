/// `TextFormField` validators with English defaults that can be overridden
/// globally or per call.
///
/// - [FormValidators] builds the validators and holds the app-wide
///   configuration.
/// - [ValidationMessages] holds the error messages. Extend it to localize
///   them.
/// - [ValidationRules] holds the patterns and the password policy.
///
/// ```dart
/// import 'package:localized_form_field_validators/localized_form_field_validators.dart';
///
/// TextFormField(
///   decoration: const InputDecoration(labelText: 'Email'),
///   validator: FormValidators.email(),
/// );
/// ```
library;

export 'src/form_validators.dart' show FormValidators;
export 'src/validation_messages.dart' show ValidationMessages;
export 'src/validation_rules.dart' show ValidationRules;

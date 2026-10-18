/// The error messages returned by the validators in `FormValidators`.
///
/// Every message has an English default. To change messages, for example to
/// plug in localization, extend this class, override only the members you
/// need, and register the subclass once with `FormValidators.configure`:
///
/// ```dart
/// class AppValidationMessages extends ValidationMessages {
///   const AppValidationMessages();
///
///   @override
///   String get required => LocaleKeys.required.tr();
///
///   @override
///   String minLength(int min) =>
///       LocaleKeys.minLength.tr(namedArgs: {'min': '$min'});
/// }
///
/// void main() {
///   FormValidators.configure(messages: const AppValidationMessages());
///   runApp(const MyApp());
/// }
/// ```
///
/// Validators read these members each time they run and never cache the
/// result. A getter that looks up a translation therefore always returns the
/// text for the current locale.
class ValidationMessages {
  /// Creates the default English messages.
  ///
  /// Subclasses can call this from their own `const` constructor.
  const ValidationMessages();

  // General -------------------------------------------------------------------

  /// Returned when a required value is empty.
  ///
  /// Default: "This field is required."
  String get required => 'This field is required.';

  /// Returned when a value is shorter than [min] characters.
  ///
  /// Default: "Must be at least [min] characters." ("character" when [min]
  /// is 1).
  String minLength(int min) => 'Must be at least $min ${_characters(min)}.';

  /// Returned when a value is longer than [max] characters.
  ///
  /// Default: "Must be at most [max] characters." ("character" when [max] is
  /// 1).
  String maxLength(int max) => 'Must be at most $max ${_characters(max)}.';

  /// Returned when a value's length is not between [min] and [max]
  /// characters, inclusive.
  ///
  /// Default: "Must be between [min] and [max] characters."
  String lengthBetween(int min, int max) =>
      'Must be between $min and $max characters.';

  /// Returned when a value does not match a custom pattern.
  ///
  /// Default: "Invalid format."
  String get invalidFormat => 'Invalid format.';

  /// Returned when a value does not match another field, for example a
  /// password confirmation.
  ///
  /// Default: "Values do not match."
  String get valuesDoNotMatch => 'Values do not match.';

  // Email ---------------------------------------------------------------------

  /// Returned when a required email is empty.
  ///
  /// Default: "Email is required."
  String get emailRequired => 'Email is required.';

  /// Returned when a value is not a valid email address.
  ///
  /// Default: "Enter a valid email address."
  String get invalidEmail => 'Enter a valid email address.';

  // Phone ---------------------------------------------------------------------

  /// Returned when a required phone number is empty.
  ///
  /// Default: "Phone number is required."
  String get phoneRequired => 'Phone number is required.';

  /// Returned when a value is not a valid phone number.
  ///
  /// Default: "Enter a valid phone number."
  String get invalidPhone => 'Enter a valid phone number.';

  // Email or phone ------------------------------------------------------------

  /// Returned when a required email-or-phone value is empty.
  ///
  /// Default: "Email or phone number is required."
  String get emailOrPhoneRequired => 'Email or phone number is required.';

  /// Returned when a value looks like neither an email address nor a phone
  /// number.
  ///
  /// Default: "Enter a valid email address or phone number."
  String get invalidEmailOrPhone =>
      'Enter a valid email address or phone number.';

  // Password ------------------------------------------------------------------

  /// Returned when a required password is empty.
  ///
  /// Default: "Password is required."
  String get passwordRequired => 'Password is required.';

  /// Returned when a password is shorter than [min] characters.
  ///
  /// Default: "Password must be at least [min] characters." ("character"
  /// when [min] is 1).
  String passwordMinLength(int min) =>
      'Password must be at least $min ${_characters(min)}.';

  /// Returned when a password has no lowercase letter.
  ///
  /// Default: "Password must contain at least one lowercase letter."
  String get passwordLowercase =>
      'Password must contain at least one lowercase letter.';

  /// Returned when a password has no uppercase letter.
  ///
  /// Default: "Password must contain at least one uppercase letter."
  String get passwordUppercase =>
      'Password must contain at least one uppercase letter.';

  /// Returned when a password has no digit.
  ///
  /// Default: "Password must contain at least one number."
  String get passwordNumber => 'Password must contain at least one number.';

  /// Returned when a password has no special character.
  ///
  /// Default: "Password must contain at least one special character."
  String get passwordSpecialCharacter =>
      'Password must contain at least one special character.';

  // Numbers -------------------------------------------------------------------

  /// Returned when a value is not a valid number.
  ///
  /// Default: "Enter a valid number."
  String get invalidNumber => 'Enter a valid number.';

  /// Returned when a number is less than [min].
  ///
  /// Default: "Must be at least [min]."
  String numberMin(num min) => 'Must be at least $min.';

  /// Returned when a number is greater than [max].
  ///
  /// Default: "Must be at most [max]."
  String numberMax(num max) => 'Must be at most $max.';
}

String _characters(int count) => count == 1 ? 'character' : 'characters';

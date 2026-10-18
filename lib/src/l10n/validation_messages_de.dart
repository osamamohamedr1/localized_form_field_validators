import '../validation_messages.dart';

/// Built-in German (`de`) validation messages.
///
/// Select these messages with `FormValidators.configure(languageCode: 'de')`,
/// or extend this class to change individual messages and keep the rest in
/// German.
class ValidationMessagesDe extends ValidationMessages {
  /// Creates the German messages.
  const ValidationMessagesDe();

  @override
  String get required => 'Dieses Feld ist erforderlich.';

  @override
  String minLength(int min) => 'Muss mindestens $min Zeichen lang sein.';

  @override
  String maxLength(int max) => 'Darf höchstens $max Zeichen lang sein.';

  @override
  String lengthBetween(int min, int max) =>
      'Muss zwischen $min und $max Zeichen lang sein.';

  @override
  String get invalidFormat => 'Ungültiges Format.';

  @override
  String get valuesDoNotMatch => 'Die Werte stimmen nicht überein.';

  @override
  String get emailRequired => 'Die E-Mail-Adresse ist erforderlich.';

  @override
  String get invalidEmail => 'Bitte eine gültige E-Mail-Adresse eingeben.';

  @override
  String get phoneRequired => 'Die Telefonnummer ist erforderlich.';

  @override
  String get invalidPhone => 'Bitte eine gültige Telefonnummer eingeben.';

  @override
  String get emailOrPhoneRequired =>
      'E-Mail-Adresse oder Telefonnummer ist erforderlich.';

  @override
  String get invalidEmailOrPhone =>
      'Bitte eine gültige E-Mail-Adresse oder Telefonnummer eingeben.';

  @override
  String get passwordRequired => 'Das Passwort ist erforderlich.';

  @override
  String passwordMinLength(int min) =>
      'Das Passwort muss mindestens $min Zeichen lang sein.';

  @override
  String get passwordLowercase =>
      'Das Passwort muss mindestens einen Kleinbuchstaben enthalten.';

  @override
  String get passwordUppercase =>
      'Das Passwort muss mindestens einen Großbuchstaben enthalten.';

  @override
  String get passwordNumber =>
      'Das Passwort muss mindestens eine Ziffer enthalten.';

  @override
  String get passwordSpecialCharacter =>
      'Das Passwort muss mindestens ein Sonderzeichen enthalten.';

  @override
  String get invalidNumber => 'Bitte eine gültige Zahl eingeben.';

  @override
  String numberMin(num min) => 'Muss mindestens $min sein.';

  @override
  String numberMax(num max) => 'Darf höchstens $max sein.';
}

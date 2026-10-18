import '../validation_messages.dart';

/// Built-in French (`fr`) validation messages.
///
/// Select these messages with `FormValidators.configure(languageCode: 'fr')`,
/// or extend this class to change individual messages and keep the rest in
/// French.
class ValidationMessagesFr extends ValidationMessages {
  /// Creates the French messages.
  const ValidationMessagesFr();

  @override
  String get required => 'Ce champ est obligatoire.';

  @override
  String minLength(int min) =>
      'Doit contenir au moins $min ${_characters(min)}.';

  @override
  String maxLength(int max) =>
      'Doit contenir au plus $max ${_characters(max)}.';

  @override
  String lengthBetween(int min, int max) =>
      'Doit contenir entre $min et $max caractères.';

  @override
  String get invalidFormat => 'Format invalide.';

  @override
  String get valuesDoNotMatch => 'Les valeurs ne correspondent pas.';

  @override
  String get emailRequired => "L'adresse e-mail est obligatoire.";

  @override
  String get invalidEmail => 'Saisissez une adresse e-mail valide.';

  @override
  String get phoneRequired => 'Le numéro de téléphone est obligatoire.';

  @override
  String get invalidPhone => 'Saisissez un numéro de téléphone valide.';

  @override
  String get emailOrPhoneRequired =>
      "L'adresse e-mail ou le numéro de téléphone est obligatoire.";

  @override
  String get invalidEmailOrPhone =>
      'Saisissez une adresse e-mail ou un numéro de téléphone valide.';

  @override
  String get passwordRequired => 'Le mot de passe est obligatoire.';

  @override
  String passwordMinLength(int min) =>
      'Le mot de passe doit contenir au moins $min ${_characters(min)}.';

  @override
  String get passwordLowercase =>
      'Le mot de passe doit contenir au moins une lettre minuscule.';

  @override
  String get passwordUppercase =>
      'Le mot de passe doit contenir au moins une lettre majuscule.';

  @override
  String get passwordNumber =>
      'Le mot de passe doit contenir au moins un chiffre.';

  @override
  String get passwordSpecialCharacter =>
      'Le mot de passe doit contenir au moins un caractère spécial.';

  @override
  String get invalidNumber => 'Saisissez un nombre valide.';

  @override
  String numberMin(num min) => 'Doit être supérieur ou égal à $min.';

  @override
  String numberMax(num max) => 'Doit être inférieur ou égal à $max.';
}

/// French uses the singular for 0 and 1.
String _characters(int count) => count <= 1 ? 'caractère' : 'caractères';

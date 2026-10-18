import '../validation_messages.dart';

/// Built-in Spanish (`es`) validation messages.
///
/// Select these messages with `FormValidators.configure(languageCode: 'es')`,
/// or extend this class to change individual messages and keep the rest in
/// Spanish.
class ValidationMessagesEs extends ValidationMessages {
  /// Creates the Spanish messages.
  const ValidationMessagesEs();

  @override
  String get required => 'Este campo es obligatorio.';

  @override
  String minLength(int min) => 'Debe tener al menos $min ${_characters(min)}.';

  @override
  String maxLength(int max) =>
      'Debe tener como máximo $max ${_characters(max)}.';

  @override
  String lengthBetween(int min, int max) =>
      'Debe tener entre $min y $max caracteres.';

  @override
  String get invalidFormat => 'Formato no válido.';

  @override
  String get valuesDoNotMatch => 'Los valores no coinciden.';

  @override
  String get emailRequired => 'El correo electrónico es obligatorio.';

  @override
  String get invalidEmail => 'Introduce un correo electrónico válido.';

  @override
  String get phoneRequired => 'El número de teléfono es obligatorio.';

  @override
  String get invalidPhone => 'Introduce un número de teléfono válido.';

  @override
  String get emailOrPhoneRequired =>
      'El correo electrónico o el número de teléfono es obligatorio.';

  @override
  String get invalidEmailOrPhone =>
      'Introduce un correo electrónico o un número de teléfono válido.';

  @override
  String get passwordRequired => 'La contraseña es obligatoria.';

  @override
  String passwordMinLength(int min) =>
      'La contraseña debe tener al menos $min ${_characters(min)}.';

  @override
  String get passwordLowercase =>
      'La contraseña debe contener al menos una letra minúscula.';

  @override
  String get passwordUppercase =>
      'La contraseña debe contener al menos una letra mayúscula.';

  @override
  String get passwordNumber =>
      'La contraseña debe contener al menos un número.';

  @override
  String get passwordSpecialCharacter =>
      'La contraseña debe contener al menos un carácter especial.';

  @override
  String get invalidNumber => 'Introduce un número válido.';

  @override
  String numberMin(num min) => 'Debe ser mayor o igual que $min.';

  @override
  String numberMax(num max) => 'Debe ser menor o igual que $max.';
}

String _characters(int count) => count == 1 ? 'carácter' : 'caracteres';

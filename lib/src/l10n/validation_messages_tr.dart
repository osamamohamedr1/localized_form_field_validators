import '../validation_messages.dart';

/// Built-in Turkish (`tr`) validation messages.
///
/// Select these messages with `FormValidators.configure(languageCode: 'tr')`,
/// or extend this class to change individual messages and keep the rest in
/// Turkish.
class ValidationMessagesTr extends ValidationMessages {
  /// Creates the Turkish messages.
  const ValidationMessagesTr();

  @override
  String get required => 'Bu alan zorunludur.';

  @override
  String minLength(int min) => 'En az $min karakter olmalıdır.';

  @override
  String maxLength(int max) => 'En fazla $max karakter olmalıdır.';

  @override
  String lengthBetween(int min, int max) =>
      '$min ile $max karakter arasında olmalıdır.';

  @override
  String get invalidFormat => 'Geçersiz biçim.';

  @override
  String get valuesDoNotMatch => 'Değerler eşleşmiyor.';

  @override
  String get emailRequired => 'E-posta adresi zorunludur.';

  @override
  String get invalidEmail => 'Geçerli bir e-posta adresi girin.';

  @override
  String get phoneRequired => 'Telefon numarası zorunludur.';

  @override
  String get invalidPhone => 'Geçerli bir telefon numarası girin.';

  @override
  String get emailOrPhoneRequired =>
      'E-posta adresi veya telefon numarası zorunludur.';

  @override
  String get invalidEmailOrPhone =>
      'Geçerli bir e-posta adresi veya telefon numarası girin.';

  @override
  String get passwordRequired => 'Şifre zorunludur.';

  @override
  String passwordMinLength(int min) => 'Şifre en az $min karakter olmalıdır.';

  @override
  String get passwordLowercase => 'Şifre en az bir küçük harf içermelidir.';

  @override
  String get passwordUppercase => 'Şifre en az bir büyük harf içermelidir.';

  @override
  String get passwordNumber => 'Şifre en az bir rakam içermelidir.';

  @override
  String get passwordSpecialCharacter =>
      'Şifre en az bir özel karakter içermelidir.';

  @override
  String get invalidNumber => 'Geçerli bir sayı girin.';

  @override
  String numberMin(num min) => 'En az $min olmalıdır.';

  @override
  String numberMax(num max) => 'En fazla $max olmalıdır.';
}

import '../validation_messages.dart';

/// Built-in Arabic (`ar`) validation messages.
///
/// Counts follow Arabic plural rules, for example "حرف واحد", "حرفين",
/// "3 أحرف" and "11 حرفًا". Select these messages with
/// `FormValidators.configure(languageCode: 'ar')`, or extend this class to
/// change individual messages and keep the rest in Arabic.
class ValidationMessagesAr extends ValidationMessages {
  /// Creates the Arabic messages.
  const ValidationMessagesAr();

  @override
  String get required => 'هذا الحقل مطلوب.';

  @override
  String minLength(int min) => 'يجب أن يتكون من ${_characters(min)} على الأقل.';

  @override
  String maxLength(int max) => 'يجب ألا يزيد عن ${_characters(max)}.';

  @override
  String lengthBetween(int min, int max) =>
      'يجب أن يكون عدد الأحرف بين $min و$max.';

  @override
  String get invalidFormat => 'التنسيق غير صالح.';

  @override
  String get valuesDoNotMatch => 'القيم غير متطابقة.';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب.';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا.';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب.';

  @override
  String get invalidPhone => 'أدخل رقم هاتف صالحًا.';

  @override
  String get emailOrPhoneRequired => 'البريد الإلكتروني أو رقم الهاتف مطلوب.';

  @override
  String get invalidEmailOrPhone =>
      'أدخل بريدًا إلكترونيًا أو رقم هاتف صالحًا.';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة.';

  @override
  String passwordMinLength(int min) =>
      'يجب أن تتكون كلمة المرور من ${_characters(min)} على الأقل.';

  @override
  String get passwordLowercase =>
      'يجب أن تحتوي كلمة المرور على حرف إنجليزي صغير واحد على الأقل.';

  @override
  String get passwordUppercase =>
      'يجب أن تحتوي كلمة المرور على حرف إنجليزي كبير واحد على الأقل.';

  @override
  String get passwordNumber =>
      'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل.';

  @override
  String get passwordSpecialCharacter =>
      'يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل.';

  @override
  String get invalidNumber => 'أدخل رقمًا صالحًا.';

  @override
  String numberMin(num min) => 'يجب ألا تقل القيمة عن $min.';

  @override
  String numberMax(num max) => 'يجب ألا تزيد القيمة عن $max.';
}

/// "[count] characters" using the CLDR Arabic plural categories.
String _characters(int count) {
  if (count == 1) return 'حرف واحد';
  if (count == 2) return 'حرفين';
  final lastTwo = count % 100;
  if (lastTwo >= 3 && lastTwo <= 10) return '$count أحرف';
  if (lastTwo >= 11 && lastTwo <= 99) return '$count حرفًا';
  return '$count حرف';
}

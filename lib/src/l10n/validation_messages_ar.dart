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

  /// Uses "حقل ... مطلوب" so the adjective agrees with "حقل" whatever the
  /// gender of [fieldName], for example "حقل الاسم مطلوب.".
  @override
  String requiredField(String fieldName) => 'حقل $fieldName مطلوب.';

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
  String get nationalIdRequired => 'رقم الهوية مطلوب.';

  @override
  String get invalidNationalId => 'أدخل رقم هوية صالحًا.';

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

  @override
  String numberGreaterThan(num value) => 'يجب أن تكون القيمة أكبر من $value.';

  @override
  String numberLessThan(num value) => 'يجب أن تكون القيمة أقل من $value.';

  @override
  String get dateRequired => 'اختر تاريخًا.';

  @override
  String get dateMustBeFuture => 'يجب أن يكون التاريخ في المستقبل.';

  @override
  String get dateMustBePast => 'يجب أن يكون التاريخ في الماضي.';

  @override
  String ageMin(int min) => 'يجب ألا يقل العمر عن ${_years(min)}.';

  @override
  String ageMax(int max) => 'يجب ألا يزيد العمر عن ${_years(max)}.';

  @override
  String get passportRequired => 'رقم جواز السفر مطلوب.';

  @override
  String get invalidPassport => 'أدخل رقم جواز سفر صالحًا.';

  @override
  String get ibanRequired => 'رقم الآيبان مطلوب.';

  @override
  String get invalidIban => 'أدخل رقم آيبان صالحًا.';
}

/// "[count] characters" with the right Arabic plural form.
String _characters(int count) => _arabicCount(
  count,
  one: 'حرف واحد',
  two: 'حرفين',
  few: 'أحرف',
  many: 'حرفًا',
  other: 'حرف',
);

/// "[count] years" with the right Arabic plural form.
String _years(int count) => _arabicCount(
  count,
  one: 'سنة واحدة',
  two: 'سنتين',
  few: 'سنوات',
  many: 'سنة',
  other: 'سنة',
);

/// Picks the noun form for [count] using the CLDR Arabic plural categories:
/// one (1), two (2), few (3 to 10), many (11 to 99) and other, each by the
/// last two digits.
String _arabicCount(
  int count, {
  required String one,
  required String two,
  required String few,
  required String many,
  required String other,
}) {
  if (count == 1) return one;
  if (count == 2) return two;
  final lastTwo = count % 100;
  if (lastTwo >= 3 && lastTwo <= 10) return '$count $few';
  if (lastTwo >= 11 && lastTwo <= 99) return '$count $many';
  return '$count $other';
}

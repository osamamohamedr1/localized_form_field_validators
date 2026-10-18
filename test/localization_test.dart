import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

/// Every message, with sample arguments, so whole translations can be
/// compared.
Map<String, String> _allMessages(ValidationMessages m) => {
  'required': m.required,
  'requiredField': m.requiredField('X'),
  'minLength': m.minLength(7),
  'maxLength': m.maxLength(7),
  'lengthBetween': m.lengthBetween(3, 7),
  'invalidFormat': m.invalidFormat,
  'valuesDoNotMatch': m.valuesDoNotMatch,
  'emailRequired': m.emailRequired,
  'invalidEmail': m.invalidEmail,
  'phoneRequired': m.phoneRequired,
  'invalidPhone': m.invalidPhone,
  'emailOrPhoneRequired': m.emailOrPhoneRequired,
  'invalidEmailOrPhone': m.invalidEmailOrPhone,
  'nationalIdRequired': m.nationalIdRequired,
  'invalidNationalId': m.invalidNationalId,
  'passwordRequired': m.passwordRequired,
  'passwordMinLength': m.passwordMinLength(7),
  'passwordLowercase': m.passwordLowercase,
  'passwordUppercase': m.passwordUppercase,
  'passwordNumber': m.passwordNumber,
  'passwordSpecialCharacter': m.passwordSpecialCharacter,
  'invalidNumber': m.invalidNumber,
  'numberMin': m.numberMin(18),
  'numberMax': m.numberMax(120),
  'numberGreaterThan': m.numberGreaterThan(0),
  'numberLessThan': m.numberLessThan(100),
  'dateRequired': m.dateRequired,
  'dateMustBeFuture': m.dateMustBeFuture,
  'dateMustBePast': m.dateMustBePast,
  'ageMin': m.ageMin(18),
  'ageMax': m.ageMax(120),
  'passportRequired': m.passportRequired,
  'invalidPassport': m.invalidPassport,
  'ibanRequired': m.ibanRequired,
  'invalidIban': m.invalidIban,
};

void main() {
  const english = ValidationMessages();

  tearDown(FormValidators.reset);

  group('ValidationMessages.forLanguage', () {
    test('supports English and Arabic', () {
      expect(ValidationMessages.supportedLanguageCodes, ['en', 'ar']);
      expect(ValidationMessages.forLanguage('ar'), isA<ValidationMessagesAr>());
      expect(
        ValidationMessages.forLanguage('en').runtimeType,
        ValidationMessages,
      );
    });

    test('ignores case, whitespace and region or script suffixes', () {
      for (final code in ['AR', ' ar ', 'ar-EG', 'ar_SA', 'Ar-Arab-EG']) {
        expect(
          ValidationMessages.forLanguage(code),
          isA<ValidationMessagesAr>(),
          reason: code,
        );
      }
      expect(
        ValidationMessages.forLanguage('en-US').runtimeType,
        ValidationMessages,
      );
    });

    test('falls back to English for other or empty codes', () {
      for (final code in ['fr', 'de', 'es', 'tr', 'xx', '', '  ', 'arabic']) {
        expect(
          ValidationMessages.forLanguage(code).runtimeType,
          ValidationMessages,
          reason: code,
        );
      }
    });
  });

  group('Arabic messages', () {
    const ar = ValidationMessagesAr();

    test('translate every message', () {
      final englishMessages = _allMessages(english);
      for (final entry in _allMessages(ar).entries) {
        expect(entry.value, isNotEmpty, reason: entry.key);
        expect(
          entry.value,
          isNot(englishMessages[entry.key]),
          reason: '${entry.key} is not translated',
        );
      }
    });

    test('include the arguments', () {
      expect(ar.minLength(7), contains('7'));
      expect(ar.lengthBetween(3, 7), allOf(contains('3'), contains('7')));
      expect(ar.passwordMinLength(7), contains('7'));
      expect(ar.numberMin(18), contains('18'));
      expect(ar.numberMax(2.5), contains('2.5'));
      expect(ar.requiredField('الاسم'), contains('الاسم'));
    });

    test('have the expected text', () {
      expect(ar.required, 'هذا الحقل مطلوب.');
      expect(ar.requiredField('الاسم'), 'حقل الاسم مطلوب.');
      expect(ar.requiredField('كلمة المرور'), 'حقل كلمة المرور مطلوب.');
      expect(ar.invalidEmail, 'أدخل بريدًا إلكترونيًا صالحًا.');
      expect(ar.nationalIdRequired, 'رقم الهوية مطلوب.');
      expect(ar.invalidNationalId, 'أدخل رقم هوية صالحًا.');
      expect(ar.passwordRequired, 'كلمة المرور مطلوبة.');
      expect(ar.numberMin(18), 'يجب ألا تقل القيمة عن 18.');
    });

    test('years follow Arabic plural rules', () {
      expect(ar.ageMin(1), 'يجب ألا يقل العمر عن سنة واحدة.');
      expect(ar.ageMin(2), 'يجب ألا يقل العمر عن سنتين.');
      expect(ar.ageMin(3), 'يجب ألا يقل العمر عن 3 سنوات.');
      expect(ar.ageMin(10), 'يجب ألا يقل العمر عن 10 سنوات.');
      expect(ar.ageMin(18), 'يجب ألا يقل العمر عن 18 سنة.');
      expect(ar.ageMax(100), 'يجب ألا يزيد العمر عن 100 سنة.');
      expect(ar.ageMax(103), 'يجب ألا يزيد العمر عن 103 سنوات.');
    });

    test('counts follow Arabic plural rules', () {
      String count(int n) => ar.maxLength(n);

      expect(count(0), 'يجب ألا يزيد عن 0 حرف.');
      expect(count(1), 'يجب ألا يزيد عن حرف واحد.');
      expect(count(2), 'يجب ألا يزيد عن حرفين.');
      expect(count(3), 'يجب ألا يزيد عن 3 أحرف.');
      expect(count(10), 'يجب ألا يزيد عن 10 أحرف.');
      expect(count(11), 'يجب ألا يزيد عن 11 حرفًا.');
      expect(count(99), 'يجب ألا يزيد عن 99 حرفًا.');
      expect(count(100), 'يجب ألا يزيد عن 100 حرف.');
      expect(count(102), 'يجب ألا يزيد عن 102 حرف.');
      expect(count(103), 'يجب ألا يزيد عن 103 أحرف.');
      expect(count(111), 'يجب ألا يزيد عن 111 حرفًا.');

      expect(ar.minLength(8), 'يجب أن يتكون من 8 أحرف على الأقل.');
      expect(
        ar.passwordMinLength(12),
        'يجب أن تتكون كلمة المرور من 12 حرفًا على الأقل.',
      );
    });
  });

  group('configure(languageCode:)', () {
    test('defaults to English when no language code is passed', () {
      expect(FormValidators.messages.runtimeType, ValidationMessages);
      expect(FormValidators.required()(''), 'This field is required.');

      FormValidators.configure(rules: const ValidationRules());
      expect(FormValidators.messages.runtimeType, ValidationMessages);
      expect(FormValidators.email()(''), 'Email is required.');
    });

    test('switches every validator to Arabic', () {
      FormValidators.configure(languageCode: 'ar');
      expect(FormValidators.messages, isA<ValidationMessagesAr>());
      expect(FormValidators.required()(''), 'هذا الحقل مطلوب.');
      expect(
        FormValidators.required(fieldName: 'الاسم')(''),
        'حقل الاسم مطلوب.',
      );
      expect(FormValidators.email()(''), 'البريد الإلكتروني مطلوب.');
      expect(
        FormValidators.password()('abc'),
        'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.',
      );
      expect(
        FormValidators.nationalId(ArabCountry.egypt)('123'),
        'أدخل رقم هوية صالحًا.',
      );
    });

    test('falls back to English for an unsupported code', () {
      FormValidators.configure(languageCode: 'ar');
      FormValidators.configure(languageCode: 'fr');
      expect(FormValidators.messages.runtimeType, ValidationMessages);
      expect(FormValidators.required()(''), english.required);
    });

    test('affects validators built before the call', () {
      final validator = FormValidators.email();
      expect(validator(''), english.emailRequired);

      FormValidators.configure(languageCode: 'ar-EG');
      expect(validator(''), 'البريد الإلكتروني مطلوب.');

      FormValidators.configure(languageCode: 'en');
      expect(validator(''), english.emailRequired);
    });

    test('keeps the language when only rules change', () {
      FormValidators.configure(languageCode: 'ar');
      FormValidators.configure(
        rules: const ValidationRules(passwordMinLength: 4),
      );
      expect(FormValidators.messages, isA<ValidationMessagesAr>());
      expect(
        FormValidators.password()('abc'),
        'يجب أن تتكون كلمة المرور من 4 أحرف على الأقل.',
      );
    });

    test('per-call messages still win', () {
      FormValidators.configure(languageCode: 'ar');
      expect(FormValidators.required(message: 'Custom')(''), 'Custom');
    });

    test('reset goes back to English', () {
      FormValidators.configure(languageCode: 'ar');
      FormValidators.reset();
      expect(FormValidators.required()(''), english.required);
    });

    test('asserts when both languageCode and messages are passed', () {
      expect(
        () => FormValidators.configure(
          languageCode: 'ar',
          messages: const ValidationMessages(),
        ),
        throwsAssertionError,
      );
    });
  });

  test('the Arabic messages can be extended to change one message', () {
    FormValidators.configure(messages: const _CustomArabic());
    expect(FormValidators.email()('x'), 'البريد غير صحيح');
    expect(FormValidators.email()(''), 'البريد الإلكتروني مطلوب.');
    expect(FormValidators.required()(''), 'هذا الحقل مطلوب.');
  });
}

class _CustomArabic extends ValidationMessagesAr {
  const _CustomArabic();

  @override
  String get invalidEmail => 'البريد غير صحيح';
}

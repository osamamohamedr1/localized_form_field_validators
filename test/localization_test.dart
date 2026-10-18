import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

/// Every message, with sample arguments, so whole translations can be
/// compared.
Map<String, String> _allMessages(ValidationMessages m) => {
  'required': m.required,
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
  'passwordRequired': m.passwordRequired,
  'passwordMinLength': m.passwordMinLength(7),
  'passwordLowercase': m.passwordLowercase,
  'passwordUppercase': m.passwordUppercase,
  'passwordNumber': m.passwordNumber,
  'passwordSpecialCharacter': m.passwordSpecialCharacter,
  'invalidNumber': m.invalidNumber,
  'numberMin': m.numberMin(18),
  'numberMax': m.numberMax(120),
};

void main() {
  const english = ValidationMessages();

  tearDown(FormValidators.reset);

  group('ValidationMessages.forLanguage', () {
    test('lists the supported language codes', () {
      expect(ValidationMessages.supportedLanguageCodes, [
        'en',
        'ar',
        'de',
        'es',
        'fr',
        'tr',
      ]);
    });

    test('returns the built-in translation for each code', () {
      expect(ValidationMessages.forLanguage('ar'), isA<ValidationMessagesAr>());
      expect(ValidationMessages.forLanguage('de'), isA<ValidationMessagesDe>());
      expect(ValidationMessages.forLanguage('es'), isA<ValidationMessagesEs>());
      expect(ValidationMessages.forLanguage('fr'), isA<ValidationMessagesFr>());
      expect(ValidationMessages.forLanguage('tr'), isA<ValidationMessagesTr>());
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
        ValidationMessages.forLanguage('fr-CA'),
        isA<ValidationMessagesFr>(),
      );
      expect(
        ValidationMessages.forLanguage('es_MX'),
        isA<ValidationMessagesEs>(),
      );
      expect(
        ValidationMessages.forLanguage('en-US').runtimeType,
        ValidationMessages,
      );
    });

    test('falls back to English for unsupported or empty codes', () {
      for (final code in ['xx', 'ja', '', '  ', 'arabic']) {
        expect(
          ValidationMessages.forLanguage(code).runtimeType,
          ValidationMessages,
          reason: code,
        );
      }
    });
  });

  group('built-in translations', () {
    final englishMessages = _allMessages(english);

    for (final code in ValidationMessages.supportedLanguageCodes.skip(1)) {
      test('$code translates every message', () {
        final translated = _allMessages(ValidationMessages.forLanguage(code));
        for (final entry in translated.entries) {
          expect(entry.value, isNotEmpty, reason: '$code ${entry.key}');
          expect(
            entry.value,
            isNot(englishMessages[entry.key]),
            reason: '$code ${entry.key} is not translated',
          );
        }
      });

      test('$code includes the arguments', () {
        final m = ValidationMessages.forLanguage(code);
        expect(m.minLength(7), contains('7'));
        expect(m.maxLength(7), contains('7'));
        expect(m.lengthBetween(3, 7), allOf(contains('3'), contains('7')));
        expect(m.passwordMinLength(7), contains('7'));
        expect(m.numberMin(18), contains('18'));
        expect(m.numberMax(2.5), contains('2.5'));
      });
    }

    test('Arabic messages', () {
      const ar = ValidationMessagesAr();
      expect(ar.required, 'هذا الحقل مطلوب.');
      expect(ar.invalidEmail, 'أدخل بريدًا إلكترونيًا صالحًا.');
      expect(ar.passwordRequired, 'كلمة المرور مطلوبة.');
      expect(ar.numberMin(18), 'يجب ألا تقل القيمة عن 18.');
    });

    test('Arabic counts follow Arabic plural rules', () {
      const ar = ValidationMessagesAr();
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

    test('French and Spanish use the singular for one character', () {
      const fr = ValidationMessagesFr();
      expect(fr.minLength(1), 'Doit contenir au moins 1 caractère.');
      expect(fr.minLength(0), 'Doit contenir au moins 0 caractère.');
      expect(fr.minLength(2), 'Doit contenir au moins 2 caractères.');

      const es = ValidationMessagesEs();
      expect(es.minLength(1), 'Debe tener al menos 1 carácter.');
      expect(es.minLength(2), 'Debe tener al menos 2 caracteres.');
    });

    test('German and Turkish messages', () {
      expect(
        const ValidationMessagesDe().passwordUppercase,
        'Das Passwort muss mindestens einen Großbuchstaben enthalten.',
      );
      expect(
        const ValidationMessagesTr().minLength(8),
        'En az 8 karakter olmalıdır.',
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

    test('switches every validator to the built-in language', () {
      FormValidators.configure(languageCode: 'ar');
      expect(FormValidators.messages, isA<ValidationMessagesAr>());
      expect(FormValidators.required()(''), 'هذا الحقل مطلوب.');
      expect(FormValidators.email()(''), 'البريد الإلكتروني مطلوب.');
      expect(
        FormValidators.password()('abc'),
        'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.',
      );
    });

    test('falls back to English for an unsupported code', () {
      FormValidators.configure(languageCode: 'ar');
      FormValidators.configure(languageCode: 'xx');
      expect(FormValidators.messages.runtimeType, ValidationMessages);
      expect(FormValidators.required()(''), english.required);
    });

    test('affects validators built before the call', () {
      final validator = FormValidators.email();
      expect(validator(''), english.emailRequired);

      FormValidators.configure(languageCode: 'fr');
      expect(validator(''), "L'adresse e-mail est obligatoire.");

      FormValidators.configure(languageCode: 'de-AT');
      expect(validator(''), 'Die E-Mail-Adresse ist erforderlich.');
    });

    test('keeps the language when only rules change', () {
      FormValidators.configure(languageCode: 'tr');
      FormValidators.configure(
        rules: const ValidationRules(passwordMinLength: 4),
      );
      expect(FormValidators.messages, isA<ValidationMessagesTr>());
      expect(
        FormValidators.password()('abc'),
        'Şifre en az 4 karakter olmalıdır.',
      );
    });

    test('per-call messages still win', () {
      FormValidators.configure(languageCode: 'ar');
      expect(FormValidators.required(message: 'Custom')(''), 'Custom');
    });

    test('reset goes back to English', () {
      FormValidators.configure(languageCode: 'es');
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

  test('a built-in translation can be extended to change one message', () {
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

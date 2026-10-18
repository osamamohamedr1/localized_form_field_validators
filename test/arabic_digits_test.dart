import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  test('normalizeDigits converts Arabic-Indic and Persian digits only', () {
    expect(FormValidators.normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
    expect(FormValidators.normalizeDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    expect(FormValidators.normalizeDigits('+٢٠ ١٠-abc'), '+20 10-abc');
    expect(FormValidators.normalizeDigits('no digits'), 'no digits');
    expect(FormValidators.normalizeDigits(''), '');
  });

  group('accepted by default', () {
    test('phone', () {
      final validator = FormValidators.phone(pattern: PhonePatterns.egypt);
      expect(validator('٠١٠١٢٣٤٥٦٧٨'), isNull);
      expect(validator('۰۱۰۱۲۳۴۵۶۷۸'), isNull);
      expect(validator('٠١٣١٢٣٤٥٦٧٨'), defaults.invalidPhone);
    });

    test('emailOrPhone treats Arabic digits as a phone number', () {
      final validator = FormValidators.emailOrPhone(
        phonePattern: PhonePatterns.saudiArabia,
      );
      expect(validator('٠٥١٢٣٤٥٦٧٨'), isNull);
      expect(validator('۰۵۱۲۳۴۵۶۷۸'), isNull);
    });

    test('nationalId', () {
      final validator = FormValidators.nationalId(ArabCountry.egypt);
      expect(validator('٢٩٠٠١٠١٠١٢٣٤٥٦'), isNull);
      expect(validator('٢٩٠٠١٠١ ٠١٢٣٤٥٦'), isNull);
    });

    test('number, including the Arabic decimal separator', () {
      expect(FormValidators.number(min: 18)('٣٠'), isNull);
      expect(FormValidators.number(min: 18)('١٧'), defaults.numberMin(18));
      expect(FormValidators.number()('١٫٥'), isNull);
      expect(
        FormValidators.number(allowDecimal: false)('١٫٥'),
        defaults.invalidNumber,
      );
    });

    test('passport and IBAN', () {
      expect(FormValidators.passport()('A١٢٣٤٥٦٧٨'), isNull);
      expect(FormValidators.iban()('SA٠٣ ٨٠٠٠ ٠٠٠٠ ٦٠٨٠ ١٠١٦ ٧٥١٩'), isNull);
    });
  });

  test('normalizeDigits: false rejects Arabic digits', () {
    FormValidators.configure(
      rules: const ValidationRules(normalizeDigits: false),
    );
    expect(
      FormValidators.phone(pattern: PhonePatterns.egypt)('٠١٠١٢٣٤٥٦٧٨'),
      defaults.invalidPhone,
    );
    expect(
      FormValidators.nationalId(ArabCountry.egypt)('٢٩٠٠١٠١٠١٢٣٤٥٦'),
      defaults.invalidNationalId,
    );
    expect(FormValidators.number()('٣٠'), defaults.invalidNumber);
    expect(
      FormValidators.phone(pattern: PhonePatterns.egypt)('01012345678'),
      isNull,
    );
  });

  test('pattern and length validators are not affected', () {
    expect(FormValidators.pattern(r'^\d+$')('١٢٣'), defaults.invalidFormat);
    expect(FormValidators.pattern('^[٠-٩]+\$')('١٢٣'), isNull);
  });
}

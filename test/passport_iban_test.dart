import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  group('passport', () {
    final validator = FormValidators.passport();

    test('accepts 6 to 9 letters or digits by default', () {
      expect(validator('A12345678'), isNull);
      expect(validator('a1234567'), isNull);
      expect(validator('123456'), isNull);
      expect(validator('  AB123456  '), isNull);
    });

    test('rejects other values', () {
      expect(validator('A1234'), defaults.invalidPassport);
      expect(validator('A123456789'), defaults.invalidPassport);
      expect(validator('A1234-567'), defaults.invalidPassport);
      expect(validator('A 1234567'), defaults.invalidPassport);
    });

    test('uses a per-call pattern', () {
      final egypt = FormValidators.passport(pattern: r'^[A-Za-z]\d{8}$');
      expect(egypt('A12345678'), isNull);
      expect(egypt('12345678A'), defaults.invalidPassport);
    });

    test('uses the global pattern', () {
      FormValidators.configure(
        rules: const ValidationRules(passportPattern: r'^\d{9}$'),
      );
      expect(validator('123456789'), isNull);
      expect(validator('A12345678'), defaults.invalidPassport);
    });

    test('handles empty values and per-call messages', () {
      expect(validator(''), defaults.passportRequired);
      expect(FormValidators.passport(isRequired: false)(''), isNull);
      final custom = FormValidators.passport(
        requiredMessage: 'Passport?',
        message: 'Bad passport',
      );
      expect(custom(''), 'Passport?');
      expect(custom('1'), 'Bad passport');
    });
  });

  group('iban', () {
    final validator = FormValidators.iban();

    // Example IBANs from the SWIFT IBAN registry.
    const validIbans = [
      'GB82WEST12345698765432',
      'DE89370400440532013000',
      'SA0380000000608010167519',
      'AE070331234567890123456',
      'EG380019000500000000263180002',
      'KW81CBKU0000000000001234560101',
      'QA58DOHB00001234567890ABCDEFG',
      'JO94CBJO0010000000000131000302',
      'BH67BMAG00001299123456',
      'TR330006100519786457841326',
    ];

    test('accepts registry examples', () {
      for (final iban in validIbans) {
        expect(validator(iban), isNull, reason: iban);
      }
    });

    test('ignores spaces and letter case', () {
      expect(validator('SA03 8000 0000 6080 1016 7519'), isNull);
      expect(validator('gb82 west 1234 5698 7654 32'), isNull);
    });

    test('rejects a wrong checksum', () {
      expect(validator('GB82WEST12345698765433'), defaults.invalidIban);
      expect(validator('SA0480000000608010167519'), defaults.invalidIban);
    });

    test('rejects the wrong length for the country', () {
      expect(validator('SA038000000060801016751'), defaults.invalidIban);
      expect(validator('GB82WEST123456987654321'), defaults.invalidIban);
    });

    test('rejects malformed values', () {
      expect(validator('1234567890123456'), defaults.invalidIban);
      expect(validator('SAXX80000000608010167519'), defaults.invalidIban);
      expect(validator('SA03-8000-0000-6080-1016-7519'), defaults.invalidIban);
      expect(validator('XX12345'), defaults.invalidIban);
    });

    test('restricts the country with countryCode', () {
      final saudi = FormValidators.iban(countryCode: 'sa');
      expect(saudi('SA0380000000608010167519'), isNull);
      expect(saudi('AE070331234567890123456'), defaults.invalidIban);
    });

    test('handles empty values and per-call messages', () {
      expect(validator(' '), defaults.ibanRequired);
      expect(FormValidators.iban(isRequired: false)(''), isNull);
      final custom = FormValidators.iban(
        requiredMessage: 'IBAN?',
        message: 'Bad IBAN',
      );
      expect(custom(''), 'IBAN?');
      expect(custom('GB82WEST12345698765433'), 'Bad IBAN');
    });

    test('uses Arabic messages when configured', () {
      FormValidators.configure(languageCode: 'ar');
      expect(validator(''), 'رقم الآيبان مطلوب.');
      expect(validator('GB00'), 'أدخل رقم آيبان صالحًا.');
      expect(FormValidators.passport()('1'), 'أدخل رقم جواز سفر صالحًا.');
    });
  });
}

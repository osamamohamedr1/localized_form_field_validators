import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';
import 'package:localized_form_field_validators/src/national_ids.dart';

const _defaults = ValidationMessages();

/// Expects every value in [valid] to pass and every value in [invalid] to
/// fail with [ValidationMessages.invalidNationalId] for [country].
void _expectIds(
  ArabCountry country, {
  required List<String> valid,
  required List<String> invalid,
}) {
  final validator = FormValidators.nationalId(country);
  for (final id in valid) {
    expect(validator(id), isNull, reason: '${country.name} $id should pass');
  }
  for (final id in invalid) {
    expect(
      validator(id),
      _defaults.invalidNationalId,
      reason: '${country.name} $id should fail',
    );
  }
}

void main() {
  tearDown(FormValidators.reset);

  group('nationalId', () {
    test('rejects an empty value when required', () {
      final validator = FormValidators.nationalId(ArabCountry.egypt);
      expect(validator(null), _defaults.nationalIdRequired);
      expect(validator('  '), _defaults.nationalIdRequired);
      expect(validator(' - '), _defaults.nationalIdRequired);
    });

    test('accepts an empty value but checks a filled one when optional', () {
      final validator = FormValidators.nationalId(
        ArabCountry.egypt,
        isRequired: false,
      );
      expect(validator(''), isNull);
      expect(validator('123'), _defaults.invalidNationalId);
    });

    test('removes surrounding and inner spaces and dashes', () {
      final uae = FormValidators.nationalId(ArabCountry.uae);
      expect(uae('784-1990-1234567-6'), isNull);
      expect(uae(' 784 1990 1234567 6 '), isNull);
      expect(
        FormValidators.nationalId(ArabCountry.egypt)('2900101 0123456'),
        isNull,
      );
    });

    test('uses per-call messages', () {
      final validator = FormValidators.nationalId(
        ArabCountry.saudiArabia,
        requiredMessage: 'ID needed',
        message: 'Bad ID',
      );
      expect(validator(''), 'ID needed');
      expect(validator('123'), 'Bad ID');
    });

    test('only checks presence for a country without rules', () {
      for (final country in [
        ArabCountry.lebanon,
        ArabCountry.oman,
        ArabCountry.sudan,
        ArabCountry.yemen,
      ]) {
        final validator = FormValidators.nationalId(country);
        expect(validator('anything 123'), isNull, reason: country.name);
        expect(validator(''), _defaults.nationalIdRequired);
      }
    });

    test('only checks presence when the country is null', () {
      final validator = FormValidators.nationalId(ArabCountry.fromCode('US'));
      expect(validator('X123'), isNull);
      expect(validator(''), _defaults.nationalIdRequired);
    });

    test('uses Arabic messages when configured', () {
      FormValidators.configure(languageCode: 'ar');
      final validator = FormValidators.nationalId(ArabCountry.kuwait);
      expect(validator(''), 'رقم الهوية مطلوب.');
      expect(validator('1'), 'أدخل رقم هوية صالحًا.');
    });
  });

  group('Egypt', () {
    test('accepts valid IDs from both centuries', () {
      _expectIds(
        ArabCountry.egypt,
        valid: [
          '29001010123456', // 1990-01-01, Cairo
          '30506152112345', // 2005-06-15, Giza
          '30002298812345', // 2000-02-29 (leap day), born abroad
        ],
        invalid: [],
      );
    });

    test('rejects a wrong length, century, date or governorate', () {
      _expectIds(
        ArabCountry.egypt,
        valid: [],
        invalid: [
          '2900101012345', // 13 digits
          '290010101234567', // 15 digits
          '2900101012345a',
          '19001010123456', // century 1
          '49001010123456', // century 4
          '29013010123456', // month 13
          '29000010123456', // month 0
          '29002300123456', // 30 February
          '29002290123456', // 29 February 1990
          '29004310123456', // 31 April
          '29001000123456', // day 0
          '39912310112345', // 2099, in the future
          '29001010512345', // governorate 05
          '29001019912345', // governorate 99
        ],
      );
    });

    test('compares the birth date with today', () {
      expect(
        isValidEgyptianNationalId('32601020112345', today: DateTime(2026)),
        isFalse,
      );
      expect(
        isValidEgyptianNationalId('32601010112345', today: DateTime(2026)),
        isTrue,
      );
    });
  });

  test('Saudi Arabia: national ID or Iqama with a check digit', () {
    _expectIds(
      ArabCountry.saudiArabia,
      valid: ['1000000008', '1087654321', '2000000006', '2456789011'],
      invalid: [
        '1000000009', // wrong check digit
        '2456789012', // wrong check digit
        '3000000004', // first digit 3
        '100000000', // 9 digits
        '10000000a8',
      ],
    );
  });

  group('United Arab Emirates', () {
    test('Emirates ID with 784, birth year and check digit', () {
      _expectIds(
        ArabCountry.uae,
        valid: ['784199012345676', '784200511111112'],
        invalid: [
          '784199012345677', // wrong check digit
          '785199012345676', // not 784
          '784189912345670', // year 1899
          '78419901234567', // 14 digits
        ],
      );
    });

    test('rejects a birth year in the future', () {
      expect(
        isValidUaeNationalId('784199012345676', today: DateTime(1989)),
        isFalse,
      );
    });
  });

  group('Kuwait', () {
    test('civil ID with birth date and check digit', () {
      _expectIds(
        ArabCountry.kuwait,
        valid: ['290051512346', '285010100015', '302030405678'],
        invalid: [
          '290051512347', // wrong check digit
          '190051512346', // century 1
          '290133112346', // month 13
          '29005151234', // 11 digits
        ],
      );
    });

    test('rejects a birth date in the future', () {
      expect(
        isValidKuwaitNationalId('302030405678', today: DateTime(2002)),
        isFalse,
      );
      expect(
        isValidKuwaitNationalId('302030405678', today: DateTime(2002, 3, 4)),
        isTrue,
      );
    });
  });

  group('Qatar', () {
    test('QID with birth year and nationality code', () {
      _expectIds(
        ArabCountry.qatar,
        valid: ['28563412345', '30181800001'],
        invalid: [
          '2856341234', // 10 digits
          '18563412345', // century 1
          '39963412345', // 2099, in the future
          '28500012345', // nationality 000
        ],
      );
    });

    test('compares the birth year with today', () {
      expect(
        isValidQatarNationalId('32763412345', today: DateTime(2026)),
        isFalse,
      );
      expect(
        isValidQatarNationalId('32663412345', today: DateTime(2026)),
        isTrue,
      );
    });
  });

  test('Bahrain: CPR with a birth month', () {
    _expectIds(
      ArabCountry.bahrain,
      valid: ['850212345', '011212345'],
      invalid: ['851312345', '850012345', '85021234', '8502123456'],
    );
  });

  group('Libya', () {
    test('national number with gender digit and birth year', () {
      _expectIds(
        ArabCountry.libya,
        valid: ['119901234567', '220051234567'],
        invalid: [
          '319901234567', // first digit 3
          '118991234567', // year 1899
          '29999123456', // 11 digits
        ],
      );
    });

    test('rejects a birth year in the future', () {
      expect(
        isValidLibyaNationalId('120271234567', today: DateTime(2026)),
        isFalse,
      );
    });
  });

  test('Palestine: 9 digits with a check digit', () {
    _expectIds(
      ArabCountry.palestine,
      valid: ['123456782', '401234562'],
      invalid: ['123456783', '12345678', '1234567820'],
    );
  });

  test('Morocco: CIN letters and digits', () {
    _expectIds(
      ArabCountry.morocco,
      valid: ['A123456', 'AB123456', 'bk12345', 'J1'],
      invalid: ['123456', 'ABC12345', 'AB1234567', 'A'],
    );
  });

  test('length-only countries', () {
    _expectIds(
      ArabCountry.algeria,
      valid: ['123456789012345678'],
      invalid: ['12345678901234567', '12345678901234567X'],
    );
    _expectIds(
      ArabCountry.iraq,
      valid: ['123456789012'],
      invalid: ['12345678901', '1234567890123'],
    );
    _expectIds(
      ArabCountry.jordan,
      valid: ['9861012345'],
      invalid: ['986101234', '98610123456'],
    );
    _expectIds(
      ArabCountry.syria,
      valid: ['01234567890'],
      invalid: ['0123456789', '012345678901'],
    );
    _expectIds(
      ArabCountry.tunisia,
      valid: ['01234567'],
      invalid: ['0123456', '012345678', '0123456a'],
    );
  });

  group('overriding national ID rules', () {
    bool twelveDigits(String id) => RegExp(r'^\d{12}$').hasMatch(id);

    test('isValid replaces the built-in rule for one field', () {
      final validator = FormValidators.nationalId(
        ArabCountry.kuwait,
        isValid: twelveDigits,
      );
      expect(validator('290051512347'), isNull); // fails the built-in check
      expect(validator('12345'), _defaults.invalidNationalId);
    });

    test('isValid works without a country', () {
      final validator = FormValidators.nationalId(null, isValid: twelveDigits);
      expect(validator('123456789012'), isNull);
      expect(validator('123'), _defaults.invalidNationalId);
    });

    test('isValid can add rules for a country without built-in rules', () {
      final validator = FormValidators.nationalId(
        ArabCountry.oman,
        isValid: (id) => RegExp(r'^\d{8}$').hasMatch(id),
      );
      expect(validator('12345678'), isNull);
      expect(validator('1234'), _defaults.invalidNationalId);
    });

    test('isValid can build on the built-in rule', () {
      final validator = FormValidators.nationalId(
        ArabCountry.egypt,
        isValid: (id) =>
            ArabCountry.egypt.isValidNationalId(id) || id == '00000000000000',
      );
      expect(validator('29001010123456'), isNull);
      expect(validator('00000000000000'), isNull);
      expect(validator('19001010123456'), _defaults.invalidNationalId);
    });

    test('nationalIdRules replaces the rule for the whole app', () {
      FormValidators.configure(
        rules: ValidationRules(
          nationalIdRules: {ArabCountry.kuwait: twelveDigits},
        ),
      );
      final kuwait = FormValidators.nationalId(ArabCountry.kuwait);
      expect(kuwait('290051512347'), isNull);
      // Other countries keep their built-in rules.
      expect(
        FormValidators.nationalId(ArabCountry.egypt)('290051512347'),
        _defaults.invalidNationalId,
      );
    });

    test('isValid beats nationalIdRules', () {
      FormValidators.configure(
        rules: ValidationRules(
          nationalIdRules: {ArabCountry.kuwait: (id) => false},
        ),
      );
      expect(
        FormValidators.nationalId(ArabCountry.kuwait)('290051512346'),
        _defaults.invalidNationalId,
      );
      expect(
        FormValidators.nationalId(ArabCountry.kuwait, isValid: (id) => true)(
          'anything',
        ),
        isNull,
      );
    });

    test('the rule receives the cleaned value', () {
      String? received;
      FormValidators.nationalId(
        ArabCountry.uae,
        isValid: (id) {
          received = id;
          return true;
        },
      )(' ٧٨٤-1990 1234567-6 ');
      expect(received, '784199012345676');
    });
  });
}

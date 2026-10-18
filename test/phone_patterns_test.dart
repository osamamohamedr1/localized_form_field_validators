import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  tearDown(FormValidators.reset);

  void expectPattern(
    String pattern, {
    required List<String> valid,
    required List<String> invalid,
  }) {
    final regExp = RegExp(pattern);
    for (final number in valid) {
      expect(regExp.hasMatch(number), isTrue, reason: '$number should match');
    }
    for (final number in invalid) {
      expect(regExp.hasMatch(number), isFalse, reason: '$number should fail');
    }
  }

  test('egypt', () {
    expectPattern(
      PhonePatterns.egypt,
      valid: ['01012345678', '01112345678', '01212345678', '01512345678'],
      invalid: [
        '1012345678 ',
        '01312345678',
        '0101234567',
        '010123456789',
        '+201012345678',
        '010 1234 5678',
      ],
    );
    expect(RegExp(PhonePatterns.egypt).hasMatch('1012345678'), isTrue);
  });

  test('saudiArabia and uae', () {
    for (final pattern in [PhonePatterns.saudiArabia, PhonePatterns.uae]) {
      expectPattern(
        pattern,
        valid: ['512345678', '0512345678', '501234567'],
        invalid: ['412345678', '51234567', '5123456789', '+966512345678'],
      );
    }
  });

  test('kuwait', () {
    expectPattern(
      PhonePatterns.kuwait,
      valid: ['41234567', '51234567', '61234567', '91234567'],
      invalid: ['21234567', '71234567', '5123456', '512345678'],
    );
  });

  test('qatar', () {
    expectPattern(
      PhonePatterns.qatar,
      valid: ['33123456', '55123456', '66123456', '77123456'],
      invalid: ['44123456', '22123456', '5512345', '551234567'],
    );
  });

  test('bahrain', () {
    expectPattern(
      PhonePatterns.bahrain,
      valid: ['36123456', '66123456'],
      invalid: ['17123456', '3612345', '361234567'],
    );
  });

  test('oman', () {
    expectPattern(
      PhonePatterns.oman,
      valid: ['71234567', '91234567'],
      invalid: ['21234567', '9123456', '912345678'],
    );
  });

  test('yemen', () {
    expectPattern(
      PhonePatterns.yemen,
      valid: ['771234567', '0711234567', '731234567', '701234567'],
      invalid: ['741234567', '77123456', '7712345678'],
    );
  });

  test('iraq', () {
    expectPattern(
      PhonePatterns.iraq,
      valid: ['07701234567', '7501234567', '07901234567'],
      invalid: ['07201234567', '0770123456', '077012345678'],
    );
  });

  test('jordan', () {
    expectPattern(
      PhonePatterns.jordan,
      valid: ['0791234567', '771234567', '0781234567'],
      invalid: ['0761234567', '079123456', '07912345678'],
    );
  });

  test('lebanon', () {
    expectPattern(
      PhonePatterns.lebanon,
      valid: ['03123456', '3123456', '70123456', '71123456', '81123456'],
      invalid: ['72123456', '0312345', '031234567', '01123456'],
    );
  });

  test('palestine', () {
    expectPattern(
      PhonePatterns.palestine,
      valid: ['0591234567', '561234567'],
      invalid: ['0571234567', '059123456', '05912345678'],
    );
  });

  test('syria', () {
    expectPattern(
      PhonePatterns.syria,
      valid: ['0931234567', '991234567'],
      invalid: ['0831234567', '093123456', '09312345678'],
    );
  });

  test('algeria', () {
    expectPattern(
      PhonePatterns.algeria,
      valid: ['0551234567', '661234567', '0771234567'],
      invalid: ['0451234567', '055123456', '05512345678'],
    );
  });

  test('libya', () {
    expectPattern(
      PhonePatterns.libya,
      valid: ['0911234567', '951234567'],
      invalid: ['0961234567', '091123456', '09112345678'],
    );
  });

  test('morocco', () {
    expectPattern(
      PhonePatterns.morocco,
      valid: ['0612345678', '712345678'],
      invalid: ['0512345678', '061234567', '06123456789'],
    );
  });

  test('sudan', () {
    expectPattern(
      PhonePatterns.sudan,
      valid: ['0912345678', '991234567', '0112345678', '121234567'],
      invalid: ['0812345678', '0132345678', '091234567'],
    );
  });

  test('tunisia', () {
    expectPattern(
      PhonePatterns.tunisia,
      valid: ['20123456', '41234567', '51234567', '98123456'],
      invalid: ['31234567', '71234567', '2012345', '201234567'],
    );
  });

  test('anyOf matches a value that matches any pattern', () {
    final combined = PhonePatterns.anyOf([
      PhonePatterns.egypt,
      PhonePatterns.qatar,
    ]);
    expectPattern(
      combined,
      valid: ['01012345678', '55123456'],
      invalid: ['512345678', '44123456', '0101234567855123456'],
    );
    expect(
      PhonePatterns.anyOf([PhonePatterns.oman]),
      '(?:${PhonePatterns.oman})',
    );
    expect(() => PhonePatterns.anyOf([]), throwsAssertionError);
  });

  test('works with phone() per call and through ValidationRules', () {
    const defaults = ValidationMessages();
    expect(
      FormValidators.phone(pattern: PhonePatterns.qatar)('55123456'),
      isNull,
    );
    expect(
      FormValidators.phone(pattern: PhonePatterns.qatar)('44123456'),
      defaults.invalidPhone,
    );

    FormValidators.configure(
      rules: const ValidationRules(phonePattern: PhonePatterns.egypt),
    );
    expect(FormValidators.phone()('01012345678'), isNull);
    expect(FormValidators.emailOrPhone()('01012345678'), isNull);
    expect(FormValidators.emailOrPhone()('55123456'), defaults.invalidPhone);
  });
}

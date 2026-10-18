import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  group('email', () {
    final validator = FormValidators.email();

    test('accepts valid addresses', () {
      expect(validator('user@example.com'), isNull);
      expect(validator('first.last+tag@mail.example.co.uk'), isNull);
      expect(validator('a_b-c@sub-domain.io'), isNull);
    });

    test('rejects invalid addresses', () {
      expect(validator('user'), defaults.invalidEmail);
      expect(validator('user@'), defaults.invalidEmail);
      expect(validator('user@example'), defaults.invalidEmail);
      expect(validator('user@example.c'), defaults.invalidEmail);
      expect(validator('@example.com'), defaults.invalidEmail);
      expect(validator('us er@example.com'), defaults.invalidEmail);
    });

    test('trims before matching', () {
      expect(validator('  user@example.com  '), isNull);
    });

    test('rejects an empty value when required', () {
      expect(validator(null), defaults.emailRequired);
      expect(validator(''), defaults.emailRequired);
      expect(validator('   '), defaults.emailRequired);
    });

    test('accepts an empty value but checks a filled one when optional', () {
      final optional = FormValidators.email(isRequired: false);
      expect(optional(null), isNull);
      expect(optional('  '), isNull);
      expect(optional('nope'), defaults.invalidEmail);
      expect(optional('user@example.com'), isNull);
    });

    test('uses per-call pattern and messages', () {
      final validator = FormValidators.email(
        pattern: r'@company\.com$',
        requiredMessage: 'Work email required',
        message: 'Use your work email',
      );
      expect(validator(''), 'Work email required');
      expect(validator('user@gmail.com'), 'Use your work email');
      expect(validator('user@company.com'), isNull);
    });
  });

  group('phone', () {
    final validator = FormValidators.phone();

    test('accepts 7 to 15 digits with an optional leading +', () {
      expect(validator('1234567'), isNull);
      expect(validator('123456789012345'), isNull);
      expect(validator('+201001234567'), isNull);
    });

    test('rejects invalid numbers', () {
      expect(validator('123456'), defaults.invalidPhone);
      expect(validator('1234567890123456'), defaults.invalidPhone);
      expect(validator('12345abc'), defaults.invalidPhone);
      expect(validator('+20 100 123 4567'), defaults.invalidPhone);
      expect(validator('++1234567'), defaults.invalidPhone);
    });

    test('trims before matching', () {
      expect(validator('  01001234567  '), isNull);
    });

    test('rejects an empty value when required', () {
      expect(validator(null), defaults.phoneRequired);
      expect(validator(' '), defaults.phoneRequired);
    });

    test('accepts an empty value but checks a filled one when optional', () {
      final optional = FormValidators.phone(isRequired: false);
      expect(optional(''), isNull);
      expect(optional('12'), defaults.invalidPhone);
    });

    test('uses per-call pattern and messages', () {
      final validator = FormValidators.phone(
        pattern: r'^\d{3}-\d{4}$',
        requiredMessage: 'Need a phone',
        message: 'Use 555-1234',
      );
      expect(validator(''), 'Need a phone');
      expect(validator('5551234'), 'Use 555-1234');
      expect(validator('555-1234'), isNull);
    });
  });

  group('emailOrPhone', () {
    final validator = FormValidators.emailOrPhone();

    test('accepts a valid email or phone', () {
      expect(validator('user@example.com'), isNull);
      expect(validator('01001234567'), isNull);
      expect(validator('+201001234567'), isNull);
    });

    test('validates input with @ or a letter as an email', () {
      expect(validator('user@example'), defaults.invalidEmail);
      expect(validator('username'), defaults.invalidEmail);
      expect(validator('123abc'), defaults.invalidEmail);
      expect(validator('@'), defaults.invalidEmail);
    });

    test('treats any Unicode letter as a letter', () {
      expect(validator('مرحبا'), defaults.invalidEmail);
    });

    test('validates digits with an optional leading + as a phone', () {
      expect(validator('12345'), defaults.invalidPhone);
      expect(validator('+12345'), defaults.invalidPhone);
    });

    test('rejects anything else with invalidEmailOrPhone', () {
      expect(validator('+'), defaults.invalidEmailOrPhone);
      expect(validator('010-0123-4567'), defaults.invalidEmailOrPhone);
      expect(validator('!!!'), defaults.invalidEmailOrPhone);
      expect(validator('12 34'), defaults.invalidEmailOrPhone);
    });

    test('trims before checking', () {
      expect(validator('  user@example.com  '), isNull);
      expect(validator('  01001234567  '), isNull);
    });

    test('rejects an empty value when required', () {
      expect(validator(null), defaults.emailOrPhoneRequired);
      expect(validator('  '), defaults.emailOrPhoneRequired);
    });

    test('accepts an empty value but checks a filled one when optional', () {
      final optional = FormValidators.emailOrPhone(isRequired: false);
      expect(optional(''), isNull);
      expect(optional('nope'), defaults.invalidEmail);
    });

    test('per-call message replaces every non-empty error', () {
      final validator = FormValidators.emailOrPhone(
        requiredMessage: 'Enter something',
        message: 'Not valid',
      );
      expect(validator(''), 'Enter something');
      expect(validator('user@example'), 'Not valid');
      expect(validator('123'), 'Not valid');
      expect(validator('!!!'), 'Not valid');
    });
  });
}

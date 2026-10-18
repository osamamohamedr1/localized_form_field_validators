import 'package:flutter_test/flutter_test.dart';
import 'package:form_validators/form_validators.dart';

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  group('password', () {
    final validator = FormValidators.password();

    test('accepts a password at or above the minimum length', () {
      expect(validator('abcdefgh'), isNull);
      expect(validator('abcdefghi'), isNull);
    });

    test('rejects a shorter password', () {
      expect(validator('abcdefg'), defaults.passwordMinLength(8));
    });

    test('does not require character classes', () {
      expect(validator('aaaaaaaa'), isNull);
    });

    test('checks the raw value without trimming', () {
      expect(validator(' abcdef '), isNull);
      expect(validator('  abc  '), defaults.passwordMinLength(8));
    });

    test('treats a password of only spaces as empty', () {
      expect(validator('          '), defaults.passwordRequired);
    });

    test('rejects an empty value when required', () {
      expect(validator(null), defaults.passwordRequired);
      expect(validator(''), defaults.passwordRequired);
    });

    test('accepts an empty value but checks a filled one when optional', () {
      final optional = FormValidators.password(isRequired: false);
      expect(optional(''), isNull);
      expect(optional('   '), isNull);
      expect(optional('abc'), defaults.passwordMinLength(8));
    });

    test('uses per-call minLength and messages', () {
      final validator = FormValidators.password(
        minLength: 4,
        requiredMessage: 'Enter your password',
        message: 'Too short',
      );
      expect(validator(''), 'Enter your password');
      expect(validator('abc'), 'Too short');
      expect(validator('abcd'), isNull);
    });

    test('asserts that minLength is not negative', () {
      expect(
        () => FormValidators.password(minLength: -1),
        throwsAssertionError,
      );
    });
  });

  group('strongPassword', () {
    final validator = FormValidators.strongPassword();

    test('accepts a password that meets every rule', () {
      expect(validator('Abcdef1!'), isNull);
      expect(validator('Pass word 9#'), isNull);
    });

    test('checks rules in order and returns the first failure', () {
      expect(validator('abc'), defaults.passwordMinLength(8));
      expect(validator('ABCDEFGH'), defaults.passwordLowercase);
      expect(validator('abcdefgh'), defaults.passwordUppercase);
      expect(validator('Abcdefgh'), defaults.passwordNumber);
      expect(validator('Abcdefg1'), defaults.passwordSpecialCharacter);
    });

    test('does not count whitespace as a special character', () {
      expect(validator('Abcdef 1'), defaults.passwordSpecialCharacter);
    });

    test('checks the raw value and treats only spaces as empty', () {
      expect(validator('        '), defaults.passwordRequired);
      expect(validator(' Abc1!  '), isNull);
    });

    test('rejects an empty value when required', () {
      expect(validator(null), defaults.passwordRequired);
      expect(validator(''), defaults.passwordRequired);
    });

    test('accepts an empty value but checks a filled one when optional', () {
      final optional = FormValidators.strongPassword(isRequired: false);
      expect(optional(''), isNull);
      expect(optional('  '), isNull);
      expect(optional('abcdefgh'), defaults.passwordUppercase);
    });

    test('per-call false overrides rules that require a check', () {
      final validator = FormValidators.strongPassword(
        minLength: 4,
        requireLowercase: false,
        requireUppercase: false,
        requireNumber: false,
        requireSpecialCharacter: false,
      );
      expect(validator('AAAA'), isNull);
      expect(validator('aaaa'), isNull);
      expect(validator('aaa'), defaults.passwordMinLength(4));
    });

    test('per-call true overrides rules that disable a check', () {
      FormValidators.configure(
        rules: const ValidationRules(
          passwordRequireLowercase: false,
          passwordRequireUppercase: false,
          passwordRequireNumber: false,
          passwordRequireSpecialCharacter: false,
        ),
      );
      expect(FormValidators.strongPassword()('aaaaaaaa'), isNull);
      expect(
        FormValidators.strongPassword(requireNumber: true)('aaaaaaaa'),
        defaults.passwordNumber,
      );
      expect(
        FormValidators.strongPassword(requireSpecialCharacter: true)(
          'aaaaaaa1',
        ),
        defaults.passwordSpecialCharacter,
      );
    });

    test('null arguments fall back to the configured rules', () {
      FormValidators.configure(
        rules: const ValidationRules(
          passwordMinLength: 4,
          passwordRequireSpecialCharacter: false,
          specialCharacterPattern: '[#]',
        ),
      );
      expect(validator('Ab1'), defaults.passwordMinLength(4));
      expect(validator('Abc1'), isNull);
      expect(
        FormValidators.strongPassword(requireSpecialCharacter: true)('Abc1!'),
        defaults.passwordSpecialCharacter,
      );
      expect(
        FormValidators.strongPassword(requireSpecialCharacter: true)('Abc1#'),
        isNull,
      );
    });

    test('per-call message replaces every non-empty error', () {
      final validator = FormValidators.strongPassword(
        requiredMessage: 'Choose a password',
        message: 'Too weak',
      );
      expect(validator(''), 'Choose a password');
      expect(validator('abc'), 'Too weak');
      expect(validator('ABCDEFGH'), 'Too weak');
      expect(validator('abcdefgh'), 'Too weak');
      expect(validator('Abcdefgh'), 'Too weak');
      expect(validator('Abcdefg1'), 'Too weak');
      expect(validator('Abcdef1!'), isNull);
    });

    test('asserts that minLength is not negative', () {
      expect(
        () => FormValidators.strongPassword(minLength: -1),
        throwsAssertionError,
      );
    });
  });
}

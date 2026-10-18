import 'package:flutter_test/flutter_test.dart';
import 'package:form_validators/form_validators.dart';

void main() {
  const defaults = ValidationRules();

  test('has the documented defaults', () {
    expect(
      defaults.emailPattern,
      r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
    );
    expect(defaults.phonePattern, r'^\+?[0-9]{7,15}$');
    expect(defaults.passwordMinLength, 8);
    expect(defaults.passwordRequireLowercase, isTrue);
    expect(defaults.passwordRequireUppercase, isTrue);
    expect(defaults.passwordRequireNumber, isTrue);
    expect(defaults.passwordRequireSpecialCharacter, isTrue);
    expect(defaults.specialCharacterPattern, r'[^A-Za-z0-9\s]');
  });

  test('copyWith with no arguments returns an equal copy', () {
    expect(defaults.copyWith(), defaults);
    expect(defaults.copyWith().hashCode, defaults.hashCode);
  });

  test('copyWith replaces only the given fields', () {
    final rules = defaults.copyWith(
      phonePattern: r'^\d{10}$',
      passwordMinLength: 12,
      passwordRequireSpecialCharacter: false,
    );
    expect(rules.phonePattern, r'^\d{10}$');
    expect(rules.passwordMinLength, 12);
    expect(rules.passwordRequireSpecialCharacter, isFalse);

    expect(rules.emailPattern, defaults.emailPattern);
    expect(rules.passwordRequireLowercase, defaults.passwordRequireLowercase);
    expect(rules.passwordRequireUppercase, defaults.passwordRequireUppercase);
    expect(rules.passwordRequireNumber, defaults.passwordRequireNumber);
    expect(rules.specialCharacterPattern, defaults.specialCharacterPattern);
  });

  test('copyWith can replace every field', () {
    final rules = defaults.copyWith(
      emailPattern: 'e',
      phonePattern: 'p',
      passwordMinLength: 1,
      passwordRequireLowercase: false,
      passwordRequireUppercase: false,
      passwordRequireNumber: false,
      passwordRequireSpecialCharacter: false,
      specialCharacterPattern: 's',
    );
    expect(
      rules,
      const ValidationRules(
        emailPattern: 'e',
        phonePattern: 'p',
        passwordMinLength: 1,
        passwordRequireLowercase: false,
        passwordRequireUppercase: false,
        passwordRequireNumber: false,
        passwordRequireSpecialCharacter: false,
        specialCharacterPattern: 's',
      ),
    );
  });

  test('equality compares every field', () {
    expect(defaults, isNot(defaults.copyWith(emailPattern: 'x')));
    expect(defaults, isNot(defaults.copyWith(passwordMinLength: 9)));
    expect(defaults, isNot(defaults.copyWith(passwordRequireNumber: false)));
    expect(defaults, isNot(defaults.copyWith(specialCharacterPattern: 'x')));
  });

  test('asserts that passwordMinLength is not negative', () {
    expect(
      () => defaults.copyWith(passwordMinLength: -1),
      throwsAssertionError,
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  const messages = ValidationMessages();

  test('general defaults', () {
    expect(messages.required, 'This field is required.');
    expect(messages.minLength(3), 'Must be at least 3 characters.');
    expect(messages.minLength(1), 'Must be at least 1 character.');
    expect(messages.maxLength(10), 'Must be at most 10 characters.');
    expect(messages.maxLength(1), 'Must be at most 1 character.');
    expect(messages.lengthBetween(2, 5), 'Must be between 2 and 5 characters.');
    expect(messages.invalidFormat, 'Invalid format.');
    expect(messages.valuesDoNotMatch, 'Values do not match.');
  });

  test('email and phone defaults', () {
    expect(messages.emailRequired, 'Email is required.');
    expect(messages.invalidEmail, 'Enter a valid email address.');
    expect(messages.phoneRequired, 'Phone number is required.');
    expect(messages.invalidPhone, 'Enter a valid phone number.');
    expect(messages.emailOrPhoneRequired, 'Email or phone number is required.');
    expect(
      messages.invalidEmailOrPhone,
      'Enter a valid email address or phone number.',
    );
  });

  test('password defaults', () {
    expect(messages.passwordRequired, 'Password is required.');
    expect(
      messages.passwordMinLength(8),
      'Password must be at least 8 characters.',
    );
    expect(
      messages.passwordMinLength(1),
      'Password must be at least 1 character.',
    );
    expect(
      messages.passwordLowercase,
      'Password must contain at least one lowercase letter.',
    );
    expect(
      messages.passwordUppercase,
      'Password must contain at least one uppercase letter.',
    );
    expect(
      messages.passwordNumber,
      'Password must contain at least one number.',
    );
    expect(
      messages.passwordSpecialCharacter,
      'Password must contain at least one special character.',
    );
  });

  test('number defaults', () {
    expect(messages.invalidNumber, 'Enter a valid number.');
    expect(messages.numberMin(18), 'Must be at least 18.');
    expect(messages.numberMin(0.5), 'Must be at least 0.5.');
    expect(messages.numberMax(120), 'Must be at most 120.');
  });

  test('a subclass overrides only what it changes', () {
    const custom = _CustomMessages();
    expect(custom.required, 'Required!');
    expect(custom.minLength(2), 'Min 2');
    expect(custom.invalidEmail, messages.invalidEmail);
    expect(custom.maxLength(4), messages.maxLength(4));
  });
}

class _CustomMessages extends ValidationMessages {
  const _CustomMessages();

  @override
  String get required => 'Required!';

  @override
  String minLength(int min) => 'Min $min';
}

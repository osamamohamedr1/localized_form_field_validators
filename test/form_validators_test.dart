import 'package:flutter_test/flutter_test.dart';
import 'package:form_validators/form_validators.dart';

const _egyptOrSaudiPhone = r'^(010|011|012|015)\d{8}$|^5\d{8}$';

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  group('defaults', () {
    test('start as the built-in messages and rules', () {
      expect(FormValidators.messages, isA<ValidationMessages>());
      expect(FormValidators.messages.required, 'This field is required.');
      expect(FormValidators.rules, const ValidationRules());
    });

    test('return English messages with no configuration', () {
      expect(FormValidators.required()(''), 'This field is required.');
      expect(FormValidators.email()('x'), 'Enter a valid email address.');
      expect(FormValidators.phone()(''), 'Phone number is required.');
      expect(
        FormValidators.emailOrPhone()('!'),
        'Enter a valid email address or phone number.',
      );
      expect(
        FormValidators.password()('abc'),
        'Password must be at least 8 characters.',
      );
      expect(FormValidators.number(max: 5)('6'), 'Must be at most 5.');
      expect(FormValidators.match(() => 'a')('b'), 'Values do not match.');
    });
  });

  group('configure', () {
    test('replaces only the arguments that are passed', () {
      const messages = _OneMessageOverride();
      const rules = ValidationRules(passwordMinLength: 4);

      FormValidators.configure(messages: messages);
      expect(FormValidators.messages, same(messages));
      expect(FormValidators.rules, const ValidationRules());

      FormValidators.configure(rules: rules);
      expect(FormValidators.messages, same(messages));
      expect(FormValidators.rules, same(rules));

      FormValidators.configure();
      expect(FormValidators.messages, same(messages));
      expect(FormValidators.rules, same(rules));
    });

    test('reset restores the defaults', () {
      FormValidators.configure(
        messages: const _OneMessageOverride(),
        rules: const ValidationRules(passwordMinLength: 4),
      );
      FormValidators.reset();
      expect(FormValidators.messages, isNot(isA<_OneMessageOverride>()));
      expect(FormValidators.rules, const ValidationRules());
      expect(FormValidators.email()(''), defaults.emailRequired);
    });
  });

  group('global override', () {
    test('a subclass that overrides one message changes only that one', () {
      FormValidators.configure(messages: const _OneMessageOverride());

      expect(FormValidators.email()('x'), 'Custom invalid email');
      expect(FormValidators.email()(''), defaults.emailRequired);
      expect(FormValidators.required()(''), defaults.required);
      expect(FormValidators.phone()('1'), defaults.invalidPhone);
      expect(
        FormValidators.emailOrPhone()('user@example'),
        'Custom invalid email',
      );
    });

    test('a custom phone pattern applies to phone and emailOrPhone', () {
      FormValidators.configure(
        rules: const ValidationRules().copyWith(
          phonePattern: _egyptOrSaudiPhone,
        ),
      );
      final phone = FormValidators.phone();
      final emailOrPhone = FormValidators.emailOrPhone();

      for (final valid in ['01012345678', '01512345678', '512345678']) {
        expect(phone(valid), isNull, reason: valid);
        expect(emailOrPhone(valid), isNull, reason: valid);
      }
      for (final invalid in ['01312345678', '+201012345678', '412345678']) {
        expect(phone(invalid), defaults.invalidPhone, reason: invalid);
        expect(emailOrPhone(invalid), defaults.invalidPhone, reason: invalid);
      }
    });

    test('a custom email pattern applies to email and emailOrPhone', () {
      FormValidators.configure(
        rules: const ValidationRules(emailPattern: r'@company\.com$'),
      );
      expect(FormValidators.email()('user@gmail.com'), defaults.invalidEmail);
      expect(FormValidators.email()('user@company.com'), isNull);
      expect(FormValidators.emailOrPhone()('user@company.com'), isNull);
    });

    test('a custom password length applies to password', () {
      FormValidators.configure(
        rules: const ValidationRules(passwordMinLength: 12),
      );
      expect(
        FormValidators.password()('abcdefghijk'),
        defaults.passwordMinLength(12),
      );
    });
  });

  group('per-call override', () {
    setUp(() {
      FormValidators.configure(
        messages: const _EveryMessageOverride(),
        rules: const ValidationRules(
          emailPattern: r'@company\.com$',
          passwordMinLength: 12,
        ),
      );
    });

    test('per-call messages beat the global messages', () {
      expect(FormValidators.required()(''), 'global required');
      expect(FormValidators.required(message: 'local')(''), 'local');

      final email = FormValidators.email(
        requiredMessage: 'local required',
        message: 'local invalid',
      );
      expect(email(''), 'local required');
      expect(email('x'), 'local invalid');
      expect(FormValidators.email()(''), 'global email required');
      expect(FormValidators.email()('x'), 'global invalid email');
    });

    test('per-call rules beat the global rules', () {
      expect(FormValidators.email()('user@gmail.com'), 'global invalid email');
      expect(
        FormValidators.email(pattern: r'@gmail\.com$')('user@gmail.com'),
        isNull,
      );

      expect(FormValidators.password()('abcdefgh'), 'global password min 12');
      expect(FormValidators.password(minLength: 8)('abcdefgh'), isNull);
    });
  });

  group('lazy evaluation', () {
    test('configure after building affects existing validators', () {
      final email = FormValidators.email();
      final phone = FormValidators.phone();
      final password = FormValidators.strongPassword();

      expect(email('x'), defaults.invalidEmail);
      expect(phone('512345678'), isNull);
      expect(password('abcdefgh'), defaults.passwordUppercase);

      FormValidators.configure(
        messages: const _OneMessageOverride(),
        rules: const ValidationRules(
          phonePattern: r'^0\d{10}$',
          passwordRequireUppercase: false,
          passwordRequireNumber: false,
          passwordRequireSpecialCharacter: false,
        ),
      );

      expect(email('x'), 'Custom invalid email');
      expect(phone('512345678'), defaults.invalidPhone);
      expect(password('abcdefgh'), isNull);
    });

    test('message getters are read on every validation', () {
      final messages = _LocaleMessages();
      FormValidators.configure(messages: messages);
      final validator = FormValidators.compose([
        FormValidators.required(),
        FormValidators.minLength(3),
      ]);

      expect(validator(''), 'Required');
      expect(validator('ab'), 'At least 3');

      messages.locale = 'ar';
      expect(validator(''), 'مطلوب');
      expect(validator('ab'), '3 على الأقل');
    });
  });
}

class _OneMessageOverride extends ValidationMessages {
  const _OneMessageOverride();

  @override
  String get invalidEmail => 'Custom invalid email';
}

class _EveryMessageOverride extends ValidationMessages {
  const _EveryMessageOverride();

  @override
  String get required => 'global required';

  @override
  String get emailRequired => 'global email required';

  @override
  String get invalidEmail => 'global invalid email';

  @override
  String passwordMinLength(int min) => 'global password min $min';
}

/// Simulates a localization package whose current locale can change at
/// runtime.
class _LocaleMessages extends ValidationMessages {
  String locale = 'en';

  @override
  String get required => locale == 'ar' ? 'مطلوب' : 'Required';

  @override
  String minLength(int min) =>
      locale == 'ar' ? '$min على الأقل' : 'At least $min';
}

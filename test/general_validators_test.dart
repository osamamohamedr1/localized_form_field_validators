import 'package:easy_form_validators/easy_form_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  group('required', () {
    final validator = FormValidators.required();

    test('accepts a non-blank value', () {
      expect(validator('a'), isNull);
      expect(validator('  a  '), isNull);
    });

    test('rejects null, empty and blank values', () {
      expect(validator(null), defaults.required);
      expect(validator(''), defaults.required);
      expect(validator('   '), defaults.required);
      expect(validator('\t\n'), defaults.required);
    });

    test('uses the per-call message', () {
      expect(FormValidators.required(message: 'Name it')(''), 'Name it');
    });
  });

  group('minLength', () {
    final validator = FormValidators.minLength(3);

    test('accepts values at or above the minimum', () {
      expect(validator('abc'), isNull);
      expect(validator('abcd'), isNull);
    });

    test('rejects shorter values', () {
      expect(validator('ab'), defaults.minLength(3));
    });

    test('trims before measuring', () {
      expect(validator('  ab  '), defaults.minLength(3));
      expect(validator('  abc  '), isNull);
    });

    test('treats empty and blank values as valid', () {
      expect(validator(null), isNull);
      expect(validator(''), isNull);
      expect(validator('   '), isNull);
    });

    test('counts an emoji as one character', () {
      expect(FormValidators.minLength(2)('😀'), defaults.minLength(2));
      expect(FormValidators.maxLength(1)('😀'), isNull);
    });

    test('uses the per-call message', () {
      expect(
        FormValidators.minLength(3, message: 'Too short')('a'),
        'Too short',
      );
    });

    test('asserts that min is not negative', () {
      expect(() => FormValidators.minLength(-1), throwsAssertionError);
    });
  });

  group('maxLength', () {
    final validator = FormValidators.maxLength(3);

    test('accepts values at or below the maximum', () {
      expect(validator('a'), isNull);
      expect(validator('abc'), isNull);
    });

    test('rejects longer values', () {
      expect(validator('abcd'), defaults.maxLength(3));
    });

    test('trims before measuring', () {
      expect(validator('  abc  '), isNull);
    });

    test('treats empty values as valid', () {
      expect(validator(null), isNull);
      expect(validator(''), isNull);
    });

    test('uses the per-call message', () {
      expect(
        FormValidators.maxLength(1, message: 'Too long')('ab'),
        'Too long',
      );
    });

    test('asserts that max is not negative', () {
      expect(() => FormValidators.maxLength(-1), throwsAssertionError);
    });
  });

  group('lengthBetween', () {
    final validator = FormValidators.lengthBetween(2, 4);

    test('accepts values within the range, inclusive', () {
      expect(validator('ab'), isNull);
      expect(validator('abc'), isNull);
      expect(validator('abcd'), isNull);
    });

    test('rejects values outside the range', () {
      expect(validator('a'), defaults.lengthBetween(2, 4));
      expect(validator('abcde'), defaults.lengthBetween(2, 4));
    });

    test('trims before measuring', () {
      expect(validator('  a  '), defaults.lengthBetween(2, 4));
      expect(validator('  abcd  '), isNull);
    });

    test('treats empty values as valid', () {
      expect(validator(null), isNull);
      expect(validator('  '), isNull);
    });

    test('uses the per-call message', () {
      expect(FormValidators.lengthBetween(2, 4, message: 'Bad')('a'), 'Bad');
    });

    test('asserts that min <= max and min >= 0', () {
      expect(() => FormValidators.lengthBetween(5, 3), throwsAssertionError);
      expect(() => FormValidators.lengthBetween(-1, 3), throwsAssertionError);
      expect(FormValidators.lengthBetween(3, 3)('abc'), isNull);
    });
  });

  group('pattern', () {
    final validator = FormValidators.pattern(r'^[A-Z]{2}\d{4}$');

    test('accepts a matching value', () {
      expect(validator('AB1234'), isNull);
    });

    test('rejects a value that does not match', () {
      expect(validator('ab1234'), defaults.invalidFormat);
      expect(validator('AB123'), defaults.invalidFormat);
    });

    test('trims before matching', () {
      expect(validator('  AB1234  '), isNull);
    });

    test('treats empty values as valid', () {
      expect(validator(null), isNull);
      expect(validator(''), isNull);
    });

    test('matches anywhere unless the pattern is anchored', () {
      expect(FormValidators.pattern('[0-9]')('abc1'), isNull);
      expect(FormValidators.pattern('[0-9]')('abc'), defaults.invalidFormat);
    });

    test('uses the per-call message', () {
      expect(FormValidators.pattern('^x', message: 'No x')('y'), 'No x');
    });
  });

  group('match', () {
    test('accepts equal values and rejects different ones', () {
      final validator = FormValidators.match(() => 'Secret1!');
      expect(validator('Secret1!'), isNull);
      expect(validator('secret1!'), defaults.valuesDoNotMatch);
    });

    test('reads the other value at validation time', () {
      var other = 'first';
      final validator = FormValidators.match(() => other);
      expect(validator('second'), defaults.valuesDoNotMatch);
      other = 'second';
      expect(validator('second'), isNull);
    });

    test('compares raw values without trimming', () {
      final validator = FormValidators.match(() => 'abc');
      expect(validator(' abc'), defaults.valuesDoNotMatch);
    });

    test('treats null as an empty string', () {
      expect(FormValidators.match(() => null)(''), isNull);
      expect(FormValidators.match(() => '')(null), isNull);
      expect(FormValidators.match(() => 'a')(null), defaults.valuesDoNotMatch);
    });

    test('uses the per-call message', () {
      final validator = FormValidators.match(() => 'a', message: 'Differs');
      expect(validator('b'), 'Differs');
    });
  });

  group('compose', () {
    test('returns the first error in order', () {
      final validator = FormValidators.compose([
        FormValidators.required(message: 'first'),
        FormValidators.minLength(3, message: 'second'),
        FormValidators.pattern(r'^[a-z]+$', message: 'third'),
      ]);
      expect(validator(''), 'first');
      expect(validator('A'), 'second');
      expect(validator('ABC'), 'third');
      expect(validator('abc'), isNull);
    });

    test('stops at the first error', () {
      var laterCalls = 0;
      final validator = FormValidators.compose([
        (_) => 'error',
        (_) {
          laterCalls++;
          return null;
        },
      ]);
      expect(validator('x'), 'error');
      expect(laterCalls, 0);
    });

    test('skips null entries', () {
      final validator = FormValidators.compose([
        null,
        FormValidators.required(),
        null,
      ]);
      expect(validator(''), defaults.required);
      expect(validator('a'), isNull);
    });

    test('passes when the list is empty', () {
      expect(FormValidators.compose([])('anything'), isNull);
    });

    test('is not affected by later changes to the list', () {
      final validators = <String? Function(String?)?>[
        FormValidators.required(),
      ];
      final validator = FormValidators.compose(validators);
      validators.add((_) => 'added later');
      expect(validator('a'), isNull);
    });
  });
}

import 'package:easy_form_validators/easy_form_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  group('number', () {
    final validator = FormValidators.number();

    test('accepts integers and decimals', () {
      expect(validator('42'), isNull);
      expect(validator('-7'), isNull);
      expect(validator('3.14'), isNull);
      expect(validator('0'), isNull);
    });

    test('rejects values that are not numbers', () {
      expect(validator('abc'), defaults.invalidNumber);
      expect(validator('12abc'), defaults.invalidNumber);
      expect(validator('1,5'), defaults.invalidNumber);
      expect(validator('1 000'), defaults.invalidNumber);
    });

    test('rejects NaN and infinity', () {
      expect(validator('NaN'), defaults.invalidNumber);
      expect(validator('Infinity'), defaults.invalidNumber);
      expect(validator('-Infinity'), defaults.invalidNumber);
    });

    test('trims before parsing', () {
      expect(validator('  42  '), isNull);
    });

    test('rejects an empty value when required', () {
      expect(validator(null), defaults.required);
      expect(validator('  '), defaults.required);
    });

    test('accepts an empty value but checks a filled one when optional', () {
      final optional = FormValidators.number(isRequired: false);
      expect(optional(''), isNull);
      expect(optional('abc'), defaults.invalidNumber);
    });

    test('rejects decimals when allowDecimal is false', () {
      final whole = FormValidators.number(allowDecimal: false);
      expect(whole('42'), isNull);
      expect(whole('-3'), isNull);
      expect(whole('3.5'), defaults.invalidNumber);
      expect(whole('5.0'), defaults.invalidNumber);
      expect(whole('1e3'), defaults.invalidNumber);
    });

    test('checks min and max inclusively', () {
      final ranged = FormValidators.number(min: 18, max: 120);
      expect(ranged('18'), isNull);
      expect(ranged('120'), isNull);
      expect(ranged('17.9'), defaults.numberMin(18));
      expect(ranged('121'), defaults.numberMax(120));
    });

    test('supports decimal bounds', () {
      final ranged = FormValidators.number(min: 0.5, max: 1.5);
      expect(ranged('1'), isNull);
      expect(ranged('0.4'), defaults.numberMin(0.5));
      expect(ranged('1.6'), defaults.numberMax(1.5));
    });

    test('per-call messages replace the defaults', () {
      final validator = FormValidators.number(
        min: 1,
        max: 10,
        requiredMessage: 'Enter a quantity',
        message: 'Choose 1 to 10',
      );
      expect(validator(''), 'Enter a quantity');
      expect(validator('x'), 'Choose 1 to 10');
      expect(validator('0'), 'Choose 1 to 10');
      expect(validator('11'), 'Choose 1 to 10');
      expect(validator('5'), isNull);
    });

    test('asserts that min <= max', () {
      expect(
        () => FormValidators.number(min: 10, max: 1),
        throwsAssertionError,
      );
      expect(FormValidators.number(min: 5, max: 5)('5'), isNull);
    });
  });
}

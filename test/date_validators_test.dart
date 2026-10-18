import 'package:flutter/widgets.dart' show FormFieldValidator;
import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

/// Today at noon, shifted by [days], so tests don't depend on the time.
DateTime _day(int days) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + days, 12);
}

/// A birth date exactly [years] years ago, shifted by [days].
DateTime _yearsAgo(int years, {int days = 0}) {
  final now = DateTime.now();
  return DateTime(now.year - years, now.month, now.day + days);
}

void main() {
  const defaults = ValidationMessages();

  tearDown(FormValidators.reset);

  group('futureDate', () {
    final validator = FormValidators.futureDate();

    test('accepts a date after today', () {
      expect(validator(_day(1)), isNull);
      expect(validator(_day(400)), isNull);
    });

    test('rejects today and past dates', () {
      expect(validator(_day(0)), defaults.dateMustBeFuture);
      expect(validator(DateTime.now()), defaults.dateMustBeFuture);
      expect(validator(_day(-1)), defaults.dateMustBeFuture);
    });

    test('accepts today with allowToday', () {
      final validator = FormValidators.futureDate(allowToday: true);
      expect(validator(_day(0)), isNull);
      expect(validator(_day(-1)), defaults.dateMustBeFuture);
    });

    test('ignores the time of day', () {
      final now = DateTime.now();
      final lateToday = DateTime(now.year, now.month, now.day, 23, 59);
      final earlyTomorrow = DateTime(now.year, now.month, now.day + 1);
      expect(validator(lateToday), defaults.dateMustBeFuture);
      expect(validator(earlyTomorrow), isNull);
    });

    test('handles a null date', () {
      expect(validator(null), defaults.dateRequired);
      expect(FormValidators.futureDate(isRequired: false)(null), isNull);
    });

    test('uses per-call messages', () {
      final validator = FormValidators.futureDate(
        requiredMessage: 'Pick the expiry date',
        message: 'This ID has expired',
      );
      expect(validator(null), 'Pick the expiry date');
      expect(validator(_day(-1)), 'This ID has expired');
    });
  });

  group('pastDate', () {
    final validator = FormValidators.pastDate();

    test('accepts past dates and today', () {
      expect(validator(_day(-1)), isNull);
      expect(validator(_day(0)), isNull);
    });

    test('rejects future dates', () {
      expect(validator(_day(1)), defaults.dateMustBePast);
    });

    test('rejects today when allowToday is false', () {
      final validator = FormValidators.pastDate(allowToday: false);
      expect(validator(_day(0)), defaults.dateMustBePast);
      expect(validator(_day(-1)), isNull);
    });

    test('handles a null date', () {
      expect(validator(null), defaults.dateRequired);
      expect(FormValidators.pastDate(isRequired: false)(null), isNull);
    });
  });

  group('age', () {
    test('accepts an age on the exact birthday', () {
      final validator = FormValidators.age(min: 18);
      expect(validator(_yearsAgo(18)), isNull);
      expect(validator(_yearsAgo(30)), isNull);
    });

    test('rejects the day before the birthday', () {
      final validator = FormValidators.age(min: 18);
      expect(validator(_yearsAgo(18, days: 1)), defaults.ageMin(18));
      expect(validator(_yearsAgo(10)), defaults.ageMin(18));
    });

    test('checks the maximum age', () {
      final validator = FormValidators.age(max: 120);
      expect(validator(_yearsAgo(120)), isNull);
      expect(validator(_yearsAgo(121)), defaults.ageMax(120));
      expect(validator(_yearsAgo(121, days: 1)), isNull);
    });

    test('rejects a birth date in the future', () {
      expect(FormValidators.age(min: 0)(_day(1)), defaults.dateMustBePast);
      expect(FormValidators.age(max: 5)(_day(1)), defaults.dateMustBePast);
      expect(FormValidators.age()(_day(0)), isNull);
    });

    test('handles a null date and per-call messages', () {
      expect(FormValidators.age(min: 18)(null), defaults.dateRequired);
      expect(FormValidators.age(min: 18, isRequired: false)(null), isNull);
      final validator = FormValidators.age(
        min: 18,
        requiredMessage: 'Birth date?',
        message: 'Adults only',
      );
      expect(validator(null), 'Birth date?');
      expect(validator(_yearsAgo(10)), 'Adults only');
      expect(validator(_day(1)), 'Adults only');
    });

    test('asserts valid bounds', () {
      expect(() => FormValidators.age(min: -1), throwsAssertionError);
      expect(() => FormValidators.age(min: 30, max: 18), throwsAssertionError);
    });
  });

  test('compose works with date validators', () {
    final FormFieldValidator<DateTime> validator = FormValidators.compose([
      FormValidators.pastDate(),
      FormValidators.age(min: 18),
    ]);
    expect(validator(null), defaults.dateRequired);
    expect(validator(_day(1)), defaults.dateMustBePast);
    expect(validator(_yearsAgo(10)), defaults.ageMin(18));
    expect(validator(_yearsAgo(20)), isNull);
  });

  test('uses Arabic messages when configured', () {
    FormValidators.configure(languageCode: 'ar');
    expect(FormValidators.futureDate()(null), 'اختر تاريخًا.');
    expect(
      FormValidators.futureDate()(_day(-1)),
      'يجب أن يكون التاريخ في المستقبل.',
    );
    expect(
      FormValidators.age(min: 18)(_yearsAgo(10)),
      'يجب ألا يقل العمر عن 18 سنة.',
    );
  });
}

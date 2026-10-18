import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  tearDown(FormValidators.reset);

  test('fromCode finds countries by alpha-2 or alpha-3 code', () {
    expect(ArabCountry.fromCode('EG'), ArabCountry.egypt);
    expect(ArabCountry.fromCode('EGY'), ArabCountry.egypt);
    expect(ArabCountry.fromCode(' eg '), ArabCountry.egypt);
    expect(ArabCountry.fromCode('sau'), ArabCountry.saudiArabia);
    expect(ArabCountry.fromCode('AE'), ArabCountry.uae);
    expect(ArabCountry.fromCode('ARE'), ArabCountry.uae);
    expect(ArabCountry.fromCode('US'), isNull);
    expect(ArabCountry.fromCode(''), isNull);
  });

  test('every country has unique, well-formed codes', () {
    final codes = <String>{};
    for (final country in ArabCountry.values) {
      expect(country.isoCode, matches(RegExp(r'^[A-Z]{2}$')));
      expect(country.isoCode3, matches(RegExp(r'^[A-Z]{3}$')));
      expect(country.dialCode, matches(RegExp(r'^\+\d{2,3}$')));
      expect(codes.add(country.isoCode), isTrue, reason: country.isoCode);
      expect(codes.add(country.isoCode3), isTrue, reason: country.isoCode3);
      expect(ArabCountry.fromCode(country.isoCode), country);
      expect(ArabCountry.fromCode(country.isoCode3), country);
      expect(() => RegExp(country.phonePattern), returnsNormally);
    }
  });

  test('lists which countries have national ID rules', () {
    final withoutRules = ArabCountry.values
        .where((country) => !country.hasNationalIdRules)
        .toSet();
    expect(withoutRules, {
      ArabCountry.lebanon,
      ArabCountry.oman,
      ArabCountry.sudan,
      ArabCountry.yemen,
    });
    expect(ArabCountry.oman.isValidNationalId('anything'), isTrue);
    expect(ArabCountry.egypt.isValidNationalId('123'), isFalse);
  });

  test('phonePattern matches the PhonePatterns constant', () {
    expect(ArabCountry.egypt.phonePattern, PhonePatterns.egypt);
    expect(ArabCountry.qatar.phonePattern, PhonePatterns.qatar);
    expect(
      FormValidators.phone(pattern: ArabCountry.fromCode('JO')?.phonePattern)(
        '0791234567',
      ),
      isNull,
    );
  });
}

import 'national_ids.dart';
import 'phone_patterns.dart';

/// Arab countries with built-in phone patterns and, for most, national ID
/// rules.
///
/// Use a country with `FormValidators.phone` and `FormValidators.nationalId`:
///
/// ```dart
/// FormValidators.phone(pattern: ArabCountry.egypt.phonePattern);
/// FormValidators.nationalId(ArabCountry.egypt);
/// ```
///
/// When the country comes from your backend or a country picker, look it up
/// by ISO code:
///
/// ```dart
/// final country = ArabCountry.fromCode(user.nationality); // 'EG' or 'EGY'
/// FormValidators.nationalId(country);
/// ```
enum ArabCountry {
  /// Algeria (`DZ`, `+213`). National ID: 18-digit NIN.
  algeria('DZ', 'DZA', '+213', PhonePatterns.algeria, isValidAlgeriaNationalId),

  /// Bahrain (`BH`, `+973`). National ID: 9-digit CPR with a valid birth
  /// month.
  bahrain('BH', 'BHR', '+973', PhonePatterns.bahrain, isValidBahrainNationalId),

  /// Egypt (`EG`, `+20`). National ID: 14 digits with century, birth date
  /// and governorate checks.
  egypt('EG', 'EGY', '+20', PhonePatterns.egypt, isValidEgyptianNationalId),

  /// Iraq (`IQ`, `+964`). National ID: 12-digit unified national card.
  iraq('IQ', 'IRQ', '+964', PhonePatterns.iraq, isValidIraqNationalId),

  /// Jordan (`JO`, `+962`). National ID: 10-digit national number.
  jordan('JO', 'JOR', '+962', PhonePatterns.jordan, isValidJordanNationalId),

  /// Kuwait (`KW`, `+965`). National ID: 12-digit civil ID with birth date
  /// and check digit.
  kuwait('KW', 'KWT', '+965', PhonePatterns.kuwait, isValidKuwaitNationalId),

  /// Lebanon (`LB`, `+961`). No national ID rules.
  lebanon('LB', 'LBN', '+961', PhonePatterns.lebanon, null),

  /// Libya (`LY`, `+218`). National ID: 12-digit national number with a
  /// birth year.
  libya('LY', 'LBY', '+218', PhonePatterns.libya, isValidLibyaNationalId),

  /// Morocco (`MA`, `+212`). National ID: CIN of one or two letters and up
  /// to 6 digits.
  morocco('MA', 'MAR', '+212', PhonePatterns.morocco, isValidMoroccoNationalId),

  /// Oman (`OM`, `+968`). No national ID rules.
  oman('OM', 'OMN', '+968', PhonePatterns.oman, null),

  /// Palestine (`PS`, `+970`). National ID: 9 digits with a check digit.
  palestine(
    'PS',
    'PSE',
    '+970',
    PhonePatterns.palestine,
    isValidPalestineNationalId,
  ),

  /// Qatar (`QA`, `+974`). National ID: 11-digit QID with birth year and
  /// nationality code.
  qatar('QA', 'QAT', '+974', PhonePatterns.qatar, isValidQatarNationalId),

  /// Saudi Arabia (`SA`, `+966`). National ID: 10-digit national ID or Iqama
  /// with a check digit.
  saudiArabia(
    'SA',
    'SAU',
    '+966',
    PhonePatterns.saudiArabia,
    isValidSaudiNationalId,
  ),

  /// Sudan (`SD`, `+249`). No national ID rules.
  sudan('SD', 'SDN', '+249', PhonePatterns.sudan, null),

  /// Syria (`SY`, `+963`). National ID: 11-digit national number.
  syria('SY', 'SYR', '+963', PhonePatterns.syria, isValidSyriaNationalId),

  /// Tunisia (`TN`, `+216`). National ID: 8-digit CIN.
  tunisia('TN', 'TUN', '+216', PhonePatterns.tunisia, isValidTunisiaNationalId),

  /// United Arab Emirates (`AE`, `+971`). National ID: 15-digit Emirates ID
  /// starting with `784`, with birth year and check digit.
  uae('AE', 'ARE', '+971', PhonePatterns.uae, isValidUaeNationalId),

  /// Yemen (`YE`, `+967`). No national ID rules.
  yemen('YE', 'YEM', '+967', PhonePatterns.yemen, null);

  const ArabCountry(
    this.isoCode,
    this.isoCode3,
    this.dialCode,
    this.phonePattern,
    this._nationalIdRule,
  );

  /// The ISO 3166-1 alpha-2 code, for example `EG`.
  final String isoCode;

  /// The ISO 3166-1 alpha-3 code, for example `EGY`.
  final String isoCode3;

  /// The international dialing code, for example `+20`.
  final String dialCode;

  /// The mobile phone pattern from [PhonePatterns], matching the number
  /// without [dialCode].
  final String phonePattern;

  final bool Function(String id)? _nationalIdRule;

  /// Whether `FormValidators.nationalId` checks the format of this
  /// country's national ID. For other countries it only checks that a value
  /// is present.
  bool get hasNationalIdRules => _nationalIdRule != null;

  /// Whether [id] is a valid national ID for this country, or `true` when
  /// the country has no national ID rules. [id] is checked as given; spaces
  /// and dashes are not removed.
  bool isValidNationalId(String id) => _nationalIdRule?.call(id) ?? true;

  /// Returns the country with ISO alpha-2 or alpha-3 [code], ignoring case
  /// and surrounding whitespace, or null when no country matches.
  ///
  /// ```dart
  /// ArabCountry.fromCode('eg'); // ArabCountry.egypt
  /// ArabCountry.fromCode('SAU'); // ArabCountry.saudiArabia
  /// ArabCountry.fromCode('US'); // null
  /// ```
  static ArabCountry? fromCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final country in values) {
      if (country.isoCode == normalized || country.isoCode3 == normalized) {
        return country;
      }
    }
    return null;
  }
}

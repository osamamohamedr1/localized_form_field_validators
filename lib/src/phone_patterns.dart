/// Ready-made mobile phone patterns for Arab countries.
///
/// Use one with `FormValidators.phone` or as `ValidationRules.phonePattern`:
///
/// ```dart
/// FormValidators.phone(pattern: PhonePatterns.egypt);
///
/// FormValidators.configure(
///   rules: FormValidators.rules.copyWith(
///     phonePattern: PhonePatterns.anyOf([
///       PhonePatterns.egypt,
///       PhonePatterns.saudiArabia,
///     ]),
///   ),
/// );
/// ```
///
/// Each pattern matches the number **without** the country code, as typed
/// after choosing the country code in a picker or when dialing locally. Where
/// a country uses a leading trunk `0`, it is optional. Spaces, dashes and a
/// `+` country prefix are not accepted. To look a pattern up by ISO country
/// code, use `ArabCountry.fromCode(code)?.phonePattern`.
abstract final class PhonePatterns {
  // Gulf ----------------------------------------------------------------------

  /// Bahraini mobile numbers: 8 digits starting with `3` or `6`, for example
  /// `36123456`.
  static const String bahrain = r'^[36]\d{7}$';

  /// Kuwaiti mobile numbers: 8 digits starting with `4`, `5`, `6` or `9`,
  /// for example `51234567`.
  static const String kuwait = r'^[4569]\d{7}$';

  /// Omani mobile numbers: 8 digits starting with `7` or `9`, for example
  /// `91234567`.
  static const String oman = r'^[79]\d{7}$';

  /// Qatari mobile numbers: 8 digits starting with `3`, `5`, `6` or `7`, for
  /// example `55123456`.
  static const String qatar = r'^[3567]\d{7}$';

  /// Saudi mobile numbers: `5` followed by 8 digits, with an optional leading
  /// `0`, for example `512345678` or `0512345678`.
  static const String saudiArabia = r'^0?5\d{8}$';

  /// United Arab Emirates mobile numbers: `5` followed by 8 digits, with an
  /// optional leading `0`, for example `501234567` or `0501234567`.
  static const String uae = r'^0?5\d{8}$';

  /// Yemeni mobile numbers: `70`, `71`, `73`, `77` or `78` followed by 7
  /// digits, with an optional leading `0`, for example `771234567`.
  static const String yemen = r'^0?7[01378]\d{7}$';

  // Levant and Iraq -----------------------------------------------------------

  /// Iraqi mobile numbers: `73` to `79` followed by 8 digits, with an
  /// optional leading `0`, for example `07701234567`.
  static const String iraq = r'^0?7[3-9]\d{8}$';

  /// Jordanian mobile numbers: `77`, `78` or `79` followed by 7 digits, with
  /// an optional leading `0`, for example `0791234567`.
  static const String jordan = r'^0?7[789]\d{7}$';

  /// Lebanese mobile numbers: `3` followed by 6 digits (optional leading
  /// `0`), or `70`, `71`, `76`, `78`, `79` or `81` followed by 6 digits, for
  /// example `03123456` or `71123456`.
  static const String lebanon = r'^(?:0?3\d{6}|(?:7[01689]|81)\d{6})$';

  /// Palestinian mobile numbers: `56` or `59` followed by 7 digits, with an
  /// optional leading `0`, for example `0591234567`.
  static const String palestine = r'^0?5[69]\d{7}$';

  /// Syrian mobile numbers: `9` followed by 8 digits, with an optional
  /// leading `0`, for example `0931234567`.
  static const String syria = r'^0?9\d{8}$';

  // Egypt, Sudan and North Africa ---------------------------------------------

  /// Algerian mobile numbers: `5`, `6` or `7` followed by 8 digits, with an
  /// optional leading `0`, for example `0551234567`.
  static const String algeria = r'^0?[567]\d{8}$';

  /// Egyptian mobile numbers: `10`, `11`, `12` or `15` followed by 8 digits,
  /// with an optional leading `0`, for example `01012345678`.
  static const String egypt = r'^0?1[0125]\d{8}$';

  /// Libyan mobile numbers: `91` to `95` followed by 7 digits, with an
  /// optional leading `0`, for example `0911234567`.
  static const String libya = r'^0?9[1-5]\d{7}$';

  /// Moroccan mobile numbers: `6` or `7` followed by 8 digits, with an
  /// optional leading `0`, for example `0612345678`.
  static const String morocco = r'^0?[67]\d{8}$';

  /// Sudanese mobile numbers: `9x`, `11` or `12` followed by 7 digits, with
  /// an optional leading `0`, for example `0912345678`.
  static const String sudan = r'^0?(?:9\d|1[12])\d{7}$';

  /// Tunisian mobile numbers: 8 digits starting with `2`, `4`, `5` or `9`,
  /// for example `20123456`.
  static const String tunisia = r'^[2459]\d{7}$';

  /// Combines [patterns] into one pattern that matches a value when any of
  /// them does.
  ///
  /// [patterns] must not be empty.
  static String anyOf(List<String> patterns) {
    assert(patterns.isNotEmpty, 'patterns must not be empty');
    return patterns.map((pattern) => '(?:$pattern)').join('|');
  }
}

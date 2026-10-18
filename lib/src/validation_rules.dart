import 'package:flutter/foundation.dart';

import 'arab_country.dart';
import 'password_check.dart';

/// The rules the validators in `FormValidators` check against, such as the
/// email and phone patterns and the password policy.
///
/// Every field has a sensible default. To change rules for the whole app,
/// copy the defaults with [copyWith] and register the result once with
/// `FormValidators.configure`:
///
/// ```dart
/// FormValidators.configure(
///   rules: const ValidationRules().copyWith(
///     phonePattern: r'^(010|011|012|015)\d{8}$|^5\d{8}$',
///     passwordMinLength: 10,
///   ),
/// );
/// ```
///
/// Patterns are stored as `String` so this class can stay `const`. They are
/// compiled to `RegExp` each time a validator runs, and matched with
/// `RegExp.hasMatch`, so anchor them with `^` and `$` to match the whole
/// value.
@immutable
class ValidationRules {
  /// Creates a set of rules. Every argument has a default, so
  /// `const ValidationRules()` gives the built-in rules.
  ///
  /// [passwordMinLength] must not be negative.
  const ValidationRules({
    this.emailPattern =
        r'^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$',
    this.phonePattern = r'^\+?[0-9]{7,15}$',
    this.passwordMinLength = 8,
    this.passwordRequireLowercase = true,
    this.passwordRequireUppercase = true,
    this.passwordRequireNumber = true,
    this.passwordRequireSpecialCharacter = true,
    this.passwordLowercasePattern = '[a-z]',
    this.passwordUppercasePattern = '[A-Z]',
    this.passwordNumberPattern = '[0-9]',
    this.specialCharacterPattern = r'[^A-Za-z0-9\s]',
    this.passwordCheckOrder = PasswordCheck.values,
    this.passportPattern = r'^[A-Za-z0-9]{6,9}$',
    this.nationalIdRules = const {},
    this.normalizeDigits = true,
  }) : assert(passwordMinLength >= 0, 'passwordMinLength must be >= 0');

  /// The pattern a valid email address must match.
  ///
  /// Default: `^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$`
  final String emailPattern;

  /// The pattern a valid phone number must match. Input is trimmed, and
  /// Arabic digits are converted when [normalizeDigits] is `true`, so allow
  /// separators such as spaces in the pattern if you want to accept them.
  ///
  /// Default: `^\+?[0-9]{7,15}$` (7 to 15 digits with an optional leading
  /// `+`). See `PhonePatterns` and `ArabCountry` for country patterns.
  final String phonePattern;

  /// The minimum number of characters in a password. Used by both
  /// `FormValidators.password` and `FormValidators.strongPassword`.
  ///
  /// Default: `8`.
  final int passwordMinLength;

  /// Whether `FormValidators.strongPassword` requires a character matching
  /// [passwordLowercasePattern].
  ///
  /// Default: `true`.
  final bool passwordRequireLowercase;

  /// Whether `FormValidators.strongPassword` requires a character matching
  /// [passwordUppercasePattern].
  ///
  /// Default: `true`.
  final bool passwordRequireUppercase;

  /// Whether `FormValidators.strongPassword` requires a character matching
  /// [passwordNumberPattern].
  ///
  /// Default: `true`.
  final bool passwordRequireNumber;

  /// Whether `FormValidators.strongPassword` requires a character matching
  /// [specialCharacterPattern].
  ///
  /// Default: `true`.
  final bool passwordRequireSpecialCharacter;

  /// What counts as a lowercase letter in a password.
  ///
  /// Default: `[a-z]`.
  final String passwordLowercasePattern;

  /// What counts as an uppercase letter in a password.
  ///
  /// Default: `[A-Z]`.
  final String passwordUppercasePattern;

  /// What counts as a number in a password.
  ///
  /// Default: `[0-9]`.
  final String passwordNumberPattern;

  /// What counts as a special character in a password.
  ///
  /// Default: `[^A-Za-z0-9\s]` (anything except ASCII letters, digits and
  /// whitespace).
  final String specialCharacterPattern;

  /// The order `FormValidators.strongPassword` runs its checks in; it
  /// returns the first failure. Must list every [PasswordCheck] exactly
  /// once.
  ///
  /// Default: [PasswordCheck.values], that is minimum length, lowercase,
  /// uppercase, number, then special character.
  final List<PasswordCheck> passwordCheckOrder;

  /// The pattern a valid passport number must match, used by
  /// `FormValidators.passport`.
  ///
  /// Default: `^[A-Za-z0-9]{6,9}$` (6 to 9 letters or digits).
  final String passportPattern;

  /// National ID rules that replace or add to the built-in ones, by
  /// country. Each function receives the trimmed ID with spaces and dashes
  /// removed and returns whether it is valid.
  ///
  /// ```dart
  /// bool kuwaitCivilId(String id) => RegExp(r'^\d{12}$').hasMatch(id);
  ///
  /// const ValidationRules(nationalIdRules: {ArabCountry.kuwait: kuwaitCivilId});
  /// ```
  ///
  /// Default: empty, so the built-in rules are used.
  final Map<ArabCountry, bool Function(String id)> nationalIdRules;

  /// Whether Arabic-Indic (`٠١٢٣٤٥٦٧٨٩`) and Persian (`۰۱۲۳۴۵۶۷۸۹`) digits
  /// are converted to `0`–`9` before checking phone numbers, numbers,
  /// national IDs, passports and IBANs.
  ///
  /// The validators only check the converted value; convert the value you
  /// store or send with `FormValidators.normalizeDigits`.
  ///
  /// Default: `true`.
  final bool normalizeDigits;

  /// Returns a copy of these rules with the given fields replaced.
  ///
  /// ```dart
  /// final rules = FormValidators.rules.copyWith(passwordMinLength: 12);
  /// ```
  ValidationRules copyWith({
    String? emailPattern,
    String? phonePattern,
    int? passwordMinLength,
    bool? passwordRequireLowercase,
    bool? passwordRequireUppercase,
    bool? passwordRequireNumber,
    bool? passwordRequireSpecialCharacter,
    String? passwordLowercasePattern,
    String? passwordUppercasePattern,
    String? passwordNumberPattern,
    String? specialCharacterPattern,
    List<PasswordCheck>? passwordCheckOrder,
    String? passportPattern,
    Map<ArabCountry, bool Function(String id)>? nationalIdRules,
    bool? normalizeDigits,
  }) {
    return ValidationRules(
      emailPattern: emailPattern ?? this.emailPattern,
      phonePattern: phonePattern ?? this.phonePattern,
      passwordMinLength: passwordMinLength ?? this.passwordMinLength,
      passwordRequireLowercase:
          passwordRequireLowercase ?? this.passwordRequireLowercase,
      passwordRequireUppercase:
          passwordRequireUppercase ?? this.passwordRequireUppercase,
      passwordRequireNumber:
          passwordRequireNumber ?? this.passwordRequireNumber,
      passwordRequireSpecialCharacter:
          passwordRequireSpecialCharacter ??
          this.passwordRequireSpecialCharacter,
      passwordLowercasePattern:
          passwordLowercasePattern ?? this.passwordLowercasePattern,
      passwordUppercasePattern:
          passwordUppercasePattern ?? this.passwordUppercasePattern,
      passwordNumberPattern:
          passwordNumberPattern ?? this.passwordNumberPattern,
      specialCharacterPattern:
          specialCharacterPattern ?? this.specialCharacterPattern,
      passwordCheckOrder: passwordCheckOrder ?? this.passwordCheckOrder,
      passportPattern: passportPattern ?? this.passportPattern,
      nationalIdRules: nationalIdRules ?? this.nationalIdRules,
      normalizeDigits: normalizeDigits ?? this.normalizeDigits,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ValidationRules &&
        other.emailPattern == emailPattern &&
        other.phonePattern == phonePattern &&
        other.passwordMinLength == passwordMinLength &&
        other.passwordRequireLowercase == passwordRequireLowercase &&
        other.passwordRequireUppercase == passwordRequireUppercase &&
        other.passwordRequireNumber == passwordRequireNumber &&
        other.passwordRequireSpecialCharacter ==
            passwordRequireSpecialCharacter &&
        other.passwordLowercasePattern == passwordLowercasePattern &&
        other.passwordUppercasePattern == passwordUppercasePattern &&
        other.passwordNumberPattern == passwordNumberPattern &&
        other.specialCharacterPattern == specialCharacterPattern &&
        listEquals(other.passwordCheckOrder, passwordCheckOrder) &&
        other.passportPattern == passportPattern &&
        mapEquals(other.nationalIdRules, nationalIdRules) &&
        other.normalizeDigits == normalizeDigits;
  }

  @override
  int get hashCode => Object.hash(
    emailPattern,
    phonePattern,
    passwordMinLength,
    passwordRequireLowercase,
    passwordRequireUppercase,
    passwordRequireNumber,
    passwordRequireSpecialCharacter,
    passwordLowercasePattern,
    passwordUppercasePattern,
    passwordNumberPattern,
    specialCharacterPattern,
    Object.hashAll(passwordCheckOrder),
    passportPattern,
    Object.hashAllUnordered(
      nationalIdRules.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
    normalizeDigits,
  );
}

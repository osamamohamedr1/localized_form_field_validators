import 'package:flutter/foundation.dart';

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
    this.specialCharacterPattern = r'[^A-Za-z0-9\s]',
  }) : assert(passwordMinLength >= 0, 'passwordMinLength must be >= 0');

  /// The pattern a valid email address must match.
  ///
  /// Default: `^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$`
  final String emailPattern;

  /// The pattern a valid phone number must match. Input is trimmed but not
  /// otherwise normalized, so allow separators such as spaces in the pattern
  /// if you want to accept them.
  ///
  /// Default: `^\+?[0-9]{7,15}$` (7 to 15 digits with an optional leading
  /// `+`).
  final String phonePattern;

  /// The minimum number of characters in a password. Used by both
  /// `FormValidators.password` and `FormValidators.strongPassword`.
  ///
  /// Default: `8`.
  final int passwordMinLength;

  /// Whether `FormValidators.strongPassword` requires a lowercase letter
  /// (`a` to `z`).
  ///
  /// Default: `true`.
  final bool passwordRequireLowercase;

  /// Whether `FormValidators.strongPassword` requires an uppercase letter
  /// (`A` to `Z`).
  ///
  /// Default: `true`.
  final bool passwordRequireUppercase;

  /// Whether `FormValidators.strongPassword` requires a digit (`0` to `9`).
  ///
  /// Default: `true`.
  final bool passwordRequireNumber;

  /// Whether `FormValidators.strongPassword` requires a character that
  /// matches [specialCharacterPattern].
  ///
  /// Default: `true`.
  final bool passwordRequireSpecialCharacter;

  /// The pattern a password must contain at least one match of when
  /// [passwordRequireSpecialCharacter] is `true`.
  ///
  /// Default: `[^A-Za-z0-9\s]` (anything except ASCII letters, digits and
  /// whitespace).
  final String specialCharacterPattern;

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
    String? specialCharacterPattern,
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
      specialCharacterPattern:
          specialCharacterPattern ?? this.specialCharacterPattern,
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
        other.specialCharacterPattern == specialCharacterPattern;
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
    specialCharacterPattern,
  );
}

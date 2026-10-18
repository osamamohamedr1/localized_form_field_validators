import 'package:flutter/widgets.dart' show FormFieldValidator;

import 'validation_messages.dart';
import 'validation_rules.dart';

/// Builders for `TextFormField` validators, plus the app-wide configuration
/// they read from.
///
/// Every builder returns a `FormFieldValidator<String>` that plugs straight
/// into a form field:
///
/// ```dart
/// TextFormField(validator: FormValidators.email());
/// ```
///
/// ## Overrides
///
/// Messages and rules are resolved in this order:
///
/// 1. A per-call argument, such as `message`, `requiredMessage` or `pattern`.
/// 2. The global configuration set with [configure].
/// 3. The built-in defaults in [ValidationMessages] and [ValidationRules].
///
/// The returned validators read [messages] and [rules] each time they run,
/// not when they are built, so [configure] also affects validators that
/// already exist.
///
/// ## Common parameters
///
/// - `isRequired`: when `false`, an empty value is valid, but a value that is
///   filled in is still checked.
/// - `requiredMessage`: replaces the error for an empty value.
/// - `message`: replaces every other error the validator can return.
///
/// Input is trimmed before it is checked, except by [password] and
/// [strongPassword], which check the raw value and treat a value of only
/// whitespace as empty.
abstract final class FormValidators {
  static ValidationMessages _messages = const ValidationMessages();
  static ValidationRules _rules = const ValidationRules();

  static final RegExp _letter = RegExp(r'\p{L}', unicode: true);
  static final RegExp _digitsOnly = RegExp(r'^\+?[0-9]+$');
  static final RegExp _lowercase = RegExp('[a-z]');
  static final RegExp _uppercase = RegExp('[A-Z]');
  static final RegExp _digit = RegExp('[0-9]');

  /// The messages validators currently use. Defaults to
  /// `const ValidationMessages()`.
  static ValidationMessages get messages => _messages;

  /// The rules validators currently use. Defaults to
  /// `const ValidationRules()`.
  static ValidationRules get rules => _rules;

  /// Sets the app-wide [messages] and/or [rules].
  ///
  /// Only the arguments you pass are replaced. Call it once at startup, or
  /// again whenever the configuration changes, such as after a locale change.
  ///
  /// ```dart
  /// FormValidators.configure(
  ///   messages: const AppValidationMessages(),
  ///   rules: FormValidators.rules.copyWith(passwordMinLength: 10),
  /// );
  /// ```
  static void configure({
    ValidationMessages? messages,
    ValidationRules? rules,
  }) {
    if (messages != null) _messages = messages;
    if (rules != null) _rules = rules;
  }

  /// Restores the built-in default [messages] and [rules].
  ///
  /// Call it in `tearDown` so tests don't leak configuration into each other.
  static void reset() {
    _messages = const ValidationMessages();
    _rules = const ValidationRules();
  }

  // General -------------------------------------------------------------------

  /// Fails when the value is null or blank after trimming.
  ///
  /// [message] replaces [ValidationMessages.required].
  static FormFieldValidator<String> required({String? message}) {
    return (value) => _isBlank(value) ? message ?? messages.required : null;
  }

  /// Fails when the trimmed value has fewer than [min] characters.
  ///
  /// An empty value is valid. Combine with [required] in [compose] to also
  /// reject it. [message] replaces [ValidationMessages.minLength].
  static FormFieldValidator<String> minLength(int min, {String? message}) {
    assert(min >= 0, 'min must be >= 0');
    return (value) {
      final input = _trim(value);
      if (input.isEmpty || _length(input) >= min) return null;
      return message ?? messages.minLength(min);
    };
  }

  /// Fails when the trimmed value has more than [max] characters.
  ///
  /// An empty value is valid. [message] replaces
  /// [ValidationMessages.maxLength].
  static FormFieldValidator<String> maxLength(int max, {String? message}) {
    assert(max >= 0, 'max must be >= 0');
    return (value) {
      final input = _trim(value);
      if (input.isEmpty || _length(input) <= max) return null;
      return message ?? messages.maxLength(max);
    };
  }

  /// Fails when the trimmed value has fewer than [min] or more than [max]
  /// characters.
  ///
  /// [min] must not be negative or greater than [max]. An empty value is
  /// valid. Combine with [required] in [compose] to also reject it. [message]
  /// replaces [ValidationMessages.lengthBetween].
  static FormFieldValidator<String> lengthBetween(
    int min,
    int max, {
    String? message,
  }) {
    assert(min >= 0, 'min must be >= 0');
    assert(min <= max, 'min must be <= max');
    return (value) {
      final input = _trim(value);
      if (input.isEmpty) return null;
      final length = _length(input);
      if (length >= min && length <= max) return null;
      return message ?? messages.lengthBetween(min, max);
    };
  }

  /// Fails when the trimmed value has no match for the regular expression
  /// [pattern].
  ///
  /// The value only has to contain a match, so anchor [pattern] with `^` and
  /// `$` to match the whole value. An empty value is valid. [message]
  /// replaces [ValidationMessages.invalidFormat].
  ///
  /// ```dart
  /// FormValidators.pattern(r'^[A-Z]{2}\d{4}$');
  /// ```
  static FormFieldValidator<String> pattern(String pattern, {String? message}) {
    return (value) {
      final input = _trim(value);
      if (input.isEmpty || _matches(pattern, input)) return null;
      return message ?? messages.invalidFormat;
    };
  }

  // Email and phone -----------------------------------------------------------

  /// Validates an email address against [pattern], or
  /// [ValidationRules.emailPattern] when [pattern] is null.
  ///
  /// When [isRequired] is `false`, an empty value is valid. [requiredMessage]
  /// replaces [ValidationMessages.emailRequired] and [message] replaces
  /// [ValidationMessages.invalidEmail].
  static FormFieldValidator<String> email({
    bool isRequired = true,
    String? pattern,
    String? requiredMessage,
    String? message,
  }) {
    return (value) {
      final input = _trim(value);
      if (input.isEmpty) {
        return isRequired ? requiredMessage ?? messages.emailRequired : null;
      }
      if (_matches(pattern ?? rules.emailPattern, input)) return null;
      return message ?? messages.invalidEmail;
    };
  }

  /// Validates a phone number against [pattern], or
  /// [ValidationRules.phonePattern] when [pattern] is null.
  ///
  /// The value is trimmed but not otherwise normalized. When [isRequired] is
  /// `false`, an empty value is valid. [requiredMessage] replaces
  /// [ValidationMessages.phoneRequired] and [message] replaces
  /// [ValidationMessages.invalidPhone].
  static FormFieldValidator<String> phone({
    bool isRequired = true,
    String? pattern,
    String? requiredMessage,
    String? message,
  }) {
    return (value) {
      final input = _trim(value);
      if (input.isEmpty) {
        return isRequired ? requiredMessage ?? messages.phoneRequired : null;
      }
      if (_matches(pattern ?? rules.phonePattern, input)) return null;
      return message ?? messages.invalidPhone;
    };
  }

  /// Validates a value that may be either an email address or a phone
  /// number, such as a login identifier.
  ///
  /// - A value that contains `@` or any letter is checked against
  ///   [ValidationRules.emailPattern] and fails with
  ///   [ValidationMessages.invalidEmail].
  /// - A value of only digits, with an optional leading `+`, is checked
  ///   against [ValidationRules.phonePattern] and fails with
  ///   [ValidationMessages.invalidPhone].
  /// - Anything else fails with [ValidationMessages.invalidEmailOrPhone].
  ///
  /// When [isRequired] is `false`, an empty value is valid. [requiredMessage]
  /// replaces [ValidationMessages.emailOrPhoneRequired] and [message]
  /// replaces all three errors above.
  static FormFieldValidator<String> emailOrPhone({
    bool isRequired = true,
    String? requiredMessage,
    String? message,
  }) {
    return (value) {
      final input = _trim(value);
      if (input.isEmpty) {
        return isRequired
            ? requiredMessage ?? messages.emailOrPhoneRequired
            : null;
      }
      if (input.contains('@') || _letter.hasMatch(input)) {
        if (_matches(rules.emailPattern, input)) return null;
        return message ?? messages.invalidEmail;
      }
      if (_digitsOnly.hasMatch(input)) {
        if (_matches(rules.phonePattern, input)) return null;
        return message ?? messages.invalidPhone;
      }
      return message ?? messages.invalidEmailOrPhone;
    };
  }

  // Password ------------------------------------------------------------------

  /// Validates a password for presence and minimum length only, which suits
  /// login forms. Use [strongPassword] for sign-up forms.
  ///
  /// The raw value is checked, without trimming, and a value of only
  /// whitespace counts as empty. [minLength] defaults to
  /// [ValidationRules.passwordMinLength]. When [isRequired] is `false`, an
  /// empty value is valid. [requiredMessage] replaces
  /// [ValidationMessages.passwordRequired] and [message] replaces
  /// [ValidationMessages.passwordMinLength].
  static FormFieldValidator<String> password({
    bool isRequired = true,
    int? minLength,
    String? requiredMessage,
    String? message,
  }) {
    assert(minLength == null || minLength >= 0, 'minLength must be >= 0');
    return (value) => _checkPasswordBase(
      value,
      isRequired: isRequired,
      minLength: minLength,
      requiredMessage: requiredMessage,
      message: message,
    );
  }

  /// Validates a password against a strength policy.
  ///
  /// Checks run in this order and the first failure is returned:
  ///
  /// 1. At least [minLength] characters
  ///    ([ValidationMessages.passwordMinLength]).
  /// 2. A lowercase letter, `a` to `z`, when [requireLowercase] is `true`
  ///    ([ValidationMessages.passwordLowercase]).
  /// 3. An uppercase letter, `A` to `Z`, when [requireUppercase] is `true`
  ///    ([ValidationMessages.passwordUppercase]).
  /// 4. A digit, `0` to `9`, when [requireNumber] is `true`
  ///    ([ValidationMessages.passwordNumber]).
  /// 5. A match for [ValidationRules.specialCharacterPattern] when
  ///    [requireSpecialCharacter] is `true`
  ///    ([ValidationMessages.passwordSpecialCharacter]).
  ///
  /// Each null argument falls back to the matching field of [rules]. The raw
  /// value is checked, without trimming, and a value of only whitespace
  /// counts as empty. When [isRequired] is `false`, an empty value is valid.
  /// [requiredMessage] replaces [ValidationMessages.passwordRequired] and
  /// [message] replaces every other error.
  static FormFieldValidator<String> strongPassword({
    bool isRequired = true,
    int? minLength,
    bool? requireLowercase,
    bool? requireUppercase,
    bool? requireNumber,
    bool? requireSpecialCharacter,
    String? requiredMessage,
    String? message,
  }) {
    assert(minLength == null || minLength >= 0, 'minLength must be >= 0');
    return (value) {
      final baseError = _checkPasswordBase(
        value,
        isRequired: isRequired,
        minLength: minLength,
        requiredMessage: requiredMessage,
        message: message,
      );
      if (baseError != null || _isBlank(value)) return baseError;

      final input = value!;
      final rules = FormValidators.rules;
      if ((requireLowercase ?? rules.passwordRequireLowercase) &&
          !_lowercase.hasMatch(input)) {
        return message ?? messages.passwordLowercase;
      }
      if ((requireUppercase ?? rules.passwordRequireUppercase) &&
          !_uppercase.hasMatch(input)) {
        return message ?? messages.passwordUppercase;
      }
      if ((requireNumber ?? rules.passwordRequireNumber) &&
          !_digit.hasMatch(input)) {
        return message ?? messages.passwordNumber;
      }
      if ((requireSpecialCharacter ?? rules.passwordRequireSpecialCharacter) &&
          !_matches(rules.specialCharacterPattern, input)) {
        return message ?? messages.passwordSpecialCharacter;
      }
      return null;
    };
  }

  // Numbers -------------------------------------------------------------------

  /// Validates a number, parsed from the trimmed value with `num.tryParse`.
  ///
  /// When [allowDecimal] is `false`, only whole numbers are accepted, so
  /// `5.0` is rejected. NaN and infinity are always rejected. When [min] or
  /// [max] is given, the number must be within that inclusive range, and
  /// [min] must not be greater than [max].
  ///
  /// When [isRequired] is `false`, an empty value is valid.
  /// [requiredMessage] replaces [ValidationMessages.required] and [message]
  /// replaces [ValidationMessages.invalidNumber],
  /// [ValidationMessages.numberMin] and [ValidationMessages.numberMax].
  static FormFieldValidator<String> number({
    bool isRequired = true,
    num? min,
    num? max,
    bool allowDecimal = true,
    String? requiredMessage,
    String? message,
  }) {
    assert(min == null || max == null || min <= max, 'min must be <= max');
    return (value) {
      final input = _trim(value);
      if (input.isEmpty) {
        return isRequired ? requiredMessage ?? messages.required : null;
      }
      final parsed = allowDecimal ? num.tryParse(input) : int.tryParse(input);
      if (parsed == null || !parsed.isFinite) {
        return message ?? messages.invalidNumber;
      }
      if (min != null && parsed < min) {
        return message ?? messages.numberMin(min);
      }
      if (max != null && parsed > max) {
        return message ?? messages.numberMax(max);
      }
      return null;
    };
  }

  // Combinators ---------------------------------------------------------------

  /// Fails when the raw value differs from the current value returned by
  /// [other], which is read each time validation runs.
  ///
  /// Values are compared exactly, without trimming, and null counts as an
  /// empty string, so two empty values match. Combine with [required] in
  /// [compose] to also reject an empty value. [message] replaces
  /// [ValidationMessages.valuesDoNotMatch].
  ///
  /// ```dart
  /// TextFormField(
  ///   validator: FormValidators.compose([
  ///     FormValidators.required(),
  ///     FormValidators.match(() => passwordController.text),
  ///   ]),
  /// );
  /// ```
  static FormFieldValidator<String> match(
    String? Function() other, {
    String? message,
  }) {
    return (value) {
      if ((value ?? '') == (other() ?? '')) return null;
      return message ?? messages.valuesDoNotMatch;
    };
  }

  /// Runs [validators] in order and returns the first error, skipping `null`
  /// entries. Returns `null` when every validator passes.
  ///
  /// The list is copied, so changing it afterwards has no effect.
  ///
  /// ```dart
  /// FormValidators.compose([
  ///   FormValidators.required(),
  ///   FormValidators.lengthBetween(3, 20),
  ///   isSignUp ? FormValidators.pattern(r'^[a-z0-9_]+$') : null,
  /// ]);
  /// ```
  static FormFieldValidator<String> compose(
    List<FormFieldValidator<String>?> validators,
  ) {
    final active = validators.nonNulls.toList(growable: false);
    return (value) {
      for (final validator in active) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  // Helpers -------------------------------------------------------------------

  static String? _checkPasswordBase(
    String? value, {
    required bool isRequired,
    required int? minLength,
    required String? requiredMessage,
    required String? message,
  }) {
    if (_isBlank(value)) {
      return isRequired ? requiredMessage ?? messages.passwordRequired : null;
    }
    final min = minLength ?? rules.passwordMinLength;
    if (_length(value!) >= min) return null;
    return message ?? messages.passwordMinLength(min);
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  static String _trim(String? value) => value?.trim() ?? '';

  /// Counts Unicode code points, so a character outside the Basic
  /// Multilingual Plane, such as an emoji, counts once.
  static int _length(String value) => value.runes.length;

  static bool _matches(String pattern, String input) =>
      RegExp(pattern).hasMatch(input);
}

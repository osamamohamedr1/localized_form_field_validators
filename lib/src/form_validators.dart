import 'package:flutter/widgets.dart'
    show FormFieldValidator, LocalizationsDelegate;

import 'arab_country.dart';
import 'iban.dart';
import 'password_check.dart';
import 'validation_messages.dart';
import 'validation_messages_delegate.dart';
import 'validation_rules.dart';

/// Builders for `TextFormField` validators, plus the app-wide configuration
/// they read from.
///
/// Every builder returns a `FormFieldValidator<String>` that plugs straight
/// into a form field, except the date builders ([futureDate], [pastDate] and
/// [age]), which return a `FormFieldValidator<DateTime>` for date fields:
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
/// whitespace as empty. Arabic and Persian digits are converted to `0`–`9`
/// before checking phone numbers, numbers, national IDs, passports and
/// IBANs; see [ValidationRules.normalizeDigits].
abstract final class FormValidators {
  static ValidationMessages _messages = const ValidationMessages();
  static ValidationRules _rules = const ValidationRules();

  static final RegExp _letter = RegExp(r'\p{L}', unicode: true);
  static final RegExp _digitsOnly = RegExp(r'^\+?[0-9]+$');
  static final RegExp _idSeparators = RegExp(r'[\s-]');
  static final RegExp _whitespace = RegExp(r'\s');
  static final RegExp _easternDigits = RegExp('[\u0660-\u0669\u06F0-\u06F9]');

  /// The messages validators currently use. Defaults to the English
  /// `const ValidationMessages()`.
  static ValidationMessages get messages => _messages;

  /// The rules validators currently use. Defaults to
  /// `const ValidationRules()`.
  static ValidationRules get rules => _rules;

  /// A localizations delegate that switches [messages] to the app's locale.
  ///
  /// Add it to `MaterialApp.localizationsDelegates` and the validators follow
  /// the app's language: Arabic for `ar` locales and English otherwise. Use
  /// [ValidationMessagesDelegate] directly to choose your own messages per
  /// locale.
  ///
  /// ```dart
  /// MaterialApp(
  ///   localizationsDelegates: const [
  ///     FormValidators.delegate,
  ///     ...GlobalMaterialLocalizations.delegates,
  ///   ],
  ///   supportedLocales: const [Locale('en'), Locale('ar')],
  /// );
  /// ```
  static const LocalizationsDelegate<ValidationMessages> delegate =
      ValidationMessagesDelegate();

  /// Sets the app-wide messages and/or [rules].
  ///
  /// Set the messages in one of two ways:
  ///
  /// - [languageCode] selects built-in messages, as returned by
  ///   [ValidationMessages.forLanguage]. It is case-insensitive and ignores a
  ///   region suffix such as `-EG`, and a code without built-in messages
  ///   falls back to English.
  /// - [messages] sets your own messages, such as a subclass of
  ///   [ValidationMessages].
  ///
  /// Pass at most one of the two. Only the arguments you pass are replaced,
  /// so until you pass one, validators use the English defaults. Call this
  /// once at startup, or again whenever the configuration changes, such as
  /// after a locale change.
  ///
  /// ```dart
  /// FormValidators.configure(languageCode: 'ar');
  ///
  /// FormValidators.configure(
  ///   messages: const AppValidationMessages(),
  ///   rules: FormValidators.rules.copyWith(passwordMinLength: 10),
  /// );
  /// ```
  static void configure({
    String? languageCode,
    ValidationMessages? messages,
    ValidationRules? rules,
  }) {
    assert(
      languageCode == null || messages == null,
      'Pass either languageCode or messages, not both.',
    );
    if (languageCode != null) {
      _messages = ValidationMessages.forLanguage(languageCode);
    }
    if (messages != null) _messages = messages;
    if (rules != null) _rules = rules;
  }

  /// Restores the built-in default [messages] (English) and [rules].
  ///
  /// Call it in `tearDown` so tests don't leak configuration into each other.
  static void reset() {
    _messages = const ValidationMessages();
    _rules = const ValidationRules();
  }

  /// Converts Arabic-Indic (`٠١٢٣٤٥٦٧٨٩`) and Persian (`۰۱۲۳۴۵۶۷۸۹`) digits
  /// in [value] to `0`–`9` and leaves everything else unchanged.
  ///
  /// The validators accept these digits, but your backend may not, so
  /// convert values before you store or send them:
  ///
  /// ```dart
  /// final phone = FormValidators.normalizeDigits(phoneController.text);
  /// ```
  static String normalizeDigits(String value) {
    return value.replaceAllMapped(_easternDigits, (match) {
      final unit = match[0]!.codeUnitAt(0);
      return String.fromCharCode(
        0x30 + unit - (unit >= 0x06F0 ? 0x06F0 : 0x0660),
      );
    });
  }

  // General -------------------------------------------------------------------

  /// Fails when the value is null or blank after trimming.
  ///
  /// The error is [ValidationMessages.required], or
  /// [ValidationMessages.requiredField] when [fieldName] is given, for
  /// example "Name is required." for `fieldName: 'Name'`. Pass a [fieldName]
  /// in the current language. [message] replaces both.
  static FormFieldValidator<String> required({
    String? message,
    String? fieldName,
  }) {
    return (value) {
      if (!_isBlank(value)) return null;
      if (message != null) return message;
      return fieldName != null
          ? messages.requiredField(fieldName)
          : messages.required;
    };
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
      final input = _numericInput(value);
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
  ///   [emailPattern], or [ValidationRules.emailPattern] when it is null, and
  ///   fails with [ValidationMessages.invalidEmail].
  /// - A value of only digits, with an optional leading `+`, is checked
  ///   against [phonePattern], or [ValidationRules.phonePattern] when it is
  ///   null, and fails with [ValidationMessages.invalidPhone].
  /// - Anything else fails with [ValidationMessages.invalidEmailOrPhone].
  ///
  /// When [isRequired] is `false`, an empty value is valid. [requiredMessage]
  /// replaces [ValidationMessages.emailOrPhoneRequired] and [message]
  /// replaces all three errors above.
  static FormFieldValidator<String> emailOrPhone({
    bool isRequired = true,
    String? emailPattern,
    String? phonePattern,
    String? requiredMessage,
    String? message,
  }) {
    return (value) {
      final input = _numericInput(value);
      if (input.isEmpty) {
        return isRequired
            ? requiredMessage ?? messages.emailOrPhoneRequired
            : null;
      }
      if (input.contains('@') || _letter.hasMatch(input)) {
        if (_matches(emailPattern ?? rules.emailPattern, input)) return null;
        return message ?? messages.invalidEmail;
      }
      if (_digitsOnly.hasMatch(input)) {
        if (_matches(phonePattern ?? rules.phonePattern, input)) return null;
        return message ?? messages.invalidPhone;
      }
      return message ?? messages.invalidEmailOrPhone;
    };
  }

  // National ID ---------------------------------------------------------------

  /// Validates a national ID number for [country].
  ///
  /// Spaces and dashes are removed before checking, so `784-1990-1234567-1`
  /// is checked as `784199012345671`. The checks per country:
  ///
  /// | Country | Checks |
  /// |---|---|
  /// | [ArabCountry.egypt] | 14 digits; century digit `2` or `3`; a real birth date that is not in the future; a governorate code. The check digit is not verified because its algorithm is not published. |
  /// | [ArabCountry.saudiArabia] | 10 digits starting with `1` (citizen) or `2` (Iqama); check digit. |
  /// | [ArabCountry.uae] | 15 digits starting with `784`; a birth year that is not in the future; check digit. |
  /// | [ArabCountry.kuwait] | 12 digits; century digit; a real birth date that is not in the future; check digit. |
  /// | [ArabCountry.qatar] | 11 digits; century digit; a birth year that is not in the future; a nationality code other than `000`. |
  /// | [ArabCountry.bahrain] | 9 digits whose third and fourth digits are a birth month. |
  /// | [ArabCountry.libya] | 12 digits starting with `1` or `2`; a birth year that is not in the future. |
  /// | [ArabCountry.palestine] | 9 digits; check digit. |
  /// | [ArabCountry.morocco] | One or two letters followed by up to 6 digits. |
  /// | [ArabCountry.algeria] | 18 digits. |
  /// | [ArabCountry.iraq] | 12 digits. |
  /// | [ArabCountry.jordan] | 10 digits. |
  /// | [ArabCountry.syria] | 11 digits. |
  /// | [ArabCountry.tunisia] | 8 digits. |
  ///
  /// To change a rule, pass [isValid] for this field, or set
  /// [ValidationRules.nationalIdRules] for the whole app. The rule is chosen
  /// in this order: [isValid], then `rules.nationalIdRules[country]`, then
  /// the built-in rule. It receives the trimmed ID with spaces and dashes
  /// removed and Arabic digits converted.
  ///
  /// ```dart
  /// FormValidators.nationalId(
  ///   ArabCountry.kuwait,
  ///   isValid: (id) => RegExp(r'^\d{12}$').hasMatch(id),
  /// );
  /// ```
  ///
  /// For a country without national ID rules (see
  /// [ArabCountry.hasNationalIdRules]), or when [country] is null and no
  /// [isValid] is given, only the empty check runs. That makes it safe to
  /// pass a country looked up at runtime:
  ///
  /// ```dart
  /// FormValidators.nationalId(ArabCountry.fromCode(user.nationality));
  /// ```
  ///
  /// When [isRequired] is `false`, an empty value is valid. [requiredMessage]
  /// replaces [ValidationMessages.nationalIdRequired] and [message] replaces
  /// [ValidationMessages.invalidNationalId].
  static FormFieldValidator<String> nationalId(
    ArabCountry? country, {
    bool Function(String id)? isValid,
    bool isRequired = true,
    String? requiredMessage,
    String? message,
  }) {
    return (value) {
      final input = _numericInput(value).replaceAll(_idSeparators, '');
      if (input.isEmpty) {
        return isRequired
            ? requiredMessage ?? messages.nationalIdRequired
            : null;
      }
      final rule =
          isValid ??
          rules.nationalIdRules[country] ??
          country?.isValidNationalId;
      if (rule == null || rule(input)) return null;
      return message ?? messages.invalidNationalId;
    };
  }

  // Passport and IBAN ---------------------------------------------------------

  /// Validates a passport number against [pattern], or
  /// [ValidationRules.passportPattern] when it is null. The default accepts
  /// 6 to 9 letters or digits.
  ///
  /// ```dart
  /// // Egyptian passports: one letter followed by 8 digits.
  /// FormValidators.passport(pattern: r'^[A-Za-z]\d{8}$');
  /// ```
  ///
  /// When [isRequired] is `false`, an empty value is valid. [requiredMessage]
  /// replaces [ValidationMessages.passportRequired] and [message] replaces
  /// [ValidationMessages.invalidPassport].
  static FormFieldValidator<String> passport({
    bool isRequired = true,
    String? pattern,
    String? requiredMessage,
    String? message,
  }) {
    return (value) {
      final input = _numericInput(value);
      if (input.isEmpty) {
        return isRequired ? requiredMessage ?? messages.passportRequired : null;
      }
      if (_matches(pattern ?? rules.passportPattern, input)) return null;
      return message ?? messages.invalidPassport;
    };
  }

  /// Validates an IBAN (international bank account number).
  ///
  /// Spaces are removed and letters upper-cased first, so
  /// `sa03 8000 0000 6080 1016 7519` is accepted. Checks the format, the
  /// length for the country (exact for Arab countries and some others,
  /// otherwise 15 to 34), and the mod-97 checksum. When [countryCode] is
  /// given, such as `'SA'`, the IBAN must be from that country.
  ///
  /// When [isRequired] is `false`, an empty value is valid. [requiredMessage]
  /// replaces [ValidationMessages.ibanRequired] and [message] replaces
  /// [ValidationMessages.invalidIban].
  static FormFieldValidator<String> iban({
    bool isRequired = true,
    String? countryCode,
    String? requiredMessage,
    String? message,
  }) {
    return (value) {
      final input = _numericInput(
        value,
      ).replaceAll(_whitespace, '').toUpperCase();
      if (input.isEmpty) {
        return isRequired ? requiredMessage ?? messages.ibanRequired : null;
      }
      if (isValidIban(input, countryCode: countryCode)) return null;
      return message ?? messages.invalidIban;
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
  /// These checks run, by default in this order, and the first failure is
  /// returned:
  ///
  /// - [PasswordCheck.minLength]: at least [minLength] characters
  ///   ([ValidationMessages.passwordMinLength]).
  /// - [PasswordCheck.lowercase]: a match for [lowercasePattern], `a` to `z`
  ///   by default, when [requireLowercase] is `true`
  ///   ([ValidationMessages.passwordLowercase]).
  /// - [PasswordCheck.uppercase]: a match for [uppercasePattern], `A` to `Z`
  ///   by default, when [requireUppercase] is `true`
  ///   ([ValidationMessages.passwordUppercase]).
  /// - [PasswordCheck.number]: a match for [numberPattern], `0` to `9` by
  ///   default, when [requireNumber] is `true`
  ///   ([ValidationMessages.passwordNumber]).
  /// - [PasswordCheck.specialCharacter]: a match for
  ///   [specialCharacterPattern] when [requireSpecialCharacter] is `true`
  ///   ([ValidationMessages.passwordSpecialCharacter]).
  ///
  /// [checkOrder] changes the order and must list every check exactly once.
  /// Each null argument falls back to the matching field of [rules], such as
  /// [ValidationRules.passwordCheckOrder].
  ///
  /// ```dart
  /// FormValidators.strongPassword(
  ///   specialCharacterPattern: r'[@$!%*?&^#_+=-]',
  ///   checkOrder: const [
  ///     PasswordCheck.lowercase,
  ///     PasswordCheck.uppercase,
  ///     PasswordCheck.number,
  ///     PasswordCheck.specialCharacter,
  ///     PasswordCheck.minLength,
  ///   ],
  /// );
  /// ```
  ///
  /// The raw value is checked, without trimming, and a value of only
  /// whitespace counts as empty. When [isRequired] is `false`, an empty value
  /// is valid. [requiredMessage] replaces [ValidationMessages.passwordRequired]
  /// and [message] replaces every other error.
  static FormFieldValidator<String> strongPassword({
    bool isRequired = true,
    int? minLength,
    bool? requireLowercase,
    bool? requireUppercase,
    bool? requireNumber,
    bool? requireSpecialCharacter,
    String? lowercasePattern,
    String? uppercasePattern,
    String? numberPattern,
    String? specialCharacterPattern,
    List<PasswordCheck>? checkOrder,
    String? requiredMessage,
    String? message,
  }) {
    assert(minLength == null || minLength >= 0, 'minLength must be >= 0');
    assert(
      checkOrder == null || _isCompleteOrder(checkOrder),
      'checkOrder must list every PasswordCheck exactly once',
    );
    return (value) {
      if (_isBlank(value)) {
        return isRequired ? requiredMessage ?? messages.passwordRequired : null;
      }
      final input = value!;
      final rules = FormValidators.rules;
      final order = checkOrder ?? rules.passwordCheckOrder;
      assert(
        _isCompleteOrder(order),
        'ValidationRules.passwordCheckOrder must list every PasswordCheck '
        'exactly once',
      );

      bool lacks(bool required, String pattern) =>
          required && !_matches(pattern, input);

      for (final check in order) {
        final error = switch (check) {
          PasswordCheck.minLength => _minLengthError(
            input,
            minLength ?? rules.passwordMinLength,
          ),
          PasswordCheck.lowercase =>
            lacks(
                  requireLowercase ?? rules.passwordRequireLowercase,
                  lowercasePattern ?? rules.passwordLowercasePattern,
                )
                ? messages.passwordLowercase
                : null,
          PasswordCheck.uppercase =>
            lacks(
                  requireUppercase ?? rules.passwordRequireUppercase,
                  uppercasePattern ?? rules.passwordUppercasePattern,
                )
                ? messages.passwordUppercase
                : null,
          PasswordCheck.number =>
            lacks(
                  requireNumber ?? rules.passwordRequireNumber,
                  numberPattern ?? rules.passwordNumberPattern,
                )
                ? messages.passwordNumber
                : null,
          PasswordCheck.specialCharacter =>
            lacks(
                  requireSpecialCharacter ??
                      rules.passwordRequireSpecialCharacter,
                  specialCharacterPattern ?? rules.specialCharacterPattern,
                )
                ? messages.passwordSpecialCharacter
                : null,
        };
        if (error != null) return message ?? error;
      }
      return null;
    };
  }

  // Numbers -------------------------------------------------------------------

  /// Validates a number, parsed from the trimmed value with `num.tryParse`.
  ///
  /// When [allowDecimal] is `false`, only whole numbers are accepted, so
  /// `5.0` is rejected. NaN and infinity are always rejected. Arabic digits
  /// and the Arabic decimal separator `٫` are accepted when
  /// [ValidationRules.normalizeDigits] is `true`.
  ///
  /// Bounds:
  ///
  /// - [min] and [max] are inclusive, as in "at least 18".
  /// - [greaterThan] and [lessThan] are exclusive, as in an amount that must
  ///   be more than 0: `number(greaterThan: 0)`.
  ///
  /// Use at most one lower bound ([min] or [greaterThan]) and one upper
  /// bound ([max] or [lessThan]); the lower bound must not be above the
  /// upper one.
  ///
  /// When [isRequired] is `false`, an empty value is valid.
  /// [requiredMessage] replaces [ValidationMessages.required] and [message]
  /// replaces [ValidationMessages.invalidNumber],
  /// [ValidationMessages.numberMin], [ValidationMessages.numberMax],
  /// [ValidationMessages.numberGreaterThan] and
  /// [ValidationMessages.numberLessThan].
  static FormFieldValidator<String> number({
    bool isRequired = true,
    num? min,
    num? max,
    num? greaterThan,
    num? lessThan,
    bool allowDecimal = true,
    String? requiredMessage,
    String? message,
  }) {
    assert(
      min == null || greaterThan == null,
      'Pass either min or greaterThan, not both',
    );
    assert(
      max == null || lessThan == null,
      'Pass either max or lessThan, not both',
    );
    assert(() {
      final lower = min ?? greaterThan;
      final upper = max ?? lessThan;
      return lower == null || upper == null || lower <= upper;
    }(), 'The lower bound must not be above the upper bound');
    return (value) {
      var input = _trim(value);
      if (input.isEmpty) {
        return isRequired ? requiredMessage ?? messages.required : null;
      }
      if (rules.normalizeDigits) {
        input = normalizeDigits(input).replaceAll('\u066B', '.');
      }
      final parsed = allowDecimal ? num.tryParse(input) : int.tryParse(input);
      if (parsed == null || !parsed.isFinite) {
        return message ?? messages.invalidNumber;
      }
      if (min != null && parsed < min) {
        return message ?? messages.numberMin(min);
      }
      if (greaterThan != null && parsed <= greaterThan) {
        return message ?? messages.numberGreaterThan(greaterThan);
      }
      if (max != null && parsed > max) {
        return message ?? messages.numberMax(max);
      }
      if (lessThan != null && parsed >= lessThan) {
        return message ?? messages.numberLessThan(lessThan);
      }
      return null;
    };
  }

  // Dates ---------------------------------------------------------------------

  /// Fails unless the date is after today, for example an expiry date. With
  /// [allowToday], today is accepted too.
  ///
  /// Returns a `FormFieldValidator<DateTime>` for a date field, such as a
  /// `FormField<DateTime>` wrapping a date picker. Only the calendar day is
  /// compared, not the time.
  ///
  /// When [isRequired] is `false`, a null date is valid. [requiredMessage]
  /// replaces [ValidationMessages.dateRequired] and [message] replaces
  /// [ValidationMessages.dateMustBeFuture].
  static FormFieldValidator<DateTime> futureDate({
    bool isRequired = true,
    bool allowToday = false,
    String? requiredMessage,
    String? message,
  }) {
    return (date) {
      if (date == null) {
        return isRequired ? requiredMessage ?? messages.dateRequired : null;
      }
      final comparison = _compareDays(date, DateTime.now());
      if (comparison > 0 || (allowToday && comparison == 0)) return null;
      return message ?? messages.dateMustBeFuture;
    };
  }

  /// Fails unless the date is before today, for example a birth date. Today
  /// is accepted unless [allowToday] is `false`.
  ///
  /// Returns a `FormFieldValidator<DateTime>`. Only the calendar day is
  /// compared, not the time.
  ///
  /// When [isRequired] is `false`, a null date is valid. [requiredMessage]
  /// replaces [ValidationMessages.dateRequired] and [message] replaces
  /// [ValidationMessages.dateMustBePast].
  static FormFieldValidator<DateTime> pastDate({
    bool isRequired = true,
    bool allowToday = true,
    String? requiredMessage,
    String? message,
  }) {
    return (date) {
      if (date == null) {
        return isRequired ? requiredMessage ?? messages.dateRequired : null;
      }
      final comparison = _compareDays(date, DateTime.now());
      if (comparison < 0 || (allowToday && comparison == 0)) return null;
      return message ?? messages.dateMustBePast;
    };
  }

  /// Validates an age calculated from a birth date: at least [min] and at
  /// most [max] whole years old today.
  ///
  /// ```dart
  /// FormField<DateTime>(validator: FormValidators.age(min: 18), ...);
  /// ```
  ///
  /// A birth date in the future fails with
  /// [ValidationMessages.dateMustBePast]. Returns a
  /// `FormFieldValidator<DateTime>`.
  ///
  /// When [isRequired] is `false`, a null date is valid. [requiredMessage]
  /// replaces [ValidationMessages.dateRequired] and [message] replaces
  /// [ValidationMessages.ageMin], [ValidationMessages.ageMax] and
  /// [ValidationMessages.dateMustBePast].
  static FormFieldValidator<DateTime> age({
    int? min,
    int? max,
    bool isRequired = true,
    String? requiredMessage,
    String? message,
  }) {
    assert(min == null || min >= 0, 'min must be >= 0');
    assert(min == null || max == null || min <= max, 'min must be <= max');
    return (birthDate) {
      if (birthDate == null) {
        return isRequired ? requiredMessage ?? messages.dateRequired : null;
      }
      final today = DateTime.now();
      if (_compareDays(birthDate, today) > 0) {
        return message ?? messages.dateMustBePast;
      }
      var years = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        years--;
      }
      if (min != null && years < min) return message ?? messages.ageMin(min);
      if (max != null && years > max) return message ?? messages.ageMax(max);
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
  /// Works for any field type, such as `String` for text fields and
  /// `DateTime` for date fields. The list is copied, so changing it
  /// afterwards has no effect.
  ///
  /// ```dart
  /// FormValidators.compose([
  ///   FormValidators.required(),
  ///   FormValidators.lengthBetween(3, 20),
  ///   isSignUp ? FormValidators.pattern(r'^[a-z0-9_]+$') : null,
  /// ]);
  /// ```
  static FormFieldValidator<T> compose<T>(
    List<FormFieldValidator<T>?> validators,
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

  static String? _minLengthError(String password, int min) =>
      _length(password) < min ? messages.passwordMinLength(min) : null;

  static bool _isCompleteOrder(List<PasswordCheck> order) =>
      order.length == PasswordCheck.values.length &&
      order.toSet().length == order.length;

  /// Compares the calendar days of [a] and [b], ignoring the time of day.
  static int _compareDays(DateTime a, DateTime b) {
    if (a.year != b.year) return a.year.compareTo(b.year);
    if (a.month != b.month) return a.month.compareTo(b.month);
    return a.day.compareTo(b.day);
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  /// The trimmed value, with Arabic digits converted when
  /// [ValidationRules.normalizeDigits] is `true`.
  static String _numericInput(String? value) {
    final input = _trim(value);
    return rules.normalizeDigits ? normalizeDigits(input) : input;
  }

  static String _trim(String? value) => value?.trim() ?? '';

  /// Counts Unicode code points, so a character outside the Basic
  /// Multilingual Plane, such as an emoji, counts once.
  static int _length(String value) => value.runes.length;

  static bool _matches(String pattern, String input) =>
      RegExp(pattern).hasMatch(input);
}

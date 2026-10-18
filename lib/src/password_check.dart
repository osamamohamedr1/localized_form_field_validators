/// One of the checks `FormValidators.strongPassword` runs.
///
/// Use these to change the order of the checks with
/// `ValidationRules.passwordCheckOrder` or the `checkOrder` argument of
/// `strongPassword`. Each order must list every check exactly once; turn a
/// check off with its `require*` flag, or with a minimum length of `0`.
///
/// ```dart
/// // Check the length last.
/// FormValidators.strongPassword(
///   checkOrder: const [
///     PasswordCheck.lowercase,
///     PasswordCheck.uppercase,
///     PasswordCheck.number,
///     PasswordCheck.specialCharacter,
///     PasswordCheck.minLength,
///   ],
/// );
/// ```
enum PasswordCheck {
  /// At least the minimum number of characters.
  minLength,

  /// At least one character matching the lowercase pattern.
  lowercase,

  /// At least one character matching the uppercase pattern.
  uppercase,

  /// At least one character matching the number pattern.
  number,

  /// At least one character matching the special character pattern.
  specialCharacter,
}

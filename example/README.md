# localized_form_field_validators_example

A demo sign-up form for the `localized_form_field_validators` package. It
shows:

- **Defaults:** fields that use the built-in messages and rules, including
  `required(fieldName: ...)`.
- **Following the locale:** a `ValidationMessagesDelegate` in `MaterialApp`
  switches the validators between English and Arabic. The translate icon in
  the app bar changes the locale, and Arabic is laid out right to left.
- **Global overrides:** `DemoMessages` and `DemoArabicMessages` change a few
  messages, and `PhonePatterns` limits the phone field to Egyptian and Saudi
  mobile numbers.
- **National ID:** an optional Egyptian national ID field, using
  `FormValidators.nationalId(ArabCountry.egypt)`.
- **Per-call override:** the confirm-password field passes its own messages.

Run it with:

```sh
flutter run
```

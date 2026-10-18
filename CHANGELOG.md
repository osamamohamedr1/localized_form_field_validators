## 0.2.0

* Built-in translations for Arabic (`ar`), German (`de`), Spanish (`es`),
  French (`fr`) and Turkish (`tr`). Arabic counts follow Arabic plural rules.
* `FormValidators.configure(languageCode: 'ar')` selects a built-in language.
  Codes are case-insensitive, and region suffixes such as `ar-EG` are
  ignored. Messages stay in English when no language code is passed, and an
  unsupported code falls back to English.
* `ValidationMessages.forLanguage(code)` and
  `ValidationMessages.supportedLanguageCodes`.
* Public `ValidationMessagesAr`, `ValidationMessagesDe`,
  `ValidationMessagesEs`, `ValidationMessagesFr` and `ValidationMessagesTr`
  classes. Extend one to change individual messages.
* The example app has a language menu.

## 0.1.0

Initial release.

* `FormValidators` builders that return `FormFieldValidator<String>`:
  `required`, `minLength`, `maxLength`, `lengthBetween`, `pattern`, `email`,
  `phone`, `emailOrPhone`, `password`, `strongPassword`, `number`, `match` and
  `compose`.
* `ValidationMessages` with English defaults. Extend it to override or
  localize individual messages.
* `ValidationRules` with default email and phone patterns and a password
  policy, plus `copyWith`.
* Global configuration with `FormValidators.configure` and
  `FormValidators.reset`, and per-call overrides on every builder. Precedence
  is per-call, then global, then default.
* Messages and rules are read when validation runs, so locale changes and
  later `configure` calls take effect in validators that already exist.
* No dependencies besides Flutter.

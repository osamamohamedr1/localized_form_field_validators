## 0.3.0

**Breaking:** the package now ships English and Arabic messages only. The
German, Spanish, French and Turkish messages (`ValidationMessagesDe`,
`ValidationMessagesEs`, `ValidationMessagesFr` and `ValidationMessagesTr`)
are removed, and those language codes now fall back to English. Extend
`ValidationMessages` to provide another language.

**Arab countries**

* `ArabCountry`: 18 Arab countries with ISO codes, dial codes and mobile
  phone patterns. Look one up with `ArabCountry.fromCode('EG')` or
  `fromCode('EGY')`.
* `PhonePatterns`: the same mobile patterns as `const` strings, plus
  `PhonePatterns.anyOf`.
* `FormValidators.nationalId(country)` for 14 of those countries: Egypt,
  Saudi Arabia, the UAE, Kuwait, Qatar, Bahrain, Libya, Palestine, Morocco,
  Algeria, Iraq, Jordan, Syria and Tunisia. Override a rule per field with
  `isValid`, or for the whole app with `ValidationRules.nationalIdRules`.
* Arabic-Indic and Persian digits are accepted in phone numbers, numbers,
  national IDs, passports and IBANs (`ValidationRules.normalizeDigits`), and
  `FormValidators.normalizeDigits` converts them for storage.

**New validators**

* `passport()` with `ValidationRules.passportPattern`.
* `iban()` with a mod-97 checksum, country lengths and an optional
  `countryCode`.
* `futureDate()`, `pastDate()` and `age(min:, max:)`, which return a
  `FormFieldValidator<DateTime>`. `compose` is now generic, so it also
  combines date validators.

**More options**

* `number(greaterThan:, lessThan:)` for exclusive bounds, such as an amount
  above 0.
* `emailOrPhone(emailPattern:, phonePattern:)`.
* `strongPassword`: change the order of its checks with `checkOrder` or
  `ValidationRules.passwordCheckOrder` (new `PasswordCheck` enum), and the
  character classes with `lowercasePattern`, `uppercasePattern`,
  `numberPattern` and `specialCharacterPattern`, or the matching
  `ValidationRules` fields.
* `required(fieldName:)` with a new `requiredField` message, for example
  "Name is required." or "حقل الاسم مطلوب.".
* `FormValidators.delegate` and `ValidationMessagesDelegate`: a localizations
  delegate that switches the messages when the app's locale changes.

**Messages**

* New messages: `requiredField`, `nationalIdRequired`, `invalidNationalId`,
  `passportRequired`, `invalidPassport`, `ibanRequired`, `invalidIban`,
  `dateRequired`, `dateMustBeFuture`, `dateMustBePast`, `ageMin`, `ageMax`,
  `numberGreaterThan` and `numberLessThan`, in English and Arabic. Your own
  `ValidationMessages` subclasses get the English defaults for them.

**Project**

* GitHub Actions: CI on every push and pull request, and publishing to
  pub.dev when a version tag is pushed.
* pub.dev topics and screenshots.

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

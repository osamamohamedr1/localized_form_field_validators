# localized_form_field_validators

[![pub package](https://img.shields.io/pub/v/localized_form_field_validators.svg)](https://pub.dev/packages/localized_form_field_validators)
[![CI](https://github.com/osamamohamedr1/localized_form_field_validators/actions/workflows/ci.yml/badge.svg)](https://github.com/osamamohamedr1/localized_form_field_validators/actions/workflows/ci.yml)

Ready-made validators for Flutter's `TextFormField`, with built-in English and
Arabic messages. They work out of the box with sensible rules, include mobile
phone and national ID checks for 18 Arab countries, and let you override any
message or rule for the whole app or for a single field.

```dart
TextFormField(validator: FormValidators.email());
```

## Features

- Validators for required fields, length, regular expressions, email, phone,
  "email or phone", login and strong passwords, numbers and amounts,
  matching fields, national IDs, passports, IBANs, and dates (expiry date,
  minimum age), plus `compose` to combine them.
- English default messages and rules, so no setup is needed.
- Built-in **Arabic** messages, with correct Arabic plurals. Select them with
  `FormValidators.configure(languageCode: 'ar')`, or add
  `FormValidators.delegate` to follow the app's locale automatically.
- Mobile phone patterns for 18 Arab countries, and national ID validators
  for 14 of them, with checksums and birth-date checks where the format has
  them. Look a country up by ISO code with `ArabCountry.fromCode('EG')`.
- Arabic and Persian digits (`٠١٢٣`, `۰۱۲۳`) are accepted in phone numbers,
  numbers, IDs, passports and IBANs.
- Field names in messages: `required(fieldName: 'Name')` gives "Name is
  required." or "حقل الاسم مطلوب.".
- Two levels of override: **global** (once at startup) and **per call** (on
  one field). A per-call argument beats the global configuration, which beats
  the built-in default.
- Works with any localization approach, including easy_localization,
  gen-l10n / `AppLocalizations` or your own. Messages are read each time
  validation runs, so they follow the current locale.
- No `BuildContext` needed, and no dependencies besides Flutter.

## Installation

From pub.dev:

```yaml
dependencies:
  localized_form_field_validators: ^0.3.0
```

From git:

```yaml
dependencies:
  localized_form_field_validators:
    git:
      url: https://github.com/osamamohamedr1/localized_form_field_validators.git
      ref: main
```

From a local path:

```yaml
dependencies:
  localized_form_field_validators:
    path: ../localized_form_field_validators
```

Then import it:

```dart
import 'package:localized_form_field_validators/localized_form_field_validators.dart';
```

## Quick start

```dart
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Name'),
            validator: FormValidators.compose([
              FormValidators.required(fieldName: 'Name'),
              FormValidators.lengthBetween(2, 50),
            ]),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            validator: FormValidators.email(),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
            validator: FormValidators.phone(isRequired: false),
          ),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
            validator: FormValidators.strongPassword(),
          ),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            validator: FormValidators.compose([
              FormValidators.required(),
              FormValidators.match(() => _password.text),
            ]),
          ),
          FilledButton(
            onPressed: () => _formKey.currentState!.validate(),
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }
}
```

The [`example/`](example/) folder contains a runnable version of this form.

## Validators

Every builder returns a `FormFieldValidator<String>`, except the date
builders, which return a `FormFieldValidator<DateTime>` for date fields. These
rules apply to all of them:

- **`isRequired`**: when `false`, an empty value is valid, but a value that is
  filled in is still checked.
- **`requiredMessage`** replaces the error for an empty value. **`message`**
  replaces every other error that builder can return.
- Input is **trimmed** before it is checked, except by `password` and
  `strongPassword`. Those check the raw value and treat a value of only
  spaces as empty.
- **Arabic digits** are converted to `0`–`9` before phone numbers, numbers,
  national IDs, passports and IBANs are checked (see
  [Arabic digits](#arabic-digits)).
- `null` pattern or rule arguments fall back to the global `ValidationRules`.

| Builder | Parameters | Empty value | Errors (`ValidationMessages` member) |
|---|---|---|---|
| `required` | `message`, `fieldName` | error | `required`, or `requiredField(fieldName)` |
| `minLength` | `int min`, `message` | valid | `minLength(min)` |
| `maxLength` | `int max`, `message` | valid | `maxLength(max)` |
| `lengthBetween` | `int min`, `int max`, `message` | valid | `lengthBetween(min, max)` |
| `pattern` | `String pattern`, `message` | valid | `invalidFormat` |
| `email` | `isRequired`, `pattern`, `requiredMessage`, `message` | `emailRequired` | `invalidEmail` |
| `phone` | `isRequired`, `pattern`, `requiredMessage`, `message` | `phoneRequired` | `invalidPhone` |
| `emailOrPhone` | `isRequired`, `emailPattern`, `phonePattern`, `requiredMessage`, `message` | `emailOrPhoneRequired` | `invalidEmail`, `invalidPhone`, `invalidEmailOrPhone` |
| `nationalId` | `ArabCountry? country`, `isValid`, `isRequired`, `requiredMessage`, `message` | `nationalIdRequired` | `invalidNationalId` |
| `passport` | `isRequired`, `pattern`, `requiredMessage`, `message` | `passportRequired` | `invalidPassport` |
| `iban` | `isRequired`, `countryCode`, `requiredMessage`, `message` | `ibanRequired` | `invalidIban` |
| `password` | `isRequired`, `minLength`, `requiredMessage`, `message` | `passwordRequired` | `passwordMinLength(min)` |
| `strongPassword` | `isRequired`, `minLength`, `requireLowercase`, `requireUppercase`, `requireNumber`, `requireSpecialCharacter`, `lowercasePattern`, `uppercasePattern`, `numberPattern`, `specialCharacterPattern`, `checkOrder`, `requiredMessage`, `message` | `passwordRequired` | `passwordMinLength(min)`, `passwordLowercase`, `passwordUppercase`, `passwordNumber`, `passwordSpecialCharacter` |
| `number` | `isRequired`, `min`, `max`, `greaterThan`, `lessThan`, `allowDecimal` (default `true`), `requiredMessage`, `message` | `required` | `invalidNumber`, `numberMin(min)`, `numberMax(max)`, `numberGreaterThan(value)`, `numberLessThan(value)` |
| `futureDate` | `isRequired`, `allowToday` (default `false`), `requiredMessage`, `message` | `dateRequired` | `dateMustBeFuture` |
| `pastDate` | `isRequired`, `allowToday` (default `true`), `requiredMessage`, `message` | `dateRequired` | `dateMustBePast` |
| `age` | `min`, `max`, `isRequired`, `requiredMessage`, `message` | `dateRequired` | `ageMin(min)`, `ageMax(max)`, `dateMustBePast` |
| `match` | `String? Function() other`, `message` | compared like any value | `valuesDoNotMatch` |
| `compose` | `List<FormFieldValidator<T>?> validators` | depends on the validators | first error from the list |

Notes:

- `minLength`, `maxLength`, `lengthBetween` and `pattern` treat an empty value
  as valid. Put `FormValidators.required()` first in a `compose` to also
  reject it.
- Lengths count Unicode code points, so an emoji counts as one character.
- Patterns are matched with `RegExp.hasMatch`, so anchor them with `^` and `$`
  to match the whole value.
- `emailOrPhone` treats a value that contains `@` or any letter as an email.
  It treats a value of only digits, with an optional leading `+`, as a phone
  number. Anything else gets `invalidEmailOrPhone`.
- `strongPassword` checks, by default in this order: minimum length, a
  lowercase letter (`a`–`z`), an uppercase letter (`A`–`Z`), a digit, and a
  special character. It returns the first failure. Both the order and the
  patterns can be changed (see [Passwords](#passwords)).
- `number` parses with `num.tryParse` and always rejects NaN and infinity.
  With `allowDecimal: false` it accepts whole numbers only, so `5.0` is
  rejected. `min` and `max` are inclusive; `greaterThan` and `lessThan` are
  exclusive, so `number(greaterThan: 0)` rejects `0` for an amount.
- `match` compares raw values without trimming and reads `other()` each time
  it runs.

### Default rules

| `ValidationRules` field | Default |
|---|---|
| `emailPattern` | `^[\w.+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$` |
| `phonePattern` | `^\+?[0-9]{7,15}$` |
| `passwordMinLength` | `8` |
| `passwordRequireLowercase` | `true` |
| `passwordRequireUppercase` | `true` |
| `passwordRequireNumber` | `true` |
| `passwordRequireSpecialCharacter` | `true` |
| `passwordLowercasePattern` | `[a-z]` |
| `passwordUppercasePattern` | `[A-Z]` |
| `passwordNumberPattern` | `[0-9]` |
| `specialCharacterPattern` | `[^A-Za-z0-9\s]` |
| `passwordCheckOrder` | `PasswordCheck.values` (length, lowercase, uppercase, number, special) |
| `passportPattern` | `^[A-Za-z0-9]{6,9}$` |
| `nationalIdRules` | `{}` (use the built-in rules) |
| `normalizeDigits` | `true` |

The `passwordRequire*` flags, the character patterns and `passwordCheckOrder`
are used only by `strongPassword`.

## Arabic digits

Many Arabic keyboards type Arabic-Indic digits (`٠١٢٣٤٥٦٧٨٩`), and Persian
keyboards type `۰۱۲۳۴۵۶۷۸۹`. By default `phone`, `emailOrPhone`,
`nationalId`, `number`, `passport` and `iban` convert them to `0`–`9` before
checking, and `number` also accepts the Arabic decimal separator `٫`. Other
validators, such as `pattern`, check the value as typed.

The validators only check the converted value; the field still holds what the
user typed. Convert it before you store or send it:

```dart
final phone = FormValidators.normalizeDigits(phoneController.text);
```

To turn the conversion off, set
`ValidationRules(normalizeDigits: false)`.

## Arab countries: phone numbers and national IDs

`ArabCountry` lists 18 Arab countries. Each has a mobile phone pattern, and
14 have national ID rules:

| Country | `ArabCountry` | Mobile, for example | National ID checks |
|---|---|---|---|
| Algeria | `algeria` | `0551234567` | 18-digit NIN |
| Bahrain | `bahrain` | `36123456` | 9-digit CPR with a birth month |
| Egypt | `egypt` | `01012345678` | 14 digits, century, birth date, governorate |
| Iraq | `iraq` | `07701234567` | 12-digit national card |
| Jordan | `jordan` | `0791234567` | 10-digit national number |
| Kuwait | `kuwait` | `51234567` | 12-digit civil ID, birth date, check digit |
| Lebanon | `lebanon` | `03123456`, `71123456` | none |
| Libya | `libya` | `0911234567` | 12 digits, gender digit, birth year |
| Morocco | `morocco` | `0612345678` | CIN: 1–2 letters and up to 6 digits |
| Oman | `oman` | `91234567` | none |
| Palestine | `palestine` | `0591234567` | 9 digits, check digit |
| Qatar | `qatar` | `55123456` | 11-digit QID, birth year, nationality code |
| Saudi Arabia | `saudiArabia` | `0512345678` | 10-digit ID or Iqama, check digit |
| Sudan | `sudan` | `0912345678` | none |
| Syria | `syria` | `0931234567` | 11-digit national number |
| Tunisia | `tunisia` | `20123456` | 8-digit CIN |
| UAE | `uae` | `0501234567` | 15-digit Emirates ID, `784`, birth year, check digit |
| Yemen | `yemen` | `771234567` | none |

### Phone numbers

The phone patterns match the number **without** the country code, which is
what users type after choosing `+20`, `+966` and so on in a country picker.
Where a country uses a leading `0`, it is optional. Spaces, dashes and a `+`
country prefix are not accepted. The same patterns are available as `const`
strings on `PhonePatterns`, for use in `const ValidationRules(...)`.

```dart
// One country for this field.
FormValidators.phone(pattern: ArabCountry.qatar.phonePattern);

// The country the user picked, by ISO code.
FormValidators.phone(
  pattern: ArabCountry.fromCode(selectedCountryCode)?.phonePattern,
);

// Several countries for the whole app, including emailOrPhone().
FormValidators.configure(
  rules: FormValidators.rules.copyWith(
    phonePattern: PhonePatterns.anyOf([
      PhonePatterns.egypt,
      PhonePatterns.saudiArabia,
    ]),
  ),
);
```

`ArabCountry` also has `isoCode` (`EG`), `isoCode3` (`EGY`) and `dialCode`
(`+20`), so it can drive a country picker.

### National IDs

```dart
TextFormField(
  keyboardType: TextInputType.number,
  validator: FormValidators.nationalId(ArabCountry.egypt),
);

// Nationality from your backend, as an ISO code such as 'EG' or 'EGY'.
FormValidators.nationalId(ArabCountry.fromCode(user.nationality));
```

- Spaces and dashes are removed first, so `784-1990-1234567-6` is accepted
  for the UAE.
- For a country without national ID rules, or when the country is `null`
  (for example, an unknown ISO code), only the empty check runs, so valid IDs
  are never rejected. `ArabCountry.hasNationalIdRules` tells you which
  countries are checked.
- The errors are `nationalIdRequired` and `invalidNationalId`, and
  `isRequired`, `requiredMessage` and `message` work as for other
  validators.
- Egypt's check digit is not verified, because its algorithm is not
  published. Saudi, UAE and Palestinian IDs use the Luhn check digit, and
  Kuwaiti IDs a weighted check digit.

#### Changing a country's rule

If a built-in rule doesn't fit your users' IDs, replace it, for one field
with `isValid` or for the whole app with `ValidationRules.nationalIdRules`.
The rule receives the ID with spaces and dashes removed and Arabic digits
converted. You can also add rules for a country that has none, such as Oman.

```dart
bool kuwaitCivilId(String id) => RegExp(r'^\d{12}$').hasMatch(id);
bool omanCivilNumber(String id) => RegExp(r'^\d{6,9}$').hasMatch(id);

// The whole app.
FormValidators.configure(
  rules: FormValidators.rules.copyWith(
    nationalIdRules: {
      ArabCountry.kuwait: kuwaitCivilId,
      ArabCountry.oman: omanCivilNumber,
    },
  ),
);

// One field, building on the built-in rule.
FormValidators.nationalId(
  ArabCountry.egypt,
  isValid: (id) =>
      ArabCountry.egypt.isValidNationalId(id) || testIds.contains(id),
);
```

The rule is chosen in this order: `isValid`, then
`rules.nationalIdRules[country]`, then the built-in rule.

## Passports and IBANs

```dart
// 6 to 9 letters or digits by default (ValidationRules.passportPattern).
FormValidators.passport();

// Egyptian passports: one letter followed by 8 digits.
FormValidators.passport(pattern: r'^[A-Za-z]\d{8}$');

// Any IBAN, or only Saudi IBANs.
FormValidators.iban();
FormValidators.iban(countryCode: 'SA');
```

`iban()` removes spaces and ignores letter case, so
`sa03 8000 0000 6080 1016 7519` is accepted. It checks the format, the length
(exact for Arab countries and some others, otherwise 15 to 34) and the
mod-97 checksum, so a mistyped digit is caught.

## Dates and ages

The date builders return a `FormFieldValidator<DateTime>`, for a date field
such as a `FormField<DateTime>` that opens a date picker. They compare
calendar days and ignore the time.

```dart
FormField<DateTime>(
  validator: FormValidators.futureDate(), // An expiry date after today.
  builder: (field) => MyDatePicker(field: field),
);

FormValidators.pastDate(); // A date up to today, such as a birth date.
FormValidators.age(min: 18); // At least 18 years old today.

// compose works with dates too.
FormValidators.compose([
  FormValidators.pastDate(),
  FormValidators.age(min: 18, max: 120),
]);
```

`age` counts whole years from the exact birthday and rejects a birth date in
the future.

## Passwords

`strongPassword` runs five checks, by default in this order: minimum length,
lowercase, uppercase, number and special character. Change the order with
`checkOrder` (or `ValidationRules.passwordCheckOrder`), which must list every
`PasswordCheck` once, and change what each character class means with the
pattern arguments (or the matching `ValidationRules` fields):

```dart
FormValidators.strongPassword(
  // Only these count as special characters.
  specialCharacterPattern: r'[@$!%*?&^#_+=-]',
  // Check the length last.
  checkOrder: const [
    PasswordCheck.lowercase,
    PasswordCheck.uppercase,
    PasswordCheck.number,
    PasswordCheck.specialCharacter,
    PasswordCheck.minLength,
  ],
);
```

Turn a check off with its `require*` argument, for example
`requireSpecialCharacter: false`.

## Field names in messages

Pass `fieldName` to `required()` to name the field in the error:

```dart
FormValidators.required(fieldName: 'Name'); // "Name is required."
FormValidators.required(fieldName: 'الاسم'); // Arabic: "حقل الاسم مطلوب."
```

Pass the field name in the current language. The Arabic message uses
"حقل … مطلوب", so it is grammatically correct whatever the field name. Override
`requiredField` in your messages to change the wording.

## Built-in languages

The messages are in English unless you choose Arabic:

| Code | Language | Class |
|---|---|---|
| `en` | English (default) | `ValidationMessages` |
| `ar` | Arabic | `ValidationMessagesAr` |

- If you don't pass a language code, the messages are in English.
- Codes are case-insensitive, and region suffixes are ignored, so `'ar'`,
  `'AR'`, `'ar-EG'` and `'ar_SA'` all select Arabic.
- Any other code falls back to English. For another language, extend
  `ValidationMessages` (see
  [Overriding messages globally](#overriding-messages-globally)).
- Arabic counts follow Arabic plural rules, for example "حرف واحد", "حرفين",
  "3 أحرف" and "11 حرفًا".
- Validators that already exist switch language the next time they run.

### Following the app's locale

Add `FormValidators.delegate` to your `MaterialApp`. Whenever the locale
changes, it switches the validators to Arabic for `ar` locales and to English
otherwise:

```dart
MaterialApp(
  locale: currentLocale,
  supportedLocales: const [Locale('en'), Locale('ar')],
  localizationsDelegates: const [
    FormValidators.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: const HomePage(),
);
```

`GlobalMaterialLocalizations` comes from `flutter_localizations`, which your
app needs for right-to-left layout and Arabic Material labels.

To choose your own messages for each locale, create a
`ValidationMessagesDelegate` with a top-level `messagesFor` function:

```dart
ValidationMessages appMessagesFor(Locale locale) =>
    locale.languageCode == 'ar'
        ? const AppArabicMessages()
        : const AppEnglishMessages();

MaterialApp(
  localizationsDelegates: const [
    ValidationMessagesDelegate(messagesFor: appMessagesFor),
    ...GlobalMaterialLocalizations.delegates,
  ],
  // ...
);
```

Use a top-level or static function, not a closure created in `build`, so the
messages are not reloaded on every rebuild.

Without a delegate, set the language yourself:

```dart
FormValidators.configure(languageCode: 'ar');
```

> An error that is already on screen keeps its old text until the field is
> validated again, for example on the next `validate()` call or keystroke
> with `AutovalidateMode.onUserInteraction`.

### Changing one message in Arabic

Extend `ValidationMessagesAr` and override only what you need. Every other
message stays in Arabic:

```dart
class AppArabicMessages extends ValidationMessagesAr {
  const AppArabicMessages();

  @override
  String get invalidPhone => 'أدخل رقم جوال مصري أو سعودي صحيح.';
}

FormValidators.configure(messages: const AppArabicMessages());
```

## Overriding messages globally

To use your own translations instead, for example for another language or
one that your app already translates, extend
`ValidationMessages`, override only the messages you need, and pass an
instance to `FormValidators.configure`. Every message you don't override
keeps its English default.

Validators read messages **each time they run** and never cache them. A
getter that looks up a translation therefore always returns the text for the
current locale.

### With easy_localization

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

import 'generated/locale_keys.g.dart';

class AppValidationMessages extends ValidationMessages {
  const AppValidationMessages();

  @override
  String get required => LocaleKeys.required.tr();

  @override
  String get invalidEmail => LocaleKeys.invalidEmail.tr();

  @override
  String minLength(int min) =>
      LocaleKeys.minLength.tr(namedArgs: {'min': '$min'});
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  FormValidators.configure(messages: const AppValidationMessages());

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}
```

`configure` runs only once. When the user switches language with
`context.setLocale(...)`, the getters return the new translations the next
time a field is validated.

### With gen-l10n (`AppLocalizations`)

Wrap the generated `AppLocalizations` in a `ValidationMessages` subclass, and
register it with a `ValidationMessagesDelegate`. gen-l10n generates
`lookupAppLocalizations(locale)`, which returns the right instance without a
`BuildContext`, and the delegate swaps it in whenever the locale changes.

```dart
// lib/l10n/app_en.arb
// {
//   "validationRequired": "This field is required.",
//   "validationMinLength": "Must be at least {min} characters.",
//   "@validationMinLength": {
//     "placeholders": { "min": { "type": "int" } }
//   }
// }

import 'package:localized_form_field_validators/localized_form_field_validators.dart';
import 'package:my_app/l10n/app_localizations.dart';

class L10nValidationMessages extends ValidationMessages {
  const L10nValidationMessages(this.l10n);

  final AppLocalizations l10n;

  @override
  String get required => l10n.validationRequired;

  @override
  String minLength(int min) => l10n.validationMinLength(min);
}

ValidationMessages l10nMessagesFor(Locale locale) =>
    L10nValidationMessages(lookupAppLocalizations(locale));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      localizationsDelegates: [
        ValidationMessagesDelegate(messagesFor: l10nMessagesFor),
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    );
  }
}
```

Adjust the `AppLocalizations` import to match your `l10n.yaml`. Projects
that still use the older synthetic package import
`package:flutter_gen/gen_l10n/app_localizations.dart`.

## Overriding rules

`ValidationRules` is immutable. Use `copyWith` to change only what you need.
For example, to accept Egyptian (`010`, `011`, `012`, `015` + 8 digits) and
Saudi (`5` + 8 digits) mobile numbers:

```dart
FormValidators.configure(
  rules: const ValidationRules().copyWith(
    phonePattern: r'^(010|011|012|015)\d{8}$|^5\d{8}$',
  ),
);
```

The phone pattern is used by `phone` and by the phone branch of
`emailOrPhone`. To build on the rules that are already configured, start from
`FormValidators.rules`:

```dart
FormValidators.configure(
  rules: FormValidators.rules.copyWith(
    passwordMinLength: 12,
    passwordRequireSpecialCharacter: false,
  ),
);
```

`configure` replaces only what you pass, so setting `rules` keeps your
messages and setting `messages` keeps your rules. Validators that already
exist pick up the change the next time they run.

## Per-call overrides

Any builder argument overrides the global configuration for that one field.

```dart
// Message overrides.
FormValidators.email(
  requiredMessage: 'We need your work email.',
  message: 'That does not look like an email address.',
);

// Rule overrides.
FormValidators.email(pattern: r'^[\w.+-]+@company\.com$');
FormValidators.phone(pattern: r'^\d{3}-\d{4}$');
FormValidators.emailOrPhone(
  emailPattern: r'@company\.com$',
  phonePattern: ArabCountry.qatar.phonePattern,
);
FormValidators.strongPassword(minLength: 12, requireSpecialCharacter: false);
```

Precedence, from highest to lowest:

1. **Per-call argument**, such as `message`, `requiredMessage`, `pattern`,
   `minLength` or `requireUppercase`.
2. **Global configuration** set with `FormValidators.configure`: a
   built-in language, your own `ValidationMessages` subclass, or
   `ValidationRules`.
3. **Built-in default**: the English `ValidationMessages` and the default
   `ValidationRules`.

## Composing validators

`compose` runs validators in order and returns the first error. `null`
entries are skipped, which makes conditional rules easy:

```dart
TextFormField(
  validator: FormValidators.compose([
    FormValidators.email(),
    FormValidators.maxLength(100),
    requireWorkEmail
        ? FormValidators.pattern(
            r'@company\.com$',
            message: 'Use your work email.',
          )
        : null,
  ]),
);
```

### Writing a custom validator

A validator is any `String? Function(String?)`. Return `null` when the value
is valid and an error message otherwise. To follow the package's conventions,
treat an empty value as valid, accept a per-call `message`, and look up the
default message inside the closure so it follows the current locale:

```dart
FormFieldValidator<String> noWhitespace({String? message}) {
  return (value) {
    if (value == null || value.isEmpty) return null;
    if (!value.contains(RegExp(r'\s'))) return null;
    return message ?? LocaleKeys.noWhitespace.tr();
  };
}

FormValidators.compose([FormValidators.required(), noWhitespace()]);
```

## Testing

The configuration is global, so restore it after each test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  tearDown(FormValidators.reset);

  test('uses the custom phone pattern', () {
    FormValidators.configure(
      rules: const ValidationRules(phonePattern: r'^5\d{8}$'),
    );
    expect(FormValidators.phone()('512345678'), isNull);
  });
}
```

## Contributing

Issues and pull requests are welcome on
[GitHub](https://github.com/osamamohamedr1/localized_form_field_validators).
CI checks formatting, analysis, tests and docs on every pull request. If a
national ID or phone rule rejects real numbers, please open an issue with the
format (not a real person's number).

To regenerate the README screenshots on macOS, run
`flutter test screenshots --update-goldens` in `example/`. Releases are
published to pub.dev automatically when a `vX.Y.Z` tag is pushed.

## License

MIT. See [LICENSE](LICENSE).

# localized_form_field_validators

Ready-made validators for Flutter's `TextFormField`. They work out of the box
with English messages and sensible rules, and you can override any message or
rule for the whole app or for a single field.

```dart
TextFormField(validator: FormValidators.email());
```

## Features

- Validators for required fields, length, regular expressions, email, phone,
  "email or phone", login and strong passwords, numbers, and matching fields,
  plus `compose` to combine them.
- English default messages and rules, so no setup is needed.
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
  localized_form_field_validators: ^0.1.0
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
              FormValidators.required(),
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

Every builder returns a `FormFieldValidator<String>`. These rules apply to all
of them:

- **`isRequired`**: when `false`, an empty value is valid, but a value that is
  filled in is still checked.
- **`requiredMessage`** replaces the error for an empty value. **`message`**
  replaces every other error that builder can return.
- Input is **trimmed** before it is checked, except by `password` and
  `strongPassword`. Those check the raw value and treat a value of only
  spaces as empty.
- `null` pattern or rule arguments fall back to the global `ValidationRules`.

| Builder | Parameters | Empty value | Errors (`ValidationMessages` member) |
|---|---|---|---|
| `required` | `message` | error | `required` |
| `minLength` | `int min`, `message` | valid | `minLength(min)` |
| `maxLength` | `int max`, `message` | valid | `maxLength(max)` |
| `lengthBetween` | `int min`, `int max`, `message` | valid | `lengthBetween(min, max)` |
| `pattern` | `String pattern`, `message` | valid | `invalidFormat` |
| `email` | `isRequired`, `pattern`, `requiredMessage`, `message` | `emailRequired` | `invalidEmail` |
| `phone` | `isRequired`, `pattern`, `requiredMessage`, `message` | `phoneRequired` | `invalidPhone` |
| `emailOrPhone` | `isRequired`, `requiredMessage`, `message` | `emailOrPhoneRequired` | `invalidEmail`, `invalidPhone`, `invalidEmailOrPhone` |
| `password` | `isRequired`, `minLength`, `requiredMessage`, `message` | `passwordRequired` | `passwordMinLength(min)` |
| `strongPassword` | `isRequired`, `minLength`, `requireLowercase`, `requireUppercase`, `requireNumber`, `requireSpecialCharacter`, `requiredMessage`, `message` | `passwordRequired` | `passwordMinLength(min)`, `passwordLowercase`, `passwordUppercase`, `passwordNumber`, `passwordSpecialCharacter` |
| `number` | `isRequired`, `min`, `max`, `allowDecimal` (default `true`), `requiredMessage`, `message` | `required` | `invalidNumber`, `numberMin(min)`, `numberMax(max)` |
| `match` | `String? Function() other`, `message` | compared like any value | `valuesDoNotMatch` |
| `compose` | `List<FormFieldValidator<String>?> validators` | depends on the validators | first error from the list |

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
- `strongPassword` checks, in order: minimum length, a lowercase letter
  (`a`–`z`), an uppercase letter (`A`–`Z`), a digit, and a special character.
  It returns the first failure.
- `number` parses with `num.tryParse` and always rejects NaN and infinity.
  With `allowDecimal: false` it accepts whole numbers only, so `5.0` is
  rejected.
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
| `specialCharacterPattern` | `[^A-Za-z0-9\s]` |

The four `passwordRequire*` flags are used only by `strongPassword`.

## Overriding messages globally

Extend `ValidationMessages`, override only the messages you need, and pass an
instance to `FormValidators.configure`. Every message you don't override keeps
its English default.

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

Generated `AppLocalizations` objects are tied to a locale, so wrap the
current instance and call `configure` from `MaterialApp.builder`. The builder
runs below `Localizations` and rebuilds when the locale changes, so the
wrapper is replaced with the new locale's instance.

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        FormValidators.configure(
          messages: L10nValidationMessages(AppLocalizations.of(context)!),
        );
        return child!;
      },
      home: const HomePage(),
    );
  }
}
```

Adjust the `AppLocalizations` import to match your `l10n.yaml`. Projects
that still use the older synthetic package import
`package:flutter_gen/gen_l10n/app_localizations.dart`.

> An error that is already on screen keeps its old text until the field is
> validated again, for example on the next `validate()` call or keystroke
> with `AutovalidateMode.onUserInteraction`.

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
FormValidators.strongPassword(minLength: 12, requireSpecialCharacter: false);
```

Precedence, from highest to lowest:

1. **Per-call argument**, such as `message`, `requiredMessage`, `pattern`,
   `minLength` or `requireUppercase`.
2. **Global configuration** set with `FormValidators.configure`.
3. **Built-in default** from `ValidationMessages` and `ValidationRules`.

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

## License

MIT. See [LICENSE](LICENSE).

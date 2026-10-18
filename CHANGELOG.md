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

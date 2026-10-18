# form_validators_example

A demo sign-up form for the `form_validators` package. It shows:

- **Defaults:** fields that use the built-in English messages and rules.
- **Global override:** `main()` calls `FormValidators.configure` with a
  `ValidationMessages` subclass and an Egyptian/Saudi phone pattern.
- **Per-call override:** the confirm-password field passes its own messages.

Run it with:

```sh
flutter run
```

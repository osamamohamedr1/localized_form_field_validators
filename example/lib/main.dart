import 'package:flutter/material.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  // Global override: applies to every validator in the app, including
  // validators that were built before this call.
  FormValidators.configure(
    messages: const DemoMessages(),
    rules: const ValidationRules().copyWith(
      // Egyptian (010/011/012/015 + 8 digits) or Saudi (5 + 8 digits) mobiles.
      phonePattern: r'^(010|011|012|015)\d{8}$|^5\d{8}$',
    ),
  );
  runApp(const DemoApp());
}

/// App-wide messages. Only these two change; every other message keeps its
/// English default.
class DemoMessages extends ValidationMessages {
  /// Creates the demo messages.
  const DemoMessages();

  @override
  String get emailRequired => 'We need your email to create the account.';

  @override
  String get invalidPhone => 'Enter an Egyptian or Saudi mobile number.';
}

/// The demo application.
class DemoApp extends StatelessWidget {
  /// Creates the demo application.
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'localized_form_field_validators demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const SignUpPage(),
    );
  }
}

/// A sign-up form that uses the validators.
class SignUpPage extends StatefulWidget {
  /// Creates the sign-up page.
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Defaults: built-in messages and rules.
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              validator: FormValidators.compose([
                FormValidators.required(),
                FormValidators.lengthBetween(2, 50),
              ]),
            ),
            // Global override: emailRequired comes from DemoMessages.
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.email(),
            ),
            // Global override: phonePattern and invalidPhone come from
            // main().
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Mobile (optional)',
                hintText: '01012345678 or 512345678',
              ),
              keyboardType: TextInputType.phone,
              validator: FormValidators.phone(isRequired: false),
            ),
            // Defaults, with a range and whole numbers only.
            TextFormField(
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: FormValidators.number(
                min: 18,
                max: 120,
                allowDecimal: false,
              ),
            ),
            // Defaults: length, lowercase, uppercase, number and special
            // character, checked in that order.
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: FormValidators.strongPassword(),
            ),
            // Per-call override: these messages beat the global and default
            // ones.
            TextFormField(
              decoration: const InputDecoration(labelText: 'Confirm password'),
              obscureText: true,
              validator: FormValidators.compose([
                FormValidators.required(
                  message: 'Please confirm your password.',
                ),
                FormValidators.match(
                  () => _password.text,
                  message: 'Passwords must match.',
                ),
              ]),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}

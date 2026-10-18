import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

void main() {
  configureDemoValidators();
  runApp(const DemoApp());
}

/// Sets the app-wide validation rules. Messages come from the localizations
/// delegate in [DemoApp], which follows the app's locale.
void configureDemoValidators() {
  // Global rule override: applies to every validator in the app, including
  // validators that were built before this call.
  FormValidators.configure(
    rules: FormValidators.rules.copyWith(
      phonePattern: PhonePatterns.anyOf([
        PhonePatterns.egypt,
        PhonePatterns.saudiArabia,
      ]),
    ),
  );
}

/// App-wide English messages. Only these two change; every other message
/// keeps its English default.
class DemoMessages extends ValidationMessages {
  /// Creates the demo English messages.
  const DemoMessages();

  @override
  String get emailRequired => 'We need your email to create the account.';

  @override
  String get invalidPhone => 'Enter an Egyptian or Saudi mobile number.';
}

/// App-wide Arabic messages, built on the package's Arabic translation.
class DemoArabicMessages extends ValidationMessagesAr {
  /// Creates the demo Arabic messages.
  const DemoArabicMessages();

  @override
  String get invalidPhone => 'أدخل رقم جوال مصري أو سعودي صحيح.';
}

/// Chooses the validators' messages for the app's locale.
ValidationMessages demoMessagesFor(Locale locale) => locale.languageCode == 'ar'
    ? const DemoArabicMessages()
    : const DemoMessages();

/// The demo application.
class DemoApp extends StatefulWidget {
  /// Creates the demo application.
  const DemoApp({super.key, this.theme});

  /// Replaces the default theme, for example to set fonts for screenshots.
  final ThemeData? theme;

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  Locale _locale = const Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'localized_form_field_validators demo',
      debugShowCheckedModeBanner: false,
      theme: widget.theme ?? ThemeData(colorSchemeSeed: Colors.indigo),
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        // Switches the validators' messages whenever the locale changes.
        ValidationMessagesDelegate(messagesFor: demoMessagesFor),
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: SignUpPage(
        onLanguageChanged: (code) => setState(() => _locale = Locale(code)),
      ),
    );
  }
}

/// A sign-up form that uses the validators.
class SignUpPage extends StatefulWidget {
  /// Creates the sign-up page.
  const SignUpPage({super.key, required this.onLanguageChanged});

  /// Called with `'en'` or `'ar'` when the user picks a language.
  final ValueChanged<String> onLanguageChanged;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  bool _submitted = false;

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  /// The demo's own labels, in the current language.
  String _t(String english, String arabic) => _isArabic ? arabic : english;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _setLanguage(String code) {
    widget.onLanguageChanged(code);
    // The delegate loads the new messages during the next frame. Validate
    // after it so errors that are already on screen switch language too.
    if (_submitted) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _formKey.currentState?.validate(),
      );
    }
  }

  void _submit() {
    _submitted = true;
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('Account created', 'تم إنشاء الحساب'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Sign up', 'إنشاء حساب')),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Language',
            icon: const Icon(Icons.translate),
            initialValue: Localizations.localeOf(context).languageCode,
            onSelected: _setLanguage,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'en', child: Text('English')),
              PopupMenuItem(value: 'ar', child: Text('العربية')),
            ],
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Built-in messages, with the field name in the error.
            TextFormField(
              decoration: InputDecoration(labelText: _t('Name', 'الاسم')),
              validator: FormValidators.compose([
                FormValidators.required(fieldName: _t('Name', 'الاسم')),
                FormValidators.lengthBetween(2, 50),
              ]),
            ),
            // Global message override: emailRequired comes from
            // DemoMessages in English.
            TextFormField(
              decoration: InputDecoration(
                labelText: _t('Email', 'البريد الإلكتروني'),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.email(),
            ),
            // Global rule override: PhonePatterns set in main().
            TextFormField(
              decoration: InputDecoration(
                labelText: _t('Mobile (optional)', 'رقم الجوال (اختياري)'),
                hintText: '01012345678 / 512345678',
              ),
              keyboardType: TextInputType.phone,
              validator: FormValidators.phone(isRequired: false),
            ),
            // Egyptian national ID: format, birth date and governorate.
            TextFormField(
              decoration: InputDecoration(
                labelText: _t(
                  'National ID (optional)',
                  'الرقم القومي (اختياري)',
                ),
                hintText: '29001010123456',
              ),
              keyboardType: TextInputType.number,
              validator: FormValidators.nationalId(
                ArabCountry.egypt,
                isRequired: false,
              ),
            ),
            // Built-in messages, with a range and whole numbers only.
            TextFormField(
              decoration: InputDecoration(labelText: _t('Age', 'العمر')),
              keyboardType: TextInputType.number,
              validator: FormValidators.number(
                min: 18,
                max: 120,
                allowDecimal: false,
              ),
            ),
            // Built-in messages: length, lowercase, uppercase, number and
            // special character, checked in that order.
            TextFormField(
              controller: _password,
              decoration: InputDecoration(
                labelText: _t('Password', 'كلمة المرور'),
              ),
              obscureText: true,
              validator: FormValidators.strongPassword(),
            ),
            // Per-call override: these messages beat the global and default
            // ones. The app translates them itself.
            TextFormField(
              decoration: InputDecoration(
                labelText: _t('Confirm password', 'تأكيد كلمة المرور'),
              ),
              obscureText: true,
              validator: FormValidators.compose([
                FormValidators.required(
                  message: _t(
                    'Please confirm your password.',
                    'يرجى تأكيد كلمة المرور.',
                  ),
                ),
                FormValidators.match(
                  () => _password.text,
                  message: _t(
                    'Passwords must match.',
                    'كلمتا المرور غير متطابقتين.',
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(_t('Create account', 'إنشاء الحساب')),
            ),
          ],
        ),
      ),
    );
  }
}

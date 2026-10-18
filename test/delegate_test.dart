import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';

Widget _app(Locale locale, LocalizationsDelegate<ValidationMessages> delegate) {
  return Localizations(
    locale: locale,
    delegates: [delegate, DefaultWidgetsLocalizations.delegate],
    child: const SizedBox(),
  );
}

ValidationMessages _customMessages(Locale locale) =>
    locale.languageCode == 'ar' ? const _ShortArabic() : const _ShortEnglish();

void main() {
  tearDown(FormValidators.reset);

  testWidgets('FormValidators.delegate follows the locale', (tester) async {
    final validator = FormValidators.required();

    await tester.pumpWidget(_app(const Locale('ar'), FormValidators.delegate));
    expect(FormValidators.messages, isA<ValidationMessagesAr>());
    expect(validator(''), 'هذا الحقل مطلوب.');

    await tester.pumpWidget(_app(const Locale('en'), FormValidators.delegate));
    expect(FormValidators.messages.runtimeType, ValidationMessages);
    expect(validator(''), 'This field is required.');
  });

  testWidgets('uses English for a locale without built-in messages', (
    tester,
  ) async {
    FormValidators.configure(languageCode: 'ar');
    await tester.pumpWidget(_app(const Locale('fr'), FormValidators.delegate));
    expect(FormValidators.messages.runtimeType, ValidationMessages);
  });

  testWidgets('messagesFor chooses the messages per locale', (tester) async {
    const delegate = ValidationMessagesDelegate(messagesFor: _customMessages);

    await tester.pumpWidget(_app(const Locale('ar', 'EG'), delegate));
    expect(FormValidators.required()(''), 'مطلوب');

    await tester.pumpWidget(_app(const Locale('en'), delegate));
    expect(FormValidators.required()(''), 'Required');
  });

  testWidgets('makes the messages available through Localizations', (
    tester,
  ) async {
    late ValidationMessages? fromContext;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('ar'),
        delegates: const [
          FormValidators.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            fromContext = Localizations.of<ValidationMessages>(
              context,
              ValidationMessages,
            );
            return const SizedBox();
          },
        ),
      ),
    );
    expect(fromContext, isA<ValidationMessagesAr>());
  });

  test('shouldReload only when messagesFor changes', () {
    const builtIn = ValidationMessagesDelegate();
    const custom = ValidationMessagesDelegate(messagesFor: _customMessages);
    expect(builtIn.shouldReload(const ValidationMessagesDelegate()), isFalse);
    expect(custom.shouldReload(builtIn), isTrue);
    expect(
      custom.shouldReload(
        const ValidationMessagesDelegate(messagesFor: _customMessages),
      ),
      isFalse,
    );
    expect(builtIn.isSupported(const Locale('ja')), isTrue);
  });
}

class _ShortEnglish extends ValidationMessages {
  const _ShortEnglish();

  @override
  String get required => 'Required';
}

class _ShortArabic extends ValidationMessagesAr {
  const _ShortArabic();

  @override
  String get required => 'مطلوب';
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';
import 'package:localized_form_field_validators_example/main.dart';

Future<void> _submit(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _chooseLanguage(WidgetTester tester, String name) async {
  await tester.tap(find.byTooltip('Language'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(name).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(configureDemoValidators);
  tearDown(FormValidators.reset);

  testWidgets('shows default, global and per-call messages', (tester) async {
    await tester.pumpWidget(const DemoApp());
    await _submit(tester, 'Create account');

    // Built-in message with a field name, and the plain built-in message.
    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('This field is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);
    // Global override.
    expect(
      find.text('We need your email to create the account.'),
      findsOneWidget,
    );
    // Per-call override.
    expect(find.text('Please confirm your password.'), findsOneWidget);
    // Optional fields show no error while empty.
    expect(find.text('Enter a valid national ID number.'), findsNothing);
  });

  testWidgets('switching to Arabic updates the errors on screen', (
    tester,
  ) async {
    await tester.pumpWidget(const DemoApp());
    await _submit(tester, 'Create account');
    expect(find.text('Name is required.'), findsOneWidget);

    await _chooseLanguage(tester, 'العربية');

    expect(find.text('Name is required.'), findsNothing);
    expect(find.text('حقل الاسم مطلوب.'), findsOneWidget);
    expect(find.text('هذا الحقل مطلوب.'), findsOneWidget);
    expect(find.text('البريد الإلكتروني مطلوب.'), findsOneWidget);
    expect(find.text('كلمة المرور مطلوبة.'), findsOneWidget);
    expect(find.text('يرجى تأكيد كلمة المرور.'), findsOneWidget);
    // The Arabic locale lays the form out right to left.
    expect(
      Directionality.of(tester.element(find.byType(Form))),
      TextDirection.rtl,
    );

    await _chooseLanguage(tester, 'English');
    expect(find.text('Name is required.'), findsOneWidget);
    expect(
      find.text('We need your email to create the account.'),
      findsOneWidget,
    );
  });

  testWidgets('validates phone and national ID when filled', (tester) async {
    await tester.pumpWidget(const DemoApp());
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(2), '44123456');
    await tester.enterText(fields.at(3), '29013010123456');
    await _submit(tester, 'Create account');

    expect(
      find.text('Enter an Egyptian or Saudi mobile number.'),
      findsOneWidget,
    );
    expect(find.text('Enter a valid national ID number.'), findsOneWidget);
  });

  testWidgets('accepts a valid form', (tester) async {
    await tester.pumpWidget(const DemoApp());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sara');
    await tester.enterText(fields.at(1), 'sara@example.com');
    await tester.enterText(fields.at(2), '01012345678');
    await tester.enterText(fields.at(3), '29001010123456');
    await tester.enterText(fields.at(4), '30');
    await tester.enterText(fields.at(5), 'Secret1!');
    await tester.enterText(fields.at(6), 'Secret1!');
    await _submit(tester, 'Create account');

    expect(find.text('Account created'), findsOneWidget);
  });
}

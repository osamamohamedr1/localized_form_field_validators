import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';
import 'package:localized_form_field_validators_example/main.dart';

void main() {
  setUp(() => FormValidators.configure(messages: const DemoMessages()));
  tearDown(FormValidators.reset);

  testWidgets('shows default, global and per-call messages', (tester) async {
    await tester.pumpWidget(const DemoApp());

    await tester.tap(find.text('Create account'));
    await tester.pump();

    // Default message.
    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(find.text('Password is required.'), findsOneWidget);
    // Global override.
    expect(
      find.text('We need your email to create the account.'),
      findsOneWidget,
    );
    // Per-call override.
    expect(find.text('Please confirm your password.'), findsOneWidget);
    // The optional phone field shows no error while empty.
    expect(
      find.text('Enter an Egyptian or Saudi mobile number.'),
      findsNothing,
    );
  });

  testWidgets('accepts a valid form', (tester) async {
    await tester.pumpWidget(const DemoApp());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sara');
    await tester.enterText(fields.at(1), 'sara@example.com');
    await tester.enterText(fields.at(2), '01012345678');
    await tester.enterText(fields.at(3), '30');
    await tester.enterText(fields.at(4), 'Secret1!');
    await tester.enterText(fields.at(5), 'Secret1!');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Account created'), findsOneWidget);
  });
}

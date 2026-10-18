// Renders the pub.dev screenshots in doc/screenshots/. Run it on macOS from
// the example directory:
//
//   flutter test screenshots --update-goldens
//
// It is outside test/, so `flutter test` and CI don't run it.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localized_form_field_validators/localized_form_field_validators.dart';
import 'package:localized_form_field_validators_example/main.dart';

const _arabicFontPath = '/System/Library/Fonts/SFArabic.ttf';

/// The Flutter SDK's bundled Material fonts, found from the test runner's
/// location: `<flutter>/bin/cache/artifacts/engine/<platform>/flutter_tester`.
Directory _materialFonts() {
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  return Directory('${artifacts.path}/material_fonts');
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  final fonts = _materialFonts().path;
  final canRun =
      File(_arabicFontPath).existsSync() &&
      File('$fonts/Roboto-Regular.ttf').existsSync();

  setUpAll(() async {
    if (!canRun) return;
    await _loadFont('Roboto', [
      '$fonts/Roboto-Regular.ttf',
      '$fonts/Roboto-Medium.ttf',
    ]);
    await _loadFont('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
    await _loadFont('SF Arabic', [_arabicFontPath]);
  });

  setUp(configureDemoValidators);
  tearDown(FormValidators.reset);

  Future<void> render(
    WidgetTester tester,
    String file, {
    bool arabic = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    debugDisableShadows = false;

    await tester.pumpWidget(
      DemoApp(
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['SF Arabic'],
        ),
      ),
    );
    if (arabic) {
      await tester.tap(find.byTooltip('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية').last);
      await tester.pumpAndSettle();
    }

    // Fill a few fields with invalid values, then submit to show errors.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'sara@example');
    await tester.enterText(fields.at(2), '0131234567');
    await tester.enterText(fields.at(5), 'secret');
    final submit = find.byType(FilledButton);
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.drag(find.byType(ListView), const Offset(0, 1000));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../doc/screenshots/$file'),
    );
    debugDisableShadows = true;
  }

  testWidgets('English', (tester) async {
    await render(tester, 'english.png');
  }, skip: !canRun);

  testWidgets('Arabic', (tester) async {
    await render(tester, 'arabic.png', arabic: true);
  }, skip: !canRun);
}

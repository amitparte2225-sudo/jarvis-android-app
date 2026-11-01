
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_app/app.dart';
import 'package:jarvis_app/core/auth/auth_controller.dart';
import 'package:jarvis_app/core/auth/pin_service.dart';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'memory_store.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(
      const Duration(milliseconds: 100),
    );
  }
}

void main() {

  // SQLite initialization for Flutter tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('fresh install asks to create a PIN',
      (tester) async {
    final auth = AuthController(
      PinService(MemoryStore(), iterations: 10),
    );

    await tester.pumpWidget(JarvisApp(auth: auth));
    await settle(tester);

    expect(find.text('Create your PIN'), findsOneWidget);
  });

  testWidgets(
      'creating a PIN opens the home screen, lock returns to unlock',
      (tester) async {
    final auth = AuthController(
      PinService(MemoryStore(), iterations: 10),
    );

    await tester.pumpWidget(JarvisApp(auth: auth));
    await settle(tester);

    await tester.enterText(
      find.byType(TextField).at(0),
      '2468',
    );

    await tester.enterText(
      find.byType(TextField).at(1),
      '2468',
    );

    await tester.tap(find.text('Save PIN'));
    await settle(tester);

    expect(find.text('Ask JARVIS'), findsOneWidget);

    await tester.tap(find.byTooltip('Lock'));
    await settle(tester);

    expect(find.text('JARVIS is locked'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      '2468',
    );

    await tester.tap(find.text('Unlock'));
    await settle(tester);

    expect(find.text('Ask JARVIS'), findsOneWidget);
  });
}

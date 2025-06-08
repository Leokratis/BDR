// Blood Donation Registry - Widget Tests
//
// Basic widget tests for the Blood Donation Registry Flutter app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bdr_app/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app loads successfully
    // Should show either loading indicator or authentication screen
    expect(
      find.byType(MaterialApp),
      findsOneWidget,
    );
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Blood Donation Registry');
  });
}

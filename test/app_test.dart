import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bdr_app/main.dart';
import 'package:bdr_app/providers/auth_provider.dart';

void main() {
  group('Blood Donation Registry App Tests', () {
    testWidgets('App should start with authentication screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());
      
      // Wait for any async operations
      await tester.pumpAndSettle();

      // Verify that the app shows either loading or auth screen initially
      expect(
        find.byType(CircularProgressIndicator)
            .or(find.text('Blood Donation Registry'))
            .or(find.text('Login')),
        findsWidgets,
      );
    });

    testWidgets('AuthProvider should initialize correctly', (WidgetTester tester) async {
      // Create an AuthProvider
      final authProvider = AuthProvider();
      
      // Verify initial state
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.isLoading, false);
      expect(authProvider.token, null);
    });

    testWidgets('App should show authentication screen when not authenticated', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(),
            ),
          ],
          child: MaterialApp(
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  return const Scaffold(body: Text('Home Screen'));
                }
                return const Scaffold(body: Text('Authentication Required'));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show authentication required since no token is set
      expect(find.text('Authentication Required'), findsOneWidget);
      expect(find.text('Home Screen'), findsNothing);
    });

    test('AuthProvider token management', () {
      final authProvider = AuthProvider();
      
      // Test setting a token
      const testToken = 'test_token_123';
      authProvider.setToken(testToken);
      
      expect(authProvider.token, testToken);
      expect(authProvider.isAuthenticated, true);
      
      // Test clearing token
      authProvider.logout();
      expect(authProvider.token, null);
      expect(authProvider.isAuthenticated, false);
    });
  });

  group('Widget Tests', () {
    testWidgets('MyApp should have correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      expect(materialApp.title, 'Blood Donation Registry');
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('App should use correct theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify theme is set
      expect(materialApp.theme, isNotNull);
    });
  });
}

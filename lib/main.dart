import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Ensure Flutter bindings are initialized for async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuthStatus(), // Initialize and check auth status
      child: Consumer<AuthProvider>( // Use Consumer here to rebuild MaterialApp if needed
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Blood Donation Registry',
            theme: AppTheme.lightTheme,
            // Use a nested navigator for home screen to manage its own back stack
            home: authProvider.isLoading
                ? const Scaffold( // Global loading screen
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Initializing...'),
                        ],
                      ),
                    ),
                  )
                : authProvider.isAuthenticated
                    ? const HomeScreen() // Or a Navigator wrapping HomeScreen if it has sub-routes
                    : const AuthScreen(),
            routes: {
              // Define routes for navigation. AuthScreen and HomeScreen are handled by 'home' logic.
              // Add other routes here if necessary.
              // Example: '/profile': (context) => const ProfileScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// AuthWrapper is no longer strictly necessary with the new MyApp structure,
// but if you prefer to keep it, ensure it correctly uses the AuthProvider.
// For this refactor, I've integrated its logic into MyApp.
/*
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // AuthProvider is now initialized and checkAuthStatus called in MyApp's ChangeNotifierProvider
    // If you keep AuthWrapper, you might not need to call checkAuthStatus here again
    // or ensure it doesn't conflict.
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}
*/

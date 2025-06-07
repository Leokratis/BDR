import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkForToken();
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://service.bdr.gr'));
  }

  Future<void> _checkForToken() async {
    try {
      // Extract X-Auth-Token from cookies or headers
      final cookies = await _controller.runJavaScriptReturningResult(
        'document.cookie',
      );
      
      // Check if there's an auth token in local storage or session storage
      final authToken = await _controller.runJavaScriptReturningResult(
        'localStorage.getItem("X-Auth-Token") || sessionStorage.getItem("X-Auth-Token") || ""',
      );

      String? token;
      if (authToken is String && authToken.isNotEmpty && authToken != '""') {
        token = authToken.replaceAll('"', '');
      }

      // Alternative: Check for token in headers or look for specific patterns
      if (token == null || token.isEmpty) {
        // Try to get token from document
        final documentToken = await _controller.runJavaScriptReturningResult(
          '''
          var token = '';
          var metaTags = document.getElementsByTagName('meta');
          for (var i = 0; i < metaTags.length; i++) {
            if (metaTags[i].getAttribute('name') === 'x-auth-token') {
              token = metaTags[i].getAttribute('content');
              break;
            }
          }
          token;
          '''
        );
        
        if (documentToken is String && documentToken.isNotEmpty) {
          token = documentToken;
        }
      }

      if (token != null && token.isNotEmpty) {
        if (!mounted) return;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.setAuthToken(token);
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      debugPrint('Error checking for token: $e');
    }
  }

  Future<void> _manualTokenEntry() async {
    final TextEditingController tokenController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Authentication Token'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'If you have obtained the X-Auth-Token manually, please enter it below:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'X-Auth-Token',
                hintText: 'Enter your authentication token',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = tokenController.text.trim();
              if (token.isNotEmpty) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.setAuthToken(token);
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              }
            },
            child: const Text('Save Token'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Donation Registry'),
        actions: [
          IconButton(
            onPressed: _manualTokenEntry,
            icon: const Icon(Icons.key),
            tooltip: 'Manual Token Entry',
          ),
          IconButton(
            onPressed: () {
              _controller.reload();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Instructions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Log in to your account on service.bdr.gr\n'
              '2. The app will automatically detect your authentication token\n'
              '3. If automatic detection fails, use the key icon to enter it manually',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Check for Token',
              onPressed: _checkForToken,
              variant: ButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

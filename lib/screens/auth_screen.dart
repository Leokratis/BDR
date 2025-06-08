import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _isCheckingToken = false; // Prevent multiple token checks

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000)) // Optional: for transparency
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Only attempt to check for token if not already doing so
            if (!_isCheckingToken) {
              _checkForToken();
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
            ''');
            // Optionally show an error message to the user
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Page loading error: ${error.description}')),
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // You might want to restrict navigation to certain domains
            // if (request.url.startsWith('https://your-allowed-domain.com')) {
            //   return NavigationDecision.navigate;
            // }
            // return NavigationDecision.prevent;
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'AuthTokenChannel', // Name this channel
        onMessageReceived: (JavaScriptMessage message) {
          // This message is sent from JavaScript when the token is available
          final String token = message.message;
          if (token.isNotEmpty) {
            _handleTokenFound(token);
          }
        },
      )
      ..loadRequest(Uri.parse('https://service.bdr.gr')); // Your auth URL
  }

  Future<void> _checkForToken() async {
    if (_isCheckingToken || !mounted) return;

    setState(() {
      _isCheckingToken = true;
      _isLoading = true; // Show loading indicator while checking token
    });

    try {
      // Attempt to get the token from localStorage or sessionStorage
      // Ask the web page to send the token via the JavaScriptChannel
      await _controller.runJavaScript(
        '''

        (function() {
          const token = localStorage.getItem("X-Auth-Token") || sessionStorage.getItem("X-Auth-Token");
          if (token) {
            AuthTokenChannel.postMessage(token);
          } else {
            // If no token immediately, maybe the page needs more time or user interaction.
            // Consider a slight delay or alternative checks if needed.
            // For now, if not found, the timeout will handle UI.
            console.log("Auth token not found in localStorage or sessionStorage.");
          }
        })();
        '''
      );
      // The token will be handled by the onMessageReceived callback of AuthTokenChannel
    } catch (e) {
      debugPrint('Error running JavaScript to check for token: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error communicating with login page: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        // If the channel doesn't receive a token after a timeout, stop loading.
        // This timeout is a fallback.
        Future.delayed(const Duration(seconds: 7), () { // Increased timeout slightly
          if (mounted && _isCheckingToken) { // Check _isCheckingToken before setting state
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (!authProvider.isAuthenticated) { // Only stop loading if not authenticated
                 setState(() {
                    _isLoading = false;
                    _isCheckingToken = false;
                 });
                 debugPrint("Token check timed out or token not found via channel.");
            }
          }
        });
      }
    }
  }
  Future<void> _handleTokenFound(String token) async {
    if (!mounted) return;
    
    // Clean the token if it's wrapped in quotes (common from JS)
    String cleanedToken = token;
    if (token.startsWith('"') && token.endsWith('"')) {
      cleanedToken = token.substring(1, token.length - 1);
    }
    if (cleanedToken.isEmpty) {
        debugPrint("Received an empty token.");
        setState(() {
            _isLoading = false;
            _isCheckingToken = false;
        });
        return;
    }

    debugPrint("Auth Token Received via Channel: $cleanedToken");

    // Extract userId from token structure: userId|userType|token
    String? userId;
    try {
      final tokenParts = cleanedToken.split('|');
      if (tokenParts.length >= 3) {
        userId = tokenParts[0]; // First part should be the user ID
        debugPrint("Extracted userId from token: '$userId'");
      } else {
        debugPrint("Token doesn't match expected format (userId|userType|token), using token as-is");
      }
    } catch (e) {
      debugPrint("Error extracting userId from token: $e");
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.setAuthToken(cleanedToken, userId: userId);

    if (mounted && authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted) {
      // Token was found but validation failed or something else went wrong
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to authenticate with the provided token.')),
      );
      setState(() {
        _isLoading = false;
        _isCheckingToken = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // We'll handle pop manually or allow exit
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return; // Already handled by a child navigator or another PopScope
        }
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          // If WebView can't go back, and we are on the AuthScreen, exit the app.
          // You might want to show a confirmation dialog here.
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            // Overlay for manual token entry link
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                color: Colors.black.withOpacity(0.8), // Semi-transparent background
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Problems logging in? ',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Enter token manually',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent, // Make it look like a link
                            fontSize: 12,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _manualTokenEntry();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Manual token entry method (reintegrated)
  Future<void> _manualTokenEntry() async {
    String? enteredToken;
    // Ensure any WebView loading/checking is paused or reset
    if (mounted) {
      setState(() {
        _isLoading = false; // Hide webview loading indicator
        _isCheckingToken = false; // Stop any ongoing token checks via webview
      });
    }

    await showDialog<String>(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (BuildContext dialogContext) {
        TextEditingController tokenController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Token Manually'),
          content: TextField(
            controller: tokenController,
            decoration: const InputDecoration(hintText: "Paste token here"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Optionally re-trigger webview loading if needed, or simply allow user to retry webview
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                enteredToken = tokenController.text.trim();
                Navigator.of(dialogContext).pop(enteredToken);
              },
            ),
          ],
        );
      },
    );

    if (enteredToken != null && enteredToken!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = true; // Show loading while processing manual token
          _isCheckingToken = true; // To align with the flow, will be reset in _handleTokenFound
        });
      }
      await _handleTokenFound(enteredToken!);
    } else {
      // If no token entered or dialog cancelled, ensure loading state is false
      if (mounted && _isLoading) { // Only set state if it was true
          setState(() {
            _isLoading = false;
            _isCheckingToken = false;
          });
      }
      // User might want to try WebView again, or the link again.
      // Consider if _initializeWebView() or _checkForToken() should be called if WebView was primary method.
    }
  }
}

// Ensure the rest of the class (like _handleTokenFound, _initializeWebView, etc.) is present
// ... (existing _AuthScreenState methods like _initializeWebView, _checkForToken, _handleTokenFound)

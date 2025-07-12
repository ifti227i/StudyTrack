import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'profiles.dart';

class OAuthWebView extends StatefulWidget {
  final String accountType;
  final VoidCallback onLogout;

  const OAuthWebView({
    super.key,
    required this.accountType,
    required this.onLogout,
  });

  @override
  State<OAuthWebView> createState() => _OAuthWebViewState();
}

class _OAuthWebViewState extends State<OAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _userEmail;
  bool _authCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar based on WebView loading progress
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

            // Check if we've been redirected to a success page or user page
            if (url.contains('success') ||
                url.contains('user') ||
                url.contains('auth')) {
              _handleAuthSuccess(url);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle navigation requests
            if (request.url.contains('localhost:8080/user')) {
              _handleAuthSuccess(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('http://192.168.56.1:8080/oauth2/authorization/google'),
      );
  }

  void _handleAuthSuccess(String url) async {
    if (_authCompleted) return;

    setState(() {
      _authCompleted = true;
    });

    try {
      // Try to get user info from the backend's auth/success endpoint
      final response = await _controller.runJavaScriptReturningResult(
        'fetch("/auth/success").then(r => r.text())',
      );

      // Parse the response to extract user email
      if (response.toString().contains('email')) {
        // Try to extract email from JSON response
        try {
          final responseText = response.toString();
          if (responseText.contains('"email"')) {
            final emailMatch = RegExp(
              r'"email"\s*:\s*"([^"]+)"',
            ).firstMatch(responseText);
            if (emailMatch != null) {
              _userEmail = emailMatch.group(1);
            }
          }
        } catch (e) {
          _userEmail = 'googleuser@example.com';
        }
      } else {
        _userEmail = 'googleuser@example.com';
      }

      // Navigate to profile screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              accountType: widget.accountType,
              email: _userEmail ?? 'googleuser@example.com',
              onLogout: widget.onLogout,
            ),
          ),
        );
      }
    } catch (e) {
      // If we can't parse the response, still proceed with default email
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              accountType: widget.accountType,
              email: 'googleuser@example.com',
              onLogout: widget.onLogout,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        title: const Text('Sign in with Google'),
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: null, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to Google...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

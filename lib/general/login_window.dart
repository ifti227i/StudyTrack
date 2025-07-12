import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  final void Function(GoogleSignInAccount user, String accountType)? onLogin;
  const LoginScreen({super.key, this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _accountType = 'Student';
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleSignInLoading = false;
  bool _isGoogleSignUpLoading = false;

  // Spring Boot backend URL
  static const String backendUrl = 'http://192.168.56.1:8080';

  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        // For now, we'll simulate a login since we don't have traditional login in Spring Boot
        // In a real app, you'd call your backend's login endpoint
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call

        // REMOVE navigation to CalendarScreen here
        // Let the parent widget handle navigation after login
        // If you want to support non-Google login, call widget.onLogin with a mock GoogleSignInAccount or similar
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
    }
  }

  void _initiateGoogleSignIn({required bool isSignUp}) async {
    setState(() {
      if (isSignUp) {
        _isGoogleSignUpLoading = true;
      } else {
        _isGoogleSignInLoading = true;
      }
    });

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        // Restrict Student and Teacher to @diu.edu.bd emails
        if ((_accountType == 'Student' || _accountType == 'Teacher') &&
            !(account.email.endsWith('@diu.edu.bd'))) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Only @diu.edu.bd emails are allowed for Student and Teacher accounts.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _isGoogleSignInLoading = false;
            _isGoogleSignUpLoading = false;
          });
          return;
        }
        final GoogleSignInAuthentication auth = await account.authentication;
        await _authenticateWithBackend(
          account.email,
          auth.accessToken,
          account.displayName,
          null,
          null,
        );
        if (mounted && widget.onLogin != null) {
          widget.onLogin!(account, _accountType);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign-in failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSignInLoading = false;
          _isGoogleSignUpLoading = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBackend(
    String email,
    String? accessToken,
    String? name,
    String? section,
    String? department,
  ) async {
    try {
      // Send authentication data to your Spring Boot backend
      final response = await http.post(
        Uri.parse('$backendUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'accessToken': accessToken,
          'name': name,
          'section': section,
          'department': department,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Backend authentication failed');
      }
    } catch (e) {
      // For now, we'll continue even if backend is not available
      print('Backend authentication error: $e');
    }
  }

  void _showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController emailController = TextEditingController();
        final TextEditingController passwordController =
            TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sign up successful! (Demo only)'),
                  ),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 2;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/22.png',
                    width: 320,
                    height: 320,
                  ),
                ),
                const SizedBox(height: 0.5),
                // Email label and example
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _accountType == 'Personal'
                        ? 'example@gmail.com'
                        : 'your.name@diu.edu.bd',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF23232A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 29, 53),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF23232A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 29, 53),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Account Type',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _accountTypeButton('Student'),
                    _accountTypeButton('Teacher'),
                    _accountTypeButton('Personal'),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 29, 53),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                // Removed the Sign Up text/button for a cleaner UI as per request
                // TextButton(
                //   onPressed: _showSignUpDialog,
                //   child: const Text(
                //     "Don't have an account? Sign Up",
                //     style: TextStyle(color: Colors.white),
                //   ),
                // ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 24),
                _googleButton('Continue with Google', isSignUp: false),
                const SizedBox(height: 16),
                _googleButton('Sign Up with Google', isSignUp: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _accountTypeButton(String type) {
    final bool isSelected = _accountType == type;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.white10 : Colors.transparent,
            side: BorderSide(
              color: isSelected ? Colors.white : Colors.white24,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            setState(() {
              _accountType = type;
            });
          },
          child: Text(
            type,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleButton(String text, {required bool isSignUp}) {
    final bool isLoading = isSignUp
        ? _isGoogleSignUpLoading
        : _isGoogleSignInLoading;
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: Colors.white24, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.g_mobiledata, color: Colors.white, size: 32),
        label: isLoading
            ? const Text(
                'Signing in...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
        onPressed: isLoading
            ? null
            : () {
                _initiateGoogleSignIn(isSignUp: isSignUp);
              },
      ),
    );
  }
}

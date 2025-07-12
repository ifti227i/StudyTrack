import 'package:flutter/material.dart';
import 'general/calendar_screen.dart';
import 'general/login_window.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleSignInAccount? _user;
  String? _accountType;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Remove theme mode and toggle logic

  @override
  void initState() {
    super.initState();
    _checkSignIn();
  }

  Future<void> _checkSignIn() async {
    final user = await _googleSignIn.signInSilently();
    setState(() {
      _user = user;
    });
  }

  void _onLogin(GoogleSignInAccount user, String accountType) {
    setState(() {
      _user = user;
      _accountType = accountType;
    });
  }

  void _onLogout() async {
    await _googleSignIn.signOut();
    setState(() {
      _user = null;
      _accountType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyTrack',
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: _user == null
          ? LoginScreen(onLogin: _onLogin)
          : CalendarScreen(
              user: _user!,
              onLogout: _onLogout,
              accountType: _accountType ?? 'Student',
            ),
    );
  }
}

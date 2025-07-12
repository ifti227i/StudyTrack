import 'package:flutter/material.dart';
import '../student/profile_student.dart';
import '../teacher/profile_teacher.dart';
import '../personal/profile_personal.dart';

class ProfileScreen extends StatelessWidget {
  final String accountType;
  final String email;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.accountType,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    switch (accountType) {
      case 'Student':
        return StudentProfileScreen(email: email, onLogout: onLogout);
      case 'Teacher':
        return TeacherProfileScreen(email: email, onLogout: onLogout);
      case 'Personal':
        return PersonalProfileScreen(email: email, onLogout: onLogout);
      default:
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: Text(
              'Unknown Account Type',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 22,
              ),
            ),
          ),
        );
    }
  }
}

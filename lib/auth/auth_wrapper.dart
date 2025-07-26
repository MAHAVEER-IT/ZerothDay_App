import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student_provider.dart';
import 'login_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (_, studentProvider, __) =>
          studentProvider.isAuthenticated ? HomeScreen() : LoginScreen(),
    );
  }
}

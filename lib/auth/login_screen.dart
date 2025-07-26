import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'student_provider.dart';
import '../widgets/graduate_cap_icon.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Login'),
        backgroundColor: Color(0xFF87CEEB), // Sky blue
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GraduateCapIcon(
                size: 120.0,
                color: Color(0xFF87CEEB),
              ), // Sky blue
              SizedBox(height: 24.0),
              Text(
                'Sri Eshwar College Student Login',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5CACEE), // Darker sky blue
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                'Sign in with your college email address',
                style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.0),
              Consumer<StudentProvider>(
                builder: (context, studentProvider, _) {
                  if (studentProvider.isLoading) {
                    return CircularProgressIndicator();
                  }
                  return ElevatedButton.icon(
                    icon: Icon(Icons.login),
                    label: Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5CACEE), // Darker sky blue
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    onPressed: _isLoading ? null : _signInWithGoogle,
                  );
                },
              ),
              SizedBox(height: 16.0),
              Consumer<StudentProvider>(
                builder: (context, studentProvider, _) {
                  if (studentProvider.error != null) {
                    return Container(
                      padding: EdgeInsets.all(16),
                      color: Colors.red[50],
                      child: Text(
                        studentProvider.error!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              SizedBox(height: 24.0),
              Text(
                '* Only @sece.ac.in email addresses are allowed',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      final success = await studentProvider.signInWithGoogle();

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

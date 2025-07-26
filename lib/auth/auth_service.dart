import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'student_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Server API URL - using 10.0.2.2 for Android emulator to connect to localhost
  final String _baseUrl = 'http://10.0.2.2:5000/api/auth';

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User canceled the sign-in flow
      }

      // Check if the email domain is valid
      if (!googleUser.email.endsWith('@sece.ac.in')) {
        await _googleSignIn.signOut();
        throw Exception('Only @sece.ac.in email addresses are allowed.');
      }

      // Get auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Verify token with our backend
      await verifyTokenWithBackend();

      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      await signOut(); // Sign out if there's an error
      rethrow;
    }
  }

  // Verify Firebase token with our backend
  Future<StudentModel> verifyTokenWithBackend() async {
    try {
      // Get the current user's ID token
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      String? token = await user.getIdToken();
      if (token == null) {
        throw Exception('Failed to get ID token');
      }

      // Send the token to our backend
      final response = await http.post(
        Uri.parse('$_baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse and save the student data
        final data = jsonDecode(response.body);
        final studentData = data['student'];

        // Process the student data safely
        final safeStudentData = _processSafeStudentData(studentData);

        final student = StudentModel.fromJson(safeStudentData);

        // Save student data to shared preferences
        await _saveStudentData(student);

        return student;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Failed to verify token with backend',
        );
      }
    } catch (e) {
      print('Error verifying token with backend: $e');
      rethrow;
    }
  }

  // Get student profile from backend
  Future<StudentModel> getStudentProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/profile/${user.uid}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final studentData = data['student'];

        // Process the student data safely
        final safeStudentData = _processSafeStudentData(studentData);

        final student = StudentModel.fromJson(safeStudentData);
        await _saveStudentData(student);
        return student;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get student profile');
      }
    } catch (e) {
      print('Error getting student profile: $e');
      rethrow;
    }
  }

  // Update student profile
  Future<StudentModel> updateStudentProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/profile/${user.uid}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final studentData = data['student'];

        // Process the student data safely
        final safeStudentData = _processSafeStudentData(studentData);

        final updatedStudent = StudentModel.fromJson(safeStudentData);
        await _saveStudentData(updatedStudent);
        return updatedStudent;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update student profile');
      }
    } catch (e) {
      print('Error updating student profile: $e');
      rethrow;
    }
  }

  // Save student data to shared preferences
  Future<void> _saveStudentData(StudentModel student) async {
    final prefs = await SharedPreferences.getInstance();

    // Use the model's toJson method to maintain consistency
    final studentJson = jsonEncode(student.toJson());
    await prefs.setString('studentData', studentJson);
  }

  // Load student data from shared preferences
  Future<StudentModel?> loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final studentJson = prefs.getString('studentData');

    if (studentJson == null) {
      return null;
    }

    return StudentModel.fromJson(jsonDecode(studentJson));
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Clear stored student data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('studentData');
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Helper method to safely process student data from API
  Map<String, dynamic> _processSafeStudentData(
    Map<String, dynamic> studentData,
  ) {
    // Create a safer version by handling potential timestamp issues
    final safeStudentData = Map<String, dynamic>.from(studentData);

    // Process timestamps safely
    final timestampFields = ['lastLoginTime', 'createdAt'];
    for (final field in timestampFields) {
      if (safeStudentData.containsKey(field) &&
          safeStudentData[field] != null) {
        try {
          // Try to access properties to check if it's valid
          safeStudentData[field].toString();
        } catch (e) {
          // If it fails, store it as the current time
          safeStudentData[field] = DateTime.now().toIso8601String();
        }
      }
    }

    return safeStudentData;
  }
}

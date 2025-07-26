import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'student_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Collection reference for students
  final CollectionReference _studentsCollection = FirebaseFirestore.instance
      .collection('Students');

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

      // Create or update student record
      await _createOrUpdateStudentRecord(userCredential.user!);

      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      await signOut(); // Sign out if there's an error
      rethrow;
    }
  }

  // Parse student information from email
  Map<String, dynamic> _parseStudentEmail(String email) {
    if (!email.endsWith('@sece.ac.in')) {
      throw Exception(
        'Invalid email domain. Only @sece.ac.in emails are allowed.',
      );
    }

    final localPart = email.split('@')[0].toLowerCase();

    // Extract name (everything before the year) and year+department
    final match = RegExp(r'^(.+?)(\d{4})([a-z]+)$').firstMatch(localPart);
    if (match == null) {
      throw Exception(
        'Invalid email format. Expected format: name.year+department@sece.ac.in',
      );
    }

    final nameWithDot = match.group(1)!;
    final year = match.group(2)!;
    final department = match.group(3)!;

    // Convert dots to spaces for name and clean it up
    final name = nameWithDot
        .replaceAll('.', ' ')
        .trim()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '',
        )
        .join(' ');

    return {
      'name': name,
      'year': year,
      'department': department.toUpperCase(),
      'email': email.toLowerCase(),
    };
  }

  // Create or update student record in Firestore
  Future<StudentModel> _createOrUpdateStudentRecord(User user) async {
    final uid = user.uid;
    final email = user.email!;
    final studentRef = _studentsCollection.doc(uid);

    // Check if student already exists
    final studentDoc = await studentRef.get();

    if (studentDoc.exists) {
      // Update existing student's last login time
      await studentRef.update({'lastLoginTime': FieldValue.serverTimestamp()});

      // Get updated student data
      final updatedDoc = await studentRef.get();
      final studentData = updatedDoc.data() as Map<String, dynamic>;

      // Process the student data safely
      final safeStudentData = _processSafeStudentData(studentData);

      final student = StudentModel.fromJson(safeStudentData);
      await _saveStudentData(student);
      return student;
    } else {
      // Parse student information from email
      final studentInfo = _parseStudentEmail(email);

      // Create new student document
      final studentData = {
        'uid': uid,
        'name': studentInfo['name'],
        'email': email,
        'department': studentInfo['department'],
        'year': studentInfo['year'],
        'lastLoginTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await studentRef.set(studentData);

      // Get the created student data
      final createdDoc = await studentRef.get();
      final createdData = createdDoc.data() as Map<String, dynamic>;

      // Process the student data safely
      final safeStudentData = _processSafeStudentData(createdData);

      final student = StudentModel.fromJson(safeStudentData);
      await _saveStudentData(student);
      return student;
    }
  }

  // Get student profile from Firestore
  Future<StudentModel> getStudentProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final studentDoc = await _studentsCollection.doc(user.uid).get();

      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;

        // Process the student data safely
        final safeStudentData = _processSafeStudentData(studentData);

        final student = StudentModel.fromJson(safeStudentData);
        await _saveStudentData(student);
        return student;
      } else {
        throw Exception('Student profile not found');
      }
    } catch (e) {
      print('Error getting student profile: $e');
      rethrow;
    }
  }

  // Update student profile in Firestore
  Future<StudentModel> updateStudentProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Validate update data
      _validateProfileUpdateData(profileData);

      final studentRef = _studentsCollection.doc(user.uid);

      // Check if student exists
      final studentDoc = await studentRef.get();
      if (!studentDoc.exists) {
        throw Exception('Student profile not found');
      }

      // Update student data
      await studentRef.update({
        ...profileData,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Get updated student data
      final updatedDoc = await studentRef.get();
      final updatedData = updatedDoc.data() as Map<String, dynamic>;

      // Process the student data safely
      final safeStudentData = _processSafeStudentData(updatedData);

      final student = StudentModel.fromJson(safeStudentData);
      await _saveStudentData(student);
      return student;
    } catch (e) {
      print('Error updating student profile: $e');
      rethrow;
    }
  }

  // Validate profile update data
  void _validateProfileUpdateData(Map<String, dynamic> updateData) {
    final List<String> errors = [];

    // Check for forbidden fields
    final forbiddenFields = [
      'uid',
      'email',
      'name',
      'department',
      'year',
      'createdAt',
    ];
    for (final field in forbiddenFields) {
      if (updateData.containsKey(field)) {
        errors.add("Field '$field' cannot be updated");
      }
    }

    // Field-specific validation
    if (updateData.containsKey('Hosterler')) {
      final hosteler = updateData['Hosterler'];
      if (hosteler != 'Yes' && hosteler != 'No') {
        errors.add('Hosterler must be either "Yes" or "No"');
      }

      // If hosteler is No, Block and Roomnumber should be null
      if (hosteler == 'No') {
        updateData['Block'] = null;
        updateData['Roomnumber'] = null;
      }

      // If hosteler is Yes, validate Block and Roomnumber
      if (hosteler == 'Yes') {
        if (!updateData.containsKey('Block') ||
            updateData['Block'] == null ||
            updateData['Block'].toString().trim().isEmpty) {
          errors.add('Block is required for hostelers');
        }
        if (!updateData.containsKey('Roomnumber') ||
            updateData['Roomnumber'] == null ||
            updateData['Roomnumber'].toString().trim().isEmpty) {
          errors.add('Room number is required for hostelers');
        }
      }
    }

    if (updateData.containsKey('Gender')) {
      final gender = updateData['Gender'];
      if (gender != null &&
          gender != 'Male' &&
          gender != 'Female' &&
          gender != 'Other') {
        errors.add('Gender must be "Male", "Female", or "Other"');
      }
    }

    if (errors.isNotEmpty) {
      throw Exception(errors.join('. '));
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

  // Helper method to safely process student data from Firestore
  Map<String, dynamic> _processSafeStudentData(
    Map<String, dynamic> studentData,
  ) {
    // Create a safer version by handling potential timestamp issues
    final safeStudentData = Map<String, dynamic>.from(studentData);

    // Process timestamps safely
    final timestampFields = ['lastLoginTime', 'createdAt', 'lastUpdated'];
    for (final field in timestampFields) {
      if (safeStudentData.containsKey(field) &&
          safeStudentData[field] != null) {
        try {
          // Handle Firestore Timestamp objects
          if (safeStudentData[field] is Timestamp) {
            safeStudentData[field] = (safeStudentData[field] as Timestamp)
                .toDate()
                .toIso8601String();
          } else {
            // Try to access properties to check if it's valid
            safeStudentData[field].toString();
          }
        } catch (e) {
          // If it fails, store it as the current time
          safeStudentData[field] = DateTime.now().toIso8601String();
        }
      }
    }

    return safeStudentData;
  }
}

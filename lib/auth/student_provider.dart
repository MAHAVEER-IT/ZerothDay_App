import 'package:flutter/foundation.dart';

import 'student_model.dart';
import 'auth_service.dart';

class StudentProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  StudentModel? _student;
  bool _isLoading = false;
  String? _error;

  // Getters
  StudentModel? get student => _student;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isSignedIn();

  // Constructor - try to load cached student data
  StudentProvider() {
    _loadCachedStudent();
  }

  // Load cached student data
  Future<void> _loadCachedStudent() async {
    _setLoading(true);
    try {
      _student = await _authService.loadStudentData();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _error = null;

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        await refreshStudentProfile();
        return true;
      }

      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh student profile from backend
  Future<void> refreshStudentProfile() async {
    _setLoading(true);
    _error = null;

    try {
      _student = await _authService.getStudentProfile();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update student profile
  Future<bool> updateProfile({
    String? rollNumber,
    String? hosteler,
    String? block,
    String? roomNumber,
    String? gender,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final updateData = {
        if (rollNumber != null) 'Rollnumber': rollNumber,
        if (hosteler != null) 'Hosterler': hosteler,
        if (block != null) 'Block': block,
        if (roomNumber != null) 'Roomnumber': roomNumber,
        if (gender != null) 'Gender': gender,
      };

      _student = await _authService.updateStudentProfile(updateData);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _error = null;

    try {
      await _authService.signOut();
      _student = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}

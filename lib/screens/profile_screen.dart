import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/student_model.dart';
import '../auth/student_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _rollNumber;
  String? _hosteler;
  String? _block;
  String? _roomNumber;
  String? _gender;
  bool _isEditing = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      if (studentProvider.student != null) {
        _loadStudentData(studentProvider.student!);
      }
    });
  }

  void _loadStudentData(StudentModel student) {
    setState(() {
      _rollNumber = student.rollNumber;
      _hosteler = student.hosteler;
      _block = student.block;
      _roomNumber = student.roomNumber;
      _gender = student.gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Profile'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          Consumer<StudentProvider>(
            builder: (context, studentProvider, _) {
              final student = studentProvider.student;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    student?.name.isNotEmpty == true
                        ? student!.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, _) {
          if (studentProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (studentProvider.student == null) {
            return Center(child: Text('No student data available'));
          }

          final student = studentProvider.student!;

          return RefreshIndicator(
            onRefresh: () => studentProvider.refreshStudentProfile(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student basic info card
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: 24.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              backgroundColor: Color(
                                0xFFAFDFFF,
                              ), // Light sky blue
                              radius: 48,
                              child: Text(
                                student.name.isNotEmpty
                                    ? student.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5CACEE), // Darker sky blue
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Center(
                            child: Text(
                              student.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 24.0),
                          _buildInfoRow('Email', student.email),
                          _buildInfoRow('Department', student.department),
                          _buildInfoRow('Year', student.year),
                        ],
                      ),
                    ),
                  ),
                  // Editable profile info
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profile Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!_isEditing)
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: 16.0),
                          _isEditing
                              ? _buildEditForm(student, studentProvider)
                              : _buildProfileInfo(student),
                        ],
                      ),
                    ),
                  ),

                  // Error display
                  if (studentProvider.error != null)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(12),
                      color: Colors.red[50],
                      child: Text(
                        studentProvider.error!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  // Logout button at bottom of profile
                  SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5CACEE),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _signOut,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(StudentModel student) {
    return Column(
      children: [
        _buildInfoRow('Roll Number', student.rollNumber ?? 'Not provided'),
        _buildInfoRow('Hosteler', student.hosteler ?? 'Not provided'),
        if (student.hosteler == 'Yes') ...[
          _buildInfoRow('Block', student.block ?? 'Not provided'),
          _buildInfoRow('Room Number', student.roomNumber ?? 'Not provided'),
        ],
        _buildInfoRow('Gender', student.gender ?? 'Not provided'),
      ],
    );
  }

  Widget _buildEditForm(StudentModel student, StudentProvider studentProvider) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _rollNumber,
            decoration: InputDecoration(
              labelText: 'Roll Number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your roll number';
              }
              return null;
            },
            onSaved: (value) => _rollNumber = value?.trim(),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _hosteler,
            decoration: InputDecoration(
              labelText: 'Hosteler',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'Yes', child: Text('Yes')),
              DropdownMenuItem(value: 'No', child: Text('No')),
            ],
            validator: (value) {
              if (value == null) {
                return 'Please select if you are a hosteler';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _hosteler = value;
              });
            },
          ),
          SizedBox(height: 16),
          if (_hosteler == 'Yes') ...[
            TextFormField(
              initialValue: _block,
              decoration: InputDecoration(
                labelText: 'Block',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_hosteler == 'Yes' &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Please enter your block';
                }
                return null;
              },
              onSaved: (value) => _block = value?.trim(),
            ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: _roomNumber,
              decoration: InputDecoration(
                labelText: 'Room Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_hosteler == 'Yes' &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Please enter your room number';
                }
                return null;
              },
              onSaved: (value) => _roomNumber = value?.trim(),
            ),
            SizedBox(height: 16),
          ],
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            validator: (value) {
              if (value == null) {
                return 'Please select your gender';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                _gender = value;
              });
            },
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    // Reset to original values
                    _loadStudentData(student);
                  });
                },
                child: Text('Cancel'),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isUpdating
                    ? null
                    : () => _updateProfile(studentProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5CACEE), // Sky blue
                  foregroundColor: Colors.white,
                ),
                child: _isUpdating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(StudentProvider studentProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      setState(() {
        _isUpdating = true;
      });

      try {
        final success = await studentProvider.updateProfile(
          rollNumber: _rollNumber,
          hosteler: _hosteler,
          block: _hosteler == 'Yes' ? _block : null,
          roomNumber: _hosteler == 'Yes' ? _roomNumber : null,
          gender: _gender,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      }
    }
  }

  Future<void> _signOut() async {
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    await studentProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

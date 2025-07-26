class StudentModel {
  final String uid;
  final String name;
  final String email;
  final String department;
  final String year;
  String? rollNumber;
  String? hosteler;
  String? block;
  String? roomNumber;
  String? gender;
  DateTime? lastLoginTime;
  DateTime? createdAt;

  StudentModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.department,
    required this.year,
    this.rollNumber,
    this.hosteler,
    this.block,
    this.roomNumber,
    this.gender,
    this.lastLoginTime,
    this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      year: json['year'] ?? '',
      rollNumber: json['Rollnumber'],
      hosteler: json['Hosterler'],
      block: json['Block'],
      roomNumber: json['Roomnumber'],
      gender: json['Gender'],
      lastLoginTime: json['lastLoginTime'] != null
          ? _parseTimestamp(json['lastLoginTime'])
          : null,
      createdAt: json['createdAt'] != null
          ? _parseTimestamp(json['createdAt'])
          : null,
    );
  }

  // Helper method to parse Firebase timestamps
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    try {
      if (timestamp is DateTime) return timestamp;

      // Handle various timestamp formats in a more concise way
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        // Handle Firestore timestamp objects
        return DateTime.fromMillisecondsSinceEpoch(
          timestamp.seconds * 1000 + (timestamp.nanoseconds / 1000000).round(),
        );
      } else if (timestamp is Map && timestamp.containsKey('_seconds')) {
        // Handle JSON timestamp from backend API
        final seconds = timestamp['_seconds'];
        final nanoseconds = timestamp['_nanoseconds'] ?? 0;
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds / 1000000).round(),
        );
      } else if (timestamp is int) {
        // Handle regular timestamp (milliseconds since epoch)
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        // Handle ISO format string
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      print('Error parsing timestamp: $e');
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'department': department,
      'year': year,
      'Rollnumber': rollNumber,
      'Hosterler': hosteler,
      'Block': block,
      'Roomnumber': roomNumber,
      'Gender': gender,
    };
  }

  // Create a copy of the current student with updated fields
  StudentModel copyWith({
    String? rollNumber,
    String? hosteler,
    String? block,
    String? roomNumber,
    String? gender,
  }) {
    return StudentModel(
      uid: this.uid,
      name: this.name,
      email: this.email,
      department: this.department,
      year: this.year,
      rollNumber: rollNumber ?? this.rollNumber,
      hosteler: hosteler ?? this.hosteler,
      block: block ?? this.block,
      roomNumber: roomNumber ?? this.roomNumber,
      gender: gender ?? this.gender,
      lastLoginTime: this.lastLoginTime,
      createdAt: this.createdAt,
    );
  }
}

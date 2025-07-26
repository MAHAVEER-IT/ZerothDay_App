import 'package:cloud_firestore/cloud_firestore.dart';

class HostelComplaint {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String category;
  final String issue;
  final String description;
  final String location;
  final String priority;
  final String status; // 'pending', 'in-progress', 'resolved'
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? adminComment;
  final List<String> images;

  HostelComplaint({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.category,
    required this.issue,
    required this.description,
    required this.location,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.adminComment,
    required this.images,
  });

  // Create from Firestore document
  factory HostelComplaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle timestamps
    final createdAt = data['createdAt'] is Timestamp
        ? (data['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    final updatedAt = data['updatedAt'] is Timestamp
        ? (data['updatedAt'] as Timestamp).toDate()
        : createdAt;

    DateTime? resolvedAt;
    if (data['resolvedAt'] != null && data['resolvedAt'] is Timestamp) {
      resolvedAt = (data['resolvedAt'] as Timestamp).toDate();
    }

    // Handle images array
    List<String> images = [];
    if (data['images'] != null) {
      try {
        images = List<String>.from(data['images']);
      } catch (e) {
        print("Error parsing images: $e");
      }
    }

    return HostelComplaint(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      category: data['category'] ?? '',
      issue: data['issue'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      priority: data['priority'] ?? 'Medium',
      status: data['status'] ?? 'pending',
      createdAt: createdAt,
      updatedAt: updatedAt,
      resolvedAt: resolvedAt,
      adminComment: data['adminComment'],
      images: images,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'category': category,
      'issue': issue,
      'description': description,
      'location': location,
      'priority': priority,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'adminComment': adminComment,
      'images': images,
    };
  }
}

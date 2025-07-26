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
  final List<String> images; // URLs to images

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

  // Create a copy of the complaint with some fields updated
  HostelComplaint copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? category,
    String? issue,
    String? description,
    String? location,
    String? priority,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? adminComment,
    List<String>? images,
  }) {
    return HostelComplaint(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      category: category ?? this.category,
      issue: issue ?? this.issue,
      description: description ?? this.description,
      location: location ?? this.location,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminComment: adminComment ?? this.adminComment,
      images: images ?? this.images,
    );
  }

  // Convert complaint to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'category': category,
      'issue': issue,
      'description': description,
      'location': location,
      'priority': priority,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'adminComment': adminComment,
      'images': images,
    };
  }

  // Create a complaint from a map
  factory HostelComplaint.fromMap(Map<String, dynamic> map) {
    return HostelComplaint(
      id: map['id'],
      studentId: map['studentId'],
      studentName: map['studentName'],
      studentEmail: map['studentEmail'],
      category: map['category'],
      issue: map['issue'],
      description: map['description'],
      location: map['location'],
      priority: map['priority'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'])
          : null,
      adminComment: map['adminComment'],
      images: List<String>.from(map['images']),
    );
  }
}

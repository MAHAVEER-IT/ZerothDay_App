import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  final String title;
  final String content;
  final String updatedBy;
  final DateTime timestamp;
  final List<String> doc; // Array of image URLs
  final String category;

  Announcement({
    required this.title,
    required this.content,
    required this.updatedBy,
    required this.timestamp,
    required this.doc,
    required this.category,
  });

  // Factory constructor to create an Announcement from Firebase document
  factory Announcement.fromFirestore(Map<String, dynamic> data) {
    // Extract the docs array from the data
    List<String> docs = [];
    if (data['docs'] != null) {
      docs = List<String>.from(data['docs']);
    }

    return Announcement(
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      doc: docs,
      category: data['Category'] ?? '',
    );
  }

  // Convert Announcement to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'updatedBy': updatedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'docs': doc,
      'Category': category,
    };
  }
}

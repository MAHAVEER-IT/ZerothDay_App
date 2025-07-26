import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundItem {
  final String? id; // Document ID
  final String itemName;
  final String description;
  final String location;
  final String type; // "lost" or "found"
  final DateTime dateTime;
  final String updatedBy; // Posted student name
  final List<String> images; // Array of image URLs

  LostFoundItem({
    this.id,
    required this.itemName,
    required this.description,
    required this.location,
    required this.type,
    required this.dateTime,
    required this.updatedBy,
    required this.images,
  });

  // Factory constructor to create a LostFoundItem from Firebase document
  factory LostFoundItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Extract the images array from the data
    List<String> imagesList = [];
    if (data['images'] != null) {
      imagesList = List<String>.from(data['images']);
    }

    return LostFoundItem(
      id: doc.id,
      dateTime: (data['datetime'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      images: imagesList,
      itemName: data['itemname'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
    );
  }

  // Convert LostFoundItem to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'datetime': Timestamp.fromDate(dateTime),
      'description': description,
      'images': images,
      'itemname': itemName,
      'location': location,
      'type': type,
      'updatedBy': updatedBy,
    };
  }
}

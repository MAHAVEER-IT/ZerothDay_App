import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get announcements from Firestore
  Stream<List<Announcement>> getAnnouncements() {
    return _firestore
        .collection('Announcements')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Announcement.fromFirestore(doc.data());
          }).toList(),
        );
  }

  // Get announcements by category
  Stream<List<Announcement>> getAnnouncementsByCategory(String category) {
    return _firestore
        .collection('Announcements')
        .where('Category', isEqualTo: category)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Announcement.fromFirestore(doc.data());
          }).toList(),
        );
  }

  // Get announcements by date range
  Stream<List<Announcement>> getAnnouncementsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _firestore
        .collection('Announcements')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            return Announcement.fromFirestore(doc.data());
          }).toList(),
        );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lost_found_item.dart';

class LostFoundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'LostFound';

  // Get all lost & found items
  Stream<List<LostFoundItem>> getAllItems() {
    return _firestore
        .collection(_collectionName)
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Get lost items only
  Stream<List<LostFoundItem>> getLostItems() {
    return _firestore
        .collection(_collectionName)
        .where('type', isEqualTo: 'lost')
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Get found items only
  Stream<List<LostFoundItem>> getFoundItems() {
    return _firestore
        .collection(_collectionName)
        .where('type', isEqualTo: 'found')
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Search for items by name
  Stream<List<LostFoundItem>> searchByItemName(String query) {
    // Convert query to lowercase for case-insensitive search
    String searchQuery = query.toLowerCase();

    return _firestore
        .collection(_collectionName)
        .orderBy('itemname')
        .startAt([searchQuery])
        .endAt([
          searchQuery + '\uf8ff',
        ]) // \uf8ff is a high code point that comes after all UTF-8 characters
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Get items by date range
  Stream<List<LostFoundItem>> getItemsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _firestore
        .collection(_collectionName)
        .where('datetime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('datetime', isLessThan: Timestamp.fromDate(end))
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Get items by location
  Stream<List<LostFoundItem>> getItemsByLocation(String location) {
    return _firestore
        .collection(_collectionName)
        .where('location', isEqualTo: location)
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Add a new lost or found item
  Future<DocumentReference> addItem(LostFoundItem item) {
    return _firestore.collection(_collectionName).add(item.toFirestore());
  }

  // Update an existing item
  Future<void> updateItem(LostFoundItem item) {
    if (item.id == null) {
      throw Exception("Cannot update item without an ID");
    }
    return _firestore
        .collection(_collectionName)
        .doc(item.id)
        .update(item.toFirestore());
  }

  // Delete an item
  Future<void> deleteItem(String itemId) {
    return _firestore.collection(_collectionName).doc(itemId).delete();
  }

  // Get items posted by a specific user
  Stream<List<LostFoundItem>> getItemsByUser(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('updatedBy', isEqualTo: userId)
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }

  // Get claimed items only
  Stream<List<LostFoundItem>> getClaimedItems() {
    return _firestore
        .collection(_collectionName)
        .where('type', isEqualTo: 'claimed')
        .orderBy('datetime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LostFoundItem.fromFirestore(doc))
              .toList(),
        );
  }
}

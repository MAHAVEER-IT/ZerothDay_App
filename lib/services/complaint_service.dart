import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hostel_complaint.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'complaints';

  // Get all complaints
  Stream<List<HostelComplaint>> getAllComplaints() {
    try {
      return _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => _convertSnapshots(snapshot));
    } catch (e) {
      print('Error in getAllComplaints: $e');
      // Fallback without ordering if index issues
      return _firestore
          .collection(_collectionName)
          .snapshots()
          .map((snapshot) => _convertSnapshots(snapshot));
    }
  }

  // Get complaints by status
  Stream<List<HostelComplaint>> getComplaintsByStatus(String status) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: status)
          .snapshots()
          .map((snapshot) => _convertSnapshots(snapshot));
    } catch (e) {
      print('Error in getComplaintsByStatus: $e');
      rethrow;
    }
  }

  // Get complaints by student ID
  Stream<List<HostelComplaint>> getComplaintsByStudentId(String studentId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('studentId', isEqualTo: studentId)
          .snapshots()
          .map((snapshot) => _convertSnapshots(snapshot));
    } catch (e) {
      print('Error in getComplaintsByStudentId: $e');
      rethrow;
    }
  }

  // Helper method to convert snapshots to List<HostelComplaint>
  List<HostelComplaint> _convertSnapshots(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => HostelComplaint.fromFirestore(doc))
        .toList();
  }

  // Add a new complaint
  Future<DocumentReference> addComplaint(HostelComplaint complaint) async {
    try {
      return await _firestore
          .collection(_collectionName)
          .add(complaint.toFirestore());
    } catch (e) {
      print('Error adding complaint: $e');
      rethrow;
    }
  }

  // Update an existing complaint
  Future<void> updateComplaint(HostelComplaint complaint) async {
    try {
      if (complaint.id.isEmpty) {
        throw Exception('Cannot update complaint without an ID');
      }

      await _firestore
          .collection(_collectionName)
          .doc(complaint.id)
          .update(complaint.toFirestore());
    } catch (e) {
      print('Error updating complaint: $e');
      rethrow;
    }
  }

  // Delete a complaint
  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _firestore.collection(_collectionName).doc(complaintId).delete();
    } catch (e) {
      print('Error deleting complaint: $e');
      rethrow;
    }
  }

  // Update complaint status
  Future<void> updateComplaintStatus(
    String complaintId,
    String status,
    String? adminComment,
  ) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (adminComment != null) {
        updateData['adminComment'] = adminComment;
      }

      if (status == 'resolved') {
        updateData['resolvedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection(_collectionName)
          .doc(complaintId)
          .update(updateData);
    } catch (e) {
      print('Error updating complaint status: $e');
      rethrow;
    }
  }

  // Get a specific complaint by ID
  Future<HostelComplaint?> getComplaintById(String complaintId) async {
    try {
      final docSnapshot = await _firestore
          .collection(_collectionName)
          .doc(complaintId)
          .get();

      if (docSnapshot.exists) {
        return HostelComplaint.fromFirestore(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting complaint by ID: $e');
      rethrow;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reward_request.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new reward request
  Future<void> createRequest(RewardRequest request) async {
    await _firestore.collection('reward_requests').add(request.toMap());
  }

  // Get all pending requests (for admin)
  Stream<List<RewardRequest>> getPendingRequests() {
    return _firestore
        .collection('reward_requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RewardRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update request status
  Future<void> updateRequestStatus(String id, String status) async {
    await _firestore.collection('reward_requests').doc(id).update({
      'status': status,
    });
  }
}

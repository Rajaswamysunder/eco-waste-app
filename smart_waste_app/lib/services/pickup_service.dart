import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pickup_request.dart';
import 'notification_service.dart';

class PickupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Create a new pickup request
  Future<String> createPickupRequest({
    required String userId,
    required String userName,
    required String userPhone,
    required String address,
    required String wasteType,
    required String quantity,
    required DateTime scheduledDate,
    required String notes,
    String? street,
    String timeSlot = 'morning',
  }) async {
    final data = {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'address': address,
      'street': street ?? address.split(',').first.trim(),
      'wasteType': wasteType,
      'quantity': quantity,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': 'pending',
      'notes': notes,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    DocumentReference docRef = await _firestore.collection('pickups').add(data);
    return docRef.id;
  }

  // Get all pickups for a user
  Stream<List<PickupRequest>> getUserPickups(String userId) {
    return _firestore
        .collection('pickups')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final pickups = snapshot.docs
              .map((doc) => PickupRequest.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order (newest first)
          pickups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return pickups;
        });
  }

  // Get pickups for a collector (by street)
  Stream<List<PickupRequest>> getCollectorPickups(String street) {
    return _firestore
        .collection('pickups')
        .where('street', isEqualTo: street)
        .snapshots()
        .map((snapshot) {
          final pickups = snapshot.docs
              .map((doc) => PickupRequest.fromMap(doc.data(), doc.id))
              .where((p) => ['pending', 'assigned', 'confirmed', 'in_progress'].contains(p.status))
              .toList();
          // Sort by scheduledDate
          pickups.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
          return pickups;
        });
  }

  // Get all pickups (for admin)
  Stream<List<PickupRequest>> getAllPickups() {
    return _firestore
        .collection('pickups')
        .snapshots()
        .map((snapshot) {
          final pickups = snapshot.docs
              .map((doc) => PickupRequest.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order (newest first)
          pickups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return pickups;
        });
  }

  // Get pickups by status (for admin)
  Stream<List<PickupRequest>> getPickupsByStatus(String status) {
    return _firestore
        .collection('pickups')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
          final pickups = snapshot.docs
              .map((doc) => PickupRequest.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order (newest first)
          pickups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return pickups;
        });
  }

  // Get pickups by multiple statuses (for admin - combines assigned & confirmed)
  Stream<List<PickupRequest>> getPickupsByStatuses(List<String> statuses) {
    return _firestore
        .collection('pickups')
        .where('status', whereIn: statuses)
        .snapshots()
        .map((snapshot) {
          final pickups = snapshot.docs
              .map((doc) => PickupRequest.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by createdAt in descending order (newest first)
          pickups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return pickups;
        });
  }

  // Get single pickup by ID (real-time stream)
  Stream<PickupRequest?> getPickupById(String pickupId) {
    return _firestore
        .collection('pickups')
        .doc(pickupId)
        .snapshots()
        .map((doc) {
          if (doc.exists && doc.data() != null) {
            return PickupRequest.fromMap(doc.data()!, doc.id);
          }
          return null;
        });
  }

  // Update pickup status
  Future<void> updatePickupStatus(String pickupId, String status,
      {String? collectorId, String? collectorName, String? collectorPhone}) async {
    // Get pickup first to get userId
    final doc = await _firestore.collection('pickups').doc(pickupId).get();
    final pickupData = doc.data();
    
    Map<String, dynamic> updateData = {'status': status};
    if (collectorId != null) updateData['collectorId'] = collectorId;
    if (collectorName != null) updateData['collectorName'] = collectorName;
    if (collectorPhone != null) updateData['collectorPhone'] = collectorPhone;
    if (status == 'completed') {
      updateData['completedAt'] = DateTime.now().toIso8601String();
    }

    await _firestore.collection('pickups').doc(pickupId).update(updateData);
    
    // Send notification to user
    if (pickupData != null) {
      final userId = pickupData['userId'] as String?;
      if (userId != null) {
        await _notificationService.notifyStatusChange(
          userId: userId,
          status: status,
          pickupId: pickupId,
          collectorName: collectorName ?? pickupData['collectorName'],
        );
      }
    }
  }

  // Cancel pickup
  Future<void> cancelPickup(String pickupId) async {
    await _firestore.collection('pickups').doc(pickupId).update({
      'status': 'cancelled',
    });
  }

  // Delete pickup permanently (admin only)
  Future<void> deletePickup(String pickupId) async {
    await _firestore.collection('pickups').doc(pickupId).delete();
  }

  // Assign collector to pickup
  Future<void> assignCollector(
      String pickupId, String collectorId, String collectorName, {String? collectorPhone}) async {
    // Get pickup details for notification
    final doc = await _firestore.collection('pickups').doc(pickupId).get();
    final pickupData = doc.data();
    
    await _firestore.collection('pickups').doc(pickupId).update({
      'status': 'assigned',
      'collectorId': collectorId,
      'collectorName': collectorName,
      'collectorPhone': collectorPhone,
    });
    
    // Send notification to collector
    final address = pickupData?['address'] ?? 'Unknown location';
    await _notificationService.notifyPickupAssigned(
      collectorId: collectorId,
      address: address,
      pickupId: pickupId,
    );
    
    // Send notification to user
    final userId = pickupData?['userId'] as String?;
    if (userId != null) {
      await _notificationService.notifyStatusChange(
        userId: userId,
        status: 'assigned',
        pickupId: pickupId,
        collectorName: collectorName,
      );
    }
  }

  // Get statistics (for admin)
  Future<Map<String, int>> getPickupStats() async {
    QuerySnapshot allPickups = await _firestore.collection('pickups').get();
    
    int pending = 0, assigned = 0, inProgress = 0, completed = 0, cancelled = 0;
    
    for (var doc in allPickups.docs) {
      String status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
      switch (status) {
        case 'pending':
          pending++;
          break;
        case 'assigned':
          assigned++;
          break;
        case 'in_progress':
          inProgress++;
          break;
        case 'completed':
          completed++;
          break;
        case 'cancelled':
          cancelled++;
          break;
      }
    }

    return {
      'pending': pending,
      'assigned': assigned,
      'inProgress': inProgress,
      'completed': completed,
      'cancelled': cancelled,
      'total': allPickups.docs.length,
    };
  }
  
  // Get user-specific stats
  Future<Map<String, int>> getUserStats(String userId) async {
    QuerySnapshot userPickups = await _firestore
        .collection('pickups')
        .where('userId', isEqualTo: userId)
        .get();
    
    int pending = 0, completed = 0, cancelled = 0;
    
    for (var doc in userPickups.docs) {
      String status = (doc.data() as Map<String, dynamic>)['status'] ?? '';
      switch (status) {
        case 'pending':
        case 'assigned':
        case 'in_progress':
          pending++;
          break;
        case 'completed':
          completed++;
          break;
        case 'cancelled':
          cancelled++;
          break;
      }
    }

    return {
      'pending': pending,
      'completed': completed,
      'cancelled': cancelled,
      'total': userPickups.docs.length,
    };
  }

  // Get pickups assigned to a specific collector
  Stream<List<PickupRequest>> getPickupsByCollector(String collectorId) {
    return _firestore
        .collection('pickups')
        .where('collectorId', isEqualTo: collectorId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PickupRequest.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}

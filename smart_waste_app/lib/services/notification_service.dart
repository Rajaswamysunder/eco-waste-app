import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get notifications for a user
  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // Add a notification
  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    required String type, // 'pickup', 'reminder', 'achievement', 'status'
    String? pickupId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'pickupId': pickupId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // Delete old notifications (older than 30 days)
  Future<void> cleanupOldNotifications(String userId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final oldNotifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
        .get();

    final batch = _firestore.batch();
    for (var doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Get unread count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Send notification when pickup is assigned to collector
  Future<void> notifyPickupAssigned({
    required String collectorId,
    required String address,
    required String pickupId,
  }) async {
    await addNotification(
      userId: collectorId,
      title: 'New Pickup Assigned',
      message: 'You have a new pickup request at $address',
      type: 'pickup',
      pickupId: pickupId,
    );
  }

  // Send notification when pickup status changes (to user)
  Future<void> notifyStatusChange({
    required String userId,
    required String status,
    required String pickupId,
    String? collectorName,
  }) async {
    String title;
    String message;

    switch (status) {
      case 'assigned':
        title = 'Collector Assigned';
        message = '${collectorName ?? "A collector"} has been assigned to your pickup';
        break;
      case 'confirmed':
        title = 'Pickup Confirmed';
        message = 'Your pickup has been confirmed by the collector';
        break;
      case 'in_progress':
        title = 'Collector On The Way';
        message = '${collectorName ?? "The collector"} is on the way to collect your waste';
        break;
      case 'completed':
        title = 'Pickup Completed';
        message = 'Your waste has been collected successfully! +25 Eco Points';
        break;
      default:
        title = 'Pickup Update';
        message = 'Your pickup status has been updated to $status';
    }

    await addNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'status',
      pickupId: pickupId,
    );
  }

  // Send achievement notification
  Future<void> notifyAchievement({
    required String userId,
    required String title,
    required String message,
  }) async {
    await addNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'achievement',
    );
  }
}

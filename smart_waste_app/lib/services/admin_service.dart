import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get all collectors
  Stream<List<UserModel>> getAllCollectors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'collector')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({'role': role});
  }

  // Assign street to collector
  Future<void> assignStreetToCollector(String collectorId, String street) async {
    await _firestore.collection('users').doc(collectorId).update({
      'assignedStreet': street,
    });
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Get user count
  Future<int> getUserCount() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();
    return snapshot.docs.length;
  }

  // Get collector count
  Future<int> getCollectorCount() async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'collector')
        .get();
    return snapshot.docs.length;
  }

  // Get all streets (for assignment)
  Future<List<String>> getAllStreets() async {
    // You can customize this list or fetch from Firestore
    return [
      'Main Street',
      'Oak Avenue',
      'Pine Road',
      'Elm Street',
      'Cedar Lane',
      'Maple Drive',
      'Birch Boulevard',
      'Willow Way',
      'Cherry Court',
      'Spruce Street',
    ];
  }

  // Get user stats for admin dashboard
  Future<Map<String, int>> getUserStats() async {
    final usersSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();
    final collectorsSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'collector')
        .get();
    final adminsSnapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    return {
      'users': usersSnapshot.docs.length,
      'collectors': collectorsSnapshot.docs.length,
      'admins': adminsSnapshot.docs.length,
    };
  }

  // Create a new collector
  Future<void> createCollector({
    required String email,
    required String name,
    required String phone,
    required String address,
    String? assignedStreet,
    String? vehicleNumber,
    String? vehicleType,
  }) async {
    // Create the collector document in Firestore
    await _firestore.collection('users').doc().set({
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'role': 'collector',
      'assignedStreet': assignedStreet,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Get vehicle types
  List<String> getVehicleTypes() {
    return [
      'Truck',
      'Mini Truck',
      'Van',
      'Auto',
      'Pickup',
      'Compactor',
    ];
  }
}

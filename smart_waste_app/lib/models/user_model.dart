class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String role; // 'user', 'collector', 'admin'
  final String? assignedStreet; // For collectors
  final String? vehicleNumber; // For collectors
  final String? vehicleType; // For collectors (e.g., 'Truck', 'Van', 'Auto')
  final String? profileImageUrl; // Profile picture URL
  final DateTime createdAt;
  final bool isOnline; // Real-time online status
  final DateTime? lastSeen; // Last activity timestamp

  // Alias for uid
  String get id => uid;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
    required this.role,
    this.assignedStreet,
    this.vehicleNumber,
    this.vehicleType,
    this.profileImageUrl,
    required this.createdAt,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? 'user',
      assignedStreet: map['assignedStreet'],
      vehicleNumber: map['vehicleNumber'],
      vehicleType: map['vehicleType'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'role': role,
      'assignedStreet': assignedStreet,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    String? address,
    String? role,
    String? assignedStreet,
    String? vehicleNumber,
    String? vehicleType,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      assignedStreet: assignedStreet ?? this.assignedStreet,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

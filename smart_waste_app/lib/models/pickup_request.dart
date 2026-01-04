class PickupRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String address;
  final String street;
  final double? latitude;
  final double? longitude;
  final String wasteType; // 'organic', 'recyclable', 'hazardous', 'general'
  final String quantity;
  final DateTime scheduledDate;
  final String timeSlot; // 'morning', 'afternoon', 'evening'
  final String status; // 'pending', 'assigned', 'in_progress', 'completed', 'cancelled'
  final String? collectorId;
  final String? collectorName;
  final String? collectorPhone;
  final String notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  PickupRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.address,
    required this.street,
    this.latitude,
    this.longitude,
    required this.wasteType,
    required this.quantity,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    this.collectorId,
    this.collectorName,
    this.collectorPhone,
    required this.notes,
    required this.createdAt,
    this.completedAt,
  });

  factory PickupRequest.fromMap(Map<String, dynamic> map, String id) {
    return PickupRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      address: map['address'] ?? '',
      street: map['street'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      wasteType: map['wasteType'] ?? 'general',
      quantity: map['quantity'] ?? '',
      scheduledDate: DateTime.parse(map['scheduledDate']),
      timeSlot: map['timeSlot'] ?? 'morning',
      status: map['status'] ?? 'pending',
      collectorId: map['collectorId'],
      collectorName: map['collectorName'],
      collectorPhone: map['collectorPhone'],
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'address': address,
      'street': street,
      'latitude': latitude,
      'longitude': longitude,
      'wasteType': wasteType,
      'quantity': quantity,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'collectorId': collectorId,
      'collectorName': collectorName,
      'collectorPhone': collectorPhone,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  PickupRequest copyWith({
    String? status,
    String? collectorId,
    String? collectorName,
    String? collectorPhone,
    DateTime? completedAt,
    double? latitude,
    double? longitude,
  }) {
    return PickupRequest(
      id: id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      address: address,
      street: street,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      wasteType: wasteType,
      quantity: quantity,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      status: status ?? this.status,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      collectorPhone: collectorPhone ?? this.collectorPhone,
      notes: notes,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get wasteTypeDisplay {
    switch (wasteType) {
      case 'organic':
        return '🥬 Organic Waste';
      case 'recyclable':
        return '♻️ Recyclable';
      case 'hazardous':
        return '☢️ Hazardous';
      case 'general':
      default:
        return '🗑️ General Waste';
    }
  }

  String get timeSlotDisplay {
    switch (timeSlot) {
      case 'morning':
        return '🌅 Morning (6AM - 10AM)';
      case 'afternoon':
        return '☀️ Afternoon (12PM - 4PM)';
      case 'evening':
        return '🌆 Evening (4PM - 8PM)';
      default:
        return timeSlot;
    }
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

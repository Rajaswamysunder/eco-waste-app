class RewardRequest {
  final String id;
  final String userId;
  final String userName;
  final String rewardTitle;
  final int rewardPoints;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  RewardRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rewardTitle,
    required this.rewardPoints,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rewardTitle': rewardTitle,
      'rewardPoints': rewardPoints,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RewardRequest.fromMap(Map<String, dynamic> map, String id) {
    return RewardRequest(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rewardTitle: map['rewardTitle'] ?? '',
      rewardPoints: map['rewardPoints'] ?? 0,
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

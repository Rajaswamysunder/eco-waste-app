import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../services/pickup_service.dart';
import '../../models/pickup_request.dart';
import '../auth/login_screen.dart';
import '../user/profile_screen.dart';
import '../user/notifications_screen.dart';
import 'manage_users_screen.dart';
import 'manage_collectors_screen.dart';
import 'all_pickups_screen.dart';
import 'admin_reward_requests_screen.dart';
import 'admin_settings_screen.dart';
import '../user/chatbot_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  final PickupService _pickupService = PickupService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout, color: Colors.red[400]),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthService>(context, listen: false).signOut();
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF6A1B9A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A148C),
                      Color(0xFF6A1B9A),
                      Color(0xFF7B1FA2),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin Panel',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      user?.name ?? 'Admin',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildHeaderIcon(
                                    Icons.notifications_outlined, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationsScreen(),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 8),
                                _buildHeaderIcon(Icons.settings, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AdminSettingsScreen(),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  color: Colors.amber),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'System Health',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'All services running smoothly ✓',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.completedColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Online',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats Grid
          SliverToBoxAdapter(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats Cards
                    StreamBuilder<List<PickupRequest>>(
                      stream: _pickupService.getAllPickups(),
                      builder: (context, pickupSnapshot) {
                        final pickups = pickupSnapshot.data ?? [];
                        final totalPickups = pickups.length;
                        final pendingPickups =
                            pickups.where((p) => p.status == 'pending').length;
                        final completedPickups =
                            pickups.where((p) => p.status == 'completed').length;

                        return FutureBuilder<Map<String, int>>(
                          future: _adminService.getUserStats(),
                          builder: (context, statsSnapshot) {
                            final stats = statsSnapshot.data ??
                                {'users': 0, 'collectors': 0, 'admins': 0};

                            return GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.3,
                              children: [
                                _buildAnimatedStatCard(
                                  'Total Users',
                                  stats['users'].toString(),
                                  Icons.people,
                                  const Color(0xFF2196F3),
                                  'Registered customers',
                                  trendPercent: 12,
                                  trendUp: true,
                                ),
                                _buildAnimatedStatCard(
                                  'Collectors',
                                  stats['collectors'].toString(),
                                  Icons.local_shipping,
                                  const Color(0xFF00BCD4),
                                  'Active collectors',
                                  trendPercent: 5,
                                  trendUp: true,
                                ),
                                _buildAnimatedStatCard(
                                  'Total Pickups',
                                  totalPickups.toString(),
                                  Icons.delete_sweep,
                                  const Color(0xFF9C27B0),
                                  'All time requests',
                                  trendPercent: 18,
                                  trendUp: true,
                                ),
                                _buildAnimatedStatCard(
                                  'Pending',
                                  pendingPickups.toString(),
                                  Icons.pending_actions,
                                  AppTheme.pendingColor,
                                  'Awaiting action',
                                  trendPercent: pendingPickups > 0 ? 8 : 0,
                                  trendUp: false,
                                ),
                                _buildAnimatedStatCard(
                                  'Completed',
                                  completedPickups.toString(),
                                  Icons.check_circle,
                                  AppTheme.completedColor,
                                  'Successfully done',
                                  trendPercent: 25,
                                  trendUp: true,
                                ),
                                _buildAnimatedStatCard(
                                  'Success Rate',
                                  totalPickups > 0
                                      ? '${((completedPickups / totalPickups) * 100).toStringAsFixed(0)}%'
                                      : '0%',
                                  Icons.trending_up,
                                  const Color(0xFF4CAF50),
                                  'Completion rate',
                                  trendPercent: 3,
                                  trendUp: true,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    title: 'Manage Users',
                    subtitle: 'View and manage all registered users',
                    icon: Icons.people_outline,
                    color: const Color(0xFF2196F3),
                    emoji: '👥',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageUsersScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: 'Manage Collectors',
                    subtitle: 'Add, edit, or remove waste collectors',
                    icon: Icons.local_shipping_outlined,
                    color: const Color(0xFF00BCD4),
                    emoji: '🚛',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageCollectorsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: 'Reward Requests',
                    subtitle: 'Approve or reject eco reward redemptions',
                    icon: Icons.card_giftcard,
                    color: Colors.orange,
                    emoji: '🎁',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AdminRewardRequestsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: 'All Pickup Requests',
                    subtitle: 'Monitor and manage all pickup requests',
                    icon: Icons.list_alt,
                    color: const Color(0xFF9C27B0),
                    emoji: '📋',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllPickupsScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Recent Activity
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF2D3436),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AllPickupsScreen()),
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(color: Color(0xFF6A1B9A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<PickupRequest>>(
                    stream: _pickupService.getAllPickups(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6A1B9A),
                          ),
                        );
                      }

                      final pickups = snapshot.data ?? [];
                      final recentPickups = pickups.take(5).toList();

                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      
                      if (recentPickups.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'No recent activity',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                            ),
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentPickups.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final pickup = recentPickups[index];
                            return _buildActivityItem(pickup);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.smart_toy, color: Colors.white),
        tooltip: 'EcoBot Assistant',
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildAnimatedStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle, {
    double? trendPercent,
    bool trendUp = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (trendPercent != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: trendUp ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${trendPercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: trendUp ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF2D3436),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String emoji,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(PickupRequest pickup) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppTheme.getStatusColor(pickup.status);
    final wasteColor = AppTheme.getWasteTypeColor(pickup.wasteType);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: wasteColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getWasteIcon(pickup.wasteType),
              color: wasteColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${pickup.wasteType} • ${pickup.quantity}',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: pickup.status),
        ],
      ),
    );
  }

  IconData _getWasteIcon(String type) {
    switch (type.toLowerCase()) {
      case 'organic':
        return Icons.eco;
      case 'recyclable':
        return Icons.recycling;
      case 'e-waste':
        return Icons.devices;
      case 'hazardous':
        return Icons.warning_amber;
      default:
        return Icons.delete;
    }
  }
}

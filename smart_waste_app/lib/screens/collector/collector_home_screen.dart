import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/pickup_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../models/pickup_request.dart';
import '../auth/login_screen.dart';
import '../user/notifications_screen.dart';
import 'collector_settings_screen.dart';
import '../user/chatbot_screen.dart';

class CollectorHomeScreen extends StatefulWidget {
  const CollectorHomeScreen({super.key});

  @override
  State<CollectorHomeScreen> createState() => _CollectorHomeScreenState();
}

class _CollectorHomeScreenState extends State<CollectorHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final PickupService _pickupService = PickupService();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  Timer? _onlineStatusTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    
    // Use post frame callback to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setOnlineStatus(true);
      // Update online status every 2 minutes to keep status fresh
      _onlineStatusTimer = Timer.periodic(const Duration(minutes: 2), (_) {
        _updateLastSeen();
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _onlineStatusTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - set online
      _setOnlineStatus(true);
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.inactive ||
               state == AppLifecycleState.detached) {
      // App went to background - set offline
      _setOnlineStatus(false);
    }
  }

  Future<void> _setOnlineStatus(bool isOnline) async {
    // Try to get user from provider first
    final providerUser = Provider.of<UserProvider>(context, listen: false).user;
    String? uid = providerUser?.uid;
    
    // Fallback to Firebase Auth if provider doesn't have user yet
    if (uid == null) {
      uid = FirebaseAuth.instance.currentUser?.uid;
    }
    
    if (uid != null) {
      try {
        await _authService.setOnlineStatus(uid, isOnline);
        debugPrint('Set online status for $uid: $isOnline');
      } catch (e) {
        debugPrint('Error setting online status: $e');
      }
    } else {
      debugPrint('No user found to set online status');
    }
  }

  Future<void> _updateLastSeen() async {
    final providerUser = Provider.of<UserProvider>(context, listen: false).user;
    String? uid = providerUser?.uid;
    
    if (uid == null) {
      uid = FirebaseAuth.instance.currentUser?.uid;
    }
    
    if (uid != null) {
      await _authService.updateLastSeen(uid);
    }
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

  void _showNotifications() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Color(0xFF1565C0), size: 28),
                    const SizedBox(width: 12),
                    const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _notificationService.markAllAsRead(user.uid);
                        Navigator.pop(context);
                      },
                      child: const Text('Mark all read'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _notificationService.getNotifications(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final notifications = snapshot.data ?? [];
                    
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text('No notifications yet', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final n = notifications[index];
                        final isUnread = !(n['read'] ?? false);
                        final type = n['type'] ?? 'pickup';
                        IconData icon = type == 'pickup' ? Icons.local_shipping : 
                                        type == 'reminder' ? Icons.access_time : 
                                        type == 'status' ? Icons.update : Icons.emoji_events;
                        Color color = type == 'pickup' ? Colors.blue : 
                                      type == 'reminder' ? Colors.orange : 
                                      type == 'status' ? Colors.purple : Colors.green;
                        
                        // Format time
                        String timeAgo = 'Just now';
                        if (n['createdAt'] != null) {
                          final createdAt = (n['createdAt'] as dynamic).toDate();
                          final diff = DateTime.now().difference(createdAt);
                          if (diff.inMinutes < 60) {
                            timeAgo = '${diff.inMinutes}m ago';
                          } else if (diff.inHours < 24) {
                            timeAgo = '${diff.inHours}h ago';
                          } else {
                            timeAgo = DateFormat('MMM dd').format(createdAt);
                          }
                        }
                        
                        return GestureDetector(
                          onTap: () {
                            if (isUnread && n['id'] != null) {
                              _notificationService.markAsRead(n['id']);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUnread 
                                  ? color.withOpacity(isDark ? 0.15 : 0.05) 
                                  : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[50]),
                              borderRadius: BorderRadius.circular(16),
                              border: isUnread ? Border.all(color: color.withOpacity(isDark ? 0.4 : 0.2)) : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: Text(n['title'] ?? '', style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.w600, color: isDark ? Colors.white : Colors.black87))),
                                          if (isUnread) Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(n['message'] ?? '', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                      const SizedBox(height: 4),
                                      Text(timeAgo, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with Gradient
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1565C0),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D47A1),
                      Color(0xFF1565C0),
                      Color(0xFF1976D2),
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
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Collector Dashboard',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      user?.name ?? 'Collector',
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationsScreen(),
                                      ),
                                    );
                                  },
                                  child: StreamBuilder<int>(
                                    stream: user != null ? _notificationService.getUnreadCount(user.uid) : const Stream.empty(),
                                    builder: (context, snapshot) {
                                      final unreadCount = snapshot.data ?? 0;
                                      return Stack(
                                        children: [
                                          _buildHeaderIcon(Icons.notifications_outlined),
                                          if (unreadCount > 0)
                                            Positioned(
                                              top: 6, right: 6,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                                child: Text(
                                                  unreadCount > 9 ? '9+' : '$unreadCount',
                                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CollectorSettingsScreen(),
                                      ),
                                    );
                                  },
                                  child: _buildHeaderIcon(Icons.settings),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        StreamBuilder<List<PickupRequest>>(
                          stream: user != null ? _pickupService.getPickupsByCollector(user.uid) : const Stream.empty(),
                          builder: (context, snapshot) {
                            final pickups = snapshot.data ?? [];
                            final pending = pickups
                                .where((p) => p.status == 'assigned')
                                .length;
                            final todayPickups = pickups.where((p) {
                              final today = DateTime.now();
                              return p.scheduledDate.day == today.day &&
                                  p.scheduledDate.month == today.month &&
                                  p.scheduledDate.year == today.year &&
                                  (p.status == 'confirmed' ||
                                      p.status == 'assigned');
                            }).length;

                            return Row(
                              children: [
                                _buildQuickStat(
                                    'Pending', pending.toString(), Icons.pending),
                                const SizedBox(width: 16),
                                _buildQuickStat('Today\'s Pickups',
                                    todayPickups.toString(), Icons.today),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<PickupRequest>>(
                stream: user != null ? _pickupService.getPickupsByCollector(user.uid) : const Stream.empty(),
                builder: (context, snapshot) {
                  final pickups = snapshot.data ?? [];
                  final assigned =
                      pickups.where((p) => p.status == 'assigned').length;
                  final confirmed =
                      pickups.where((p) => p.status == 'confirmed').length;
                  final inProgress =
                      pickups.where((p) => p.status == 'in_progress').length;
                  final completed =
                      pickups.where((p) => p.status == 'completed').length;

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Assigned',
                        assigned,
                        Icons.assignment,
                        AppTheme.pendingColor,
                        'Awaiting confirmation',
                      ),
                      _buildStatCard(
                        'Confirmed',
                        confirmed,
                        Icons.check_circle_outline,
                        AppTheme.confirmedColor,
                        'Ready for pickup',
                      ),
                      _buildStatCard(
                        'In Progress',
                        inProgress,
                        Icons.local_shipping,
                        Colors.purple,
                        'On the way',
                      ),
                      _buildStatCard(
                        'Completed',
                        completed,
                        Icons.done_all,
                        AppTheme.completedColor,
                        'Successfully collected',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1565C0),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1565C0),
                  indicatorWeight: 3,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Assigned'),
                    Tab(text: 'Confirmed'),
                    Tab(text: 'In Progress'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
            ),
          ),

          // Pickup List
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPickupList('assigned'),
                _buildPickupList('confirmed'),
                _buildPickupList('in_progress'),
                _buildPickupList('completed'),
              ],
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
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.smart_toy, color: Colors.white),
        tooltip: 'EcoBot Assistant',
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildQuickStat(String label, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    int count,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
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

  Widget _buildPickupList(String status) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    return StreamBuilder<List<PickupRequest>>(
      stream: user != null ? _pickupService.getPickupsByCollector(user.uid) : const Stream.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1565C0)),
          );
        }

        final pickups = (snapshot.data ?? [])
            .where((p) => p.status == status)
            .toList();

        if (pickups.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No $status pickups',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: pickups.length,
          itemBuilder: (context, index) {
            return _buildPickupCard(pickups[index]);
          },
        );
      },
    );
  }

  Widget _buildPickupCard(PickupRequest pickup) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppTheme.getStatusColor(pickup.status);
    final wasteColor = AppTheme.getWasteTypeColor(pickup.wasteType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  wasteColor.withOpacity(0.1),
                  wasteColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: wasteColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getWasteIcon(pickup.wasteType),
                        color: wasteColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickup.wasteType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Qty: ${pickup.quantity}',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                StatusBadge(status: pickup.status),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Customer Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(Icons.person, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
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
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            pickup.userPhone,
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Implement call functionality
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: AppTheme.primaryGreen,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Schedule & Location
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.calendar_today,
                        DateFormat('EEE, MMM d').format(pickup.scheduledDate),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.access_time,
                        DateFormat('hh:mm a').format(pickup.scheduledDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on,
                  pickup.address,
                  expanded: true,
                ),

                if (pickup.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, color: Colors.amber[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pickup.notes,
                            style: TextStyle(
                              color: Colors.amber[900],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: _buildActionButtons(pickup),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(PickupRequest pickup) {
    switch (pickup.status) {
      case 'pending':
      case 'assigned':
        return [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(pickup.id, 'cancelled'),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Decline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(pickup.id, 'confirmed'),
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: const Text('Confirm',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.confirmedColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ];
      case 'confirmed':
        return [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(pickup.id, 'in_progress'),
              icon: const Icon(Icons.local_shipping,
                  size: 18, color: Colors.white),
              label: const Text('Start Pickup',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ];
      case 'in_progress':
        return [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _navigateToPickup(pickup),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('Navigate'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _updateStatus(pickup.id, 'completed'),
              icon:
                  const Icon(Icons.done_all, size: 18, color: Colors.white),
              label: const Text('Complete',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.completedColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ];
      default:
        return [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.completedColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      color: AppTheme.completedColor, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: AppTheme.completedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
    }
  }

  Widget _buildInfoRow(IconData icon, String text, {bool expanded = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        expanded
            ? Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              )
            : Text(
                text,
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
      ],
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

  Future<void> _updateStatus(String pickupId, String newStatus) async {
    try {
      await _pickupService.updatePickupStatus(pickupId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Status updated to ${newStatus.replaceAll('_', ' ')}'),
              ],
            ),
            backgroundColor: AppTheme.completedColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToPickup(PickupRequest pickup) async {
    // Check if pickup has coordinates
    if (pickup.latitude != null && pickup.longitude != null) {
      // Open in Google Maps or OpenStreetMap
      final lat = pickup.latitude!;
      final lng = pickup.longitude!;
      
      // Try Google Maps first, fallback to OpenStreetMap
      final googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
      final osmUrl = Uri.parse('https://www.openstreetmap.org/directions?to=$lat,$lng');
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(osmUrl)) {
        await launchUrl(osmUrl, mode: LaunchMode.externalApplication);
      } else {
        _showMapBottomSheet(pickup);
      }
    } else {
      // No coordinates, show address-based navigation
      final address = Uri.encodeComponent(pickup.address);
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }

  void _showMapBottomSheet(PickupRequest pickup) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: isDark ? Colors.grey[600] : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                        Text(pickup.address, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: pickup.latitude != null && pickup.longitude != null
                    ? Image.network(
                        'https://staticmap.openstreetmap.de/staticmap.php?center=${pickup.latitude},${pickup.longitude}&zoom=15&size=600x400&markers=${pickup.latitude},${pickup.longitude},red-pushpin',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 8),
                              Text('Map preview unavailable', style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text('No coordinates available', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final phone = pickup.userPhone.replaceAll(RegExp(r'[^\d+]'), '');
                        final url = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call User'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final address = Uri.encodeComponent(pickup.address);
                        final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.directions, color: Colors.white),
                      label: const Text('Get Directions', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate(this.child);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

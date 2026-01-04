import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationService.getNotifications(user.uid),
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];
          final unreadNotifications = notifications.where((n) => !(n['read'] ?? false)).toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.primaryGreen,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _markAllAsRead(user.uid),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.done_all, color: Colors.white, size: 20),
                    ),
                    tooltip: 'Mark all as read',
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 70),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.notifications_active, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                Text('${unreadNotifications.length} unread', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.primaryGreen,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.primaryGreen,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Unread'),
                              if (unreadNotifications.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                                  child: Text('${unreadNotifications.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                            ],
                          ),
                        ),
                        const Tab(text: 'All'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                unreadNotifications.isEmpty
                    ? _buildEmptyState('No unread notifications')
                    : _buildNotificationList(unreadNotifications),
                notifications.isEmpty
                    ? _buildEmptyState('No notifications yet')
                    : _buildNotificationList(notifications),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
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
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<Map<String, dynamic>> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final type = notification['type'] ?? 'status';
    final iconData = _getNotificationIcon(type);
    final iconColor = _getNotificationColor(type);
    final isRead = notification['read'] ?? false;
    final title = notification['title'] ?? '';
    final message = notification['message'] ?? '';
    final notifId = notification['id'];
    
    // Format time
    String timeAgo = 'Just now';
    if (notification['createdAt'] != null) {
      try {
        final createdAt = (notification['createdAt'] as dynamic).toDate();
        timeAgo = _formatTime(createdAt);
      } catch (e) {
        timeAgo = 'Recently';
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (!isRead && notifId != null) {
          _notificationService.markAsRead(notifId);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isRead ? null : Border.all(color: iconColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: isRead ? Colors.black.withOpacity(0.04) : iconColor.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 12,
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'pickup':
        return Icons.local_shipping;
      case 'status':
        return Icons.update;
      case 'achievement':
        return Icons.emoji_events;
      case 'reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'pickup':
        return AppTheme.accentBlue;
      case 'status':
        return AppTheme.accentPurple;
      case 'achievement':
        return AppTheme.completedColor;
      case 'reminder':
        return Colors.amber;
      default:
        return AppTheme.primaryGreen;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  void _markAllAsRead(String userId) {
    _notificationService.markAllAsRead(userId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/pickup_service.dart';
import '../../services/auth_service.dart';
import '../../models/pickup_request.dart';
import '../auth/login_screen.dart';
import 'request_pickup_screen.dart';
import 'profile_screen.dart';
import 'pickup_detail_screen.dart';
import 'pickup_history_screen.dart';
import 'notifications_screen.dart';
import 'chatbot_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PickupService _pickupService = PickupService();
  final PageController _recyclingPageController = PageController();
  int _currentRecyclingPage = 0;
  String _featuredCategory = 'Organic'; // Track which category is featured

  // Recycling process data with icons
  final List<Map<String, dynamic>> _recyclingProcesses = [
    {
      'title': 'Organic Waste',
      'emoji': '🌿',
      'color': Color(0xFF4CAF50),
      'steps': [
        {'icon': Icons.delete_outline, 'label': 'Collect'},
        {'icon': Icons.category, 'label': 'Sort'},
        {'icon': Icons.spa, 'label': 'Compost'},
        {'icon': Icons.grass, 'label': 'Fertilizer'},
      ],
      'description': 'Food scraps and garden waste become nutrient-rich compost for farming.',
      'impact': 'Reduces methane by 60%',
      'resultIcon': Icons.agriculture,
      'resultLabel': 'Organic Fertilizer',
    },
    {
      'title': 'Recyclable Waste',
      'emoji': '♻️',
      'color': Color(0xFF2196F3),
      'steps': [
        {'icon': Icons.delete_outline, 'label': 'Collect'},
        {'icon': Icons.sort, 'label': 'Sort'},
        {'icon': Icons.settings, 'label': 'Process'},
        {'icon': Icons.inventory_2, 'label': 'New Items'},
      ],
      'description': 'Paper, plastic, glass & metal are transformed into brand new products.',
      'impact': 'Saves 95% energy',
      'resultIcon': Icons.recycling,
      'resultLabel': 'New Products',
    },
    {
      'title': 'E-Waste',
      'emoji': '💻',
      'color': Color(0xFFFF9800),
      'steps': [
        {'icon': Icons.devices, 'label': 'Collect'},
        {'icon': Icons.build, 'label': 'Dismantle'},
        {'icon': Icons.memory, 'label': 'Extract'},
        {'icon': Icons.auto_awesome, 'label': 'Recover'},
      ],
      'description': 'Electronics are dismantled to recover gold, silver, copper & other metals.',
      'impact': 'Recovers 80% metals',
      'resultIcon': Icons.diamond,
      'resultLabel': 'Precious Metals',
    },
    {
      'title': 'Hazardous Waste',
      'emoji': '⚠️',
      'color': Color(0xFFF44336),
      'steps': [
        {'icon': Icons.warning_amber, 'label': 'Collect'},
        {'icon': Icons.science, 'label': 'Classify'},
        {'icon': Icons.local_fire_department, 'label': 'Treat'},
        {'icon': Icons.shield, 'label': 'Dispose'},
      ],
      'description': 'Chemicals & hazardous materials are safely treated and disposed.',
      'impact': 'Protects environment',
      'resultIcon': Icons.eco,
      'resultLabel': 'Safe Disposal',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recyclingPageController.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.name ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildHeaderIcon(
                                    Icons.person_outline, 
                                    'Profile',
                                    () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfileScreen()),
                                  );
                                }),
                                const SizedBox(width: 8),
                                _buildHeaderIcon(
                                    Icons.notifications_outlined, 
                                    'Notifications',
                                    () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationsScreen()),
                                  );
                                }),
                                const SizedBox(width: 8),
                                _buildHeaderIcon(
                                    Icons.settings_outlined,
                                    'Settings',
                                    () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingsScreen()),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFB74D),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB74D).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.lightbulb_outline, color: Color(0xFFFF8F00), size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Eco Tip of the Day',
                                      style: TextStyle(
                                        color: Color(0xFFE65100),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Separate your waste to help reduce landfill impact',
                                      style: TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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

          // Quick Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<List<PickupRequest>>(
                stream: _pickupService.getUserPickups(user?.id ?? ''),
                builder: (context, snapshot) {
                  // Debug: Print connection state and pickup count
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                    );
                  }
                  
                  final pickups = snapshot.data ?? [];
                  
                  // Debug log for troubleshooting
                  debugPrint('User ID: ${user?.id}');
                  debugPrint('Total pickups found: ${pickups.length}');
                  for (var p in pickups) {
                    debugPrint('Pickup: ${p.id} - Status: ${p.status} - UserId: ${p.userId}');
                  }
                  
                  final pending =
                      pickups.where((p) => p.status == 'pending').length;
                  // Include confirmed, assigned, and in_progress as "active" orders
                  final confirmed = pickups.where((p) => 
                      p.status == 'confirmed' || 
                      p.status == 'assigned' || 
                      p.status == 'in_progress').length;
                  final completed =
                      pickups.where((p) => p.status == 'completed').length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF2D3436),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.eco, size: 14, color: AppTheme.primaryGreen),
                                const SizedBox(width: 4),
                                Text(
                                  '${pickups.length} Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Main Stats Container with Gradient
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1A1A2E),
                              Color(0xFF16213E),
                              Color(0xFF0F3460),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F3460).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildGlowingStat(
                                  pending.toString(),
                                  'Pending',
                                  Icons.schedule,
                                  const Color(0xFFFFD93D),
                                ),
                                // Vertical Divider
                                Container(
                                  height: 60,
                                  width: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0),
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                                _buildGlowingStat(
                                  confirmed.toString(),
                                  'Active',
                                  Icons.local_shipping,
                                  const Color(0xFF6BCB77),
                                ),
                                // Vertical Divider
                                Container(
                                  height: 60,
                                  width: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withOpacity(0),
                                        Colors.white.withOpacity(0.3),
                                        Colors.white.withOpacity(0),
                                      ],
                                    ),
                                  ),
                                ),
                                _buildGlowingStat(
                                  completed.toString(),
                                  'Completed',
                                  Icons.celebration,
                                  const Color(0xFF4D96FF),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Completion Rate',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      pickups.isNotEmpty 
                                          ? '${(completed / pickups.length * 100).toInt()}%'
                                          : '0%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Stack(
                                  children: [
                                    // Background with better visibility
                                    Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    // Progress with vibrant gradient
                                    FractionallySizedBox(
                                      widthFactor: pickups.isNotEmpty 
                                          ? completed / pickups.length 
                                          : 0,
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF4D96FF), Color(0xFF6BCB77)],
                                          ),
                                          borderRadius: BorderRadius.circular(5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4D96FF).withOpacity(0.5),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Empty state hint
                                if (pickups.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          size: 12,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Schedule your first pickup to start tracking!',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.6),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Waste Categories - Horizontal Scroll Design
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Waste Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF2D3436),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Horizontal Scrolling Cards
                _buildHorizontalCategoryCards(),
              ],
            ),
          ),

          // Recycling Process Slider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'How Recycling Works',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF2D3436),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Learn More'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _recyclingPageController,
                      onPageChanged: (index) {
                        setState(() => _currentRecyclingPage = index);
                      },
                      itemCount: _recyclingProcesses.length,
                      itemBuilder: (context, index) {
                        return _buildRecyclingCard(_recyclingProcesses[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _recyclingProcesses.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentRecyclingPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentRecyclingPage == index
                              ? AppTheme.primaryGreen
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Pickups',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2D3436),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PickupHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history,
                        size: 18, color: AppTheme.primaryGreen),
                    label: const Text(
                      'View History',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: isDark ? Colors.white : AppTheme.primaryGreen,
                unselectedLabelColor: Colors.grey,
                indicatorColor: isDark ? Colors.white : AppTheme.primaryGreen,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
          ),

          // Pickup List
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPickupList(user?.id ?? '', null),
                _buildPickupList(user?.id ?? '', ['pending', 'confirmed', 'assigned', 'in_progress']),
                _buildPickupList(user?.id ?? '', ['completed']),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chatbot FAB
          FloatingActionButton(
            heroTag: 'chatbot',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotScreen()),
              );
            },
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.9),
            mini: true,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
            tooltip: 'EcoBot Assistant',
          ),
          const SizedBox(height: 12),
          // New Pickup Button
          Container(
            margin: const EdgeInsets.only(bottom: 16, right: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RequestPickupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 6,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: AppTheme.primaryGreen.withOpacity(0.4),
              ),
              icon: const Icon(Icons.add, size: 22),
              label: const Text(
                'New Pickup',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildGlowingStat(String value, String label, IconData icon, Color glowColor) {
    return Column(
      children: [
        // Glowing Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: glowColor, size: 22),
        ),
        const SizedBox(height: 10),
        // Value
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        // Label
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Category data for dynamic grid - Modern vibrant color palette
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Organic',
      'emoji': '🌿',
      'description': 'Food scraps, leaves, garden waste',
      'primaryColor': Color(0xFF059669),
      'secondaryColor': Color(0xFF34D399),
    },
    {
      'name': 'Recyclable',
      'emoji': '📦',
      'description': 'Paper, plastic, glass, metal',
      'primaryColor': Color(0xFF0891B2),
      'secondaryColor': Color(0xFF22D3EE),
    },
    {
      'name': 'E-Waste',
      'emoji': '💻',
      'description': 'Electronics, batteries, cables',
      'primaryColor': Color(0xFFDB2777),
      'secondaryColor': Color(0xFFF472B6),
    },
    {
      'name': 'Hazardous',
      'emoji': '☣️',
      'description': 'Chemicals, paints, medicines',
      'primaryColor': Color(0xFFDC2626),
      'secondaryColor': Color(0xFFFB923C),
    },
    {
      'name': 'General',
      'emoji': '🗑️',
      'description': 'Non-recyclable items',
      'primaryColor': Color(0xFF4B5563),
      'secondaryColor': Color(0xFF9CA3AF),
    },
  ];

  // New Horizontal Category Cards Design
  Widget _buildHorizontalCategoryCards() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: EdgeInsets.only(right: index == _categories.length - 1 ? 0 : 14),
            child: _buildCategoryCard(category, index),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        // Show category details in a bottom sheet
        _showCategoryDetails(category);
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              category['primaryColor'],
              category['secondaryColor'],
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (category['primaryColor'] as Color).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              left: -15,
              bottom: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji icon with glow
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        category['emoji'],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Category name
                  Text(
                    category['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    category['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Tap indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 10,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Tap',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetails(Map<String, dynamic> category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Header with gradient background
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [category['primaryColor'], category['secondaryColor']],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        category['emoji'],
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['description'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Examples section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (category['examples'] as List<String>).map((example) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: (category['primaryColor'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (category['primaryColor'] as Color).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          example,
                          style: TextStyle(
                            color: category['primaryColor'],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category['primaryColor'],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCategoryGrid() {
    // Find featured category and others
    final featured = _categories.firstWhere((c) => c['name'] == _featuredCategory);
    final others = _categories.where((c) => c['name'] != _featuredCategory).toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Column(
        key: ValueKey(_featuredCategory),
        children: [
          // Top Row - Featured + 2 Mini
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured Card (Animated)
              Expanded(
                flex: 2,
                child: _buildAnimatedFeaturedCard(featured),
              ),
              const SizedBox(width: 12),
              // Two stacked mini cards
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildTappableMiniCard(others[0]),
                    const SizedBox(height: 12),
                    _buildTappableMiniCard(others[1]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom Row - Two compact cards
          Row(
            children: [
              Expanded(child: _buildTappableCompactCard(others[2])),
              const SizedBox(width: 12),
              Expanded(child: _buildTappableCompactCard(others[3])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFeaturedCard(Map<String, dynamic> category) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [category['primaryColor'], category['secondaryColor']],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (category['primaryColor'] as Color).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(category['emoji'], style: const TextStyle(fontSize: 24)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    const Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category['description'],
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

  Widget _buildTappableMiniCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => setState(() => _featuredCategory = category['name']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 69,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: (category['primaryColor'] as Color).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (category['primaryColor'] as Color).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (category['primaryColor'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(category['emoji'], style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category['name'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: category['primaryColor'],
                ),
              ),
            ),
            Icon(
              Icons.open_in_full,
              size: 14,
              color: (category['primaryColor'] as Color).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTappableCompactCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => setState(() => _featuredCategory = category['name']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (category['primaryColor'] as Color).withOpacity(0.15),
              (category['secondaryColor'] as Color).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (category['primaryColor'] as Color).withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [category['primaryColor'], category['secondaryColor']],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (category['primaryColor'] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(category['emoji'], style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: category['primaryColor'],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category['description'],
                    style: TextStyle(
                      fontSize: 10,
                      color: (category['primaryColor'] as Color).withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_full,
              size: 14,
              color: (category['primaryColor'] as Color).withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCategoryCard(
      String title, String emoji, String description, Color primaryColor, Color secondaryColor) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
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

  Widget _buildMiniCategoryCard(String title, String emoji, Color color) {
    return Container(
      height: 69,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCategoryCard(
      String title, String emoji, String description, Color primaryColor, Color secondaryColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.15),
            secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, secondaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: primaryColor.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupList(String userId, List<String>? statusFilter) {
    return StreamBuilder<List<PickupRequest>>(
      stream: _pickupService.getUserPickups(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading pickups',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        var pickups = snapshot.data ?? [];
        if (statusFilter != null) {
          pickups =
              pickups.where((p) => statusFilter.contains(p.status)).toList();
        }

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
                        color: AppTheme.lightGreen.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 48,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pickup requests yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to request a pickup',
                      style: TextStyle(color: Colors.grey[500]),
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
            final pickup = pickups[index];
            return _buildPickupCard(pickup);
          },
        );
      },
    );
  }

  Widget _buildPickupCard(PickupRequest pickup) {
    final statusColor = AppTheme.getStatusColor(pickup.status);
    final wasteColor = AppTheme.getWasteTypeColor(pickup.wasteType);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PickupDetailScreen(pickup: pickup),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: wasteColor.withOpacity(0.1),
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy')
                                .format(pickup.scheduledDate),
                            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pickup.address,
                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (pickup.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note_outlined,
                          size: 16, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pickup.notes,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(isDark ? 0.15 : 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${pickup.id.substring(0, 8)}...',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Created ${_getTimeAgo(pickup.createdAt)}',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
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

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  Widget _buildRecyclingCard(Map<String, dynamic> process) {
    final Color color = process['color'] as Color;
    final List<Map<String, dynamic>> steps = process['steps'] as List<Map<String, dynamic>>;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    process['emoji'] as String,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        process['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '✓ ${process['impact']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Process Steps with Icons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Visual Process Flow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(steps.length * 2 - 1, (index) {
                      if (index.isOdd) {
                        return Icon(
                          Icons.arrow_forward,
                          color: color.withOpacity(0.5),
                          size: 20,
                        );
                      }
                      final stepIndex = index ~/ 2;
                      final step = steps[stepIndex];
                      return Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              step['icon'] as IconData,
                              color: color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  
                  const Spacer(),
                  
                  // Result Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            process['resultIcon'] as IconData,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Result: ${process['resultLabel']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: color,
                                ),
                              ),
                              Text(
                                process['description'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

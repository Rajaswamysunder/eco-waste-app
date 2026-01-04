import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../utils/app_theme.dart';
import '../../models/pickup_request.dart';
import '../../services/pickup_service.dart';
import '../../providers/user_provider.dart';
import '../../widgets/shimmer_loading.dart';
import '../../l10n/generated/app_localizations.dart';
import 'pickup_detail_screen.dart';

class PickupHistoryScreen extends StatefulWidget {
  const PickupHistoryScreen({super.key});

  @override
  State<PickupHistoryScreen> createState() => _PickupHistoryScreenState();
}

class _PickupHistoryScreenState extends State<PickupHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final PickupService _pickupService = PickupService();
  bool _showStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
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
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
              ),
            ),
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
                      mainAxisAlignment: MainAxisAlignment.end,
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
                                Icons.history,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.pickupHistory,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!.viewPastPickups,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryGreen,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppTheme.primaryGreen,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(text: AppLocalizations.of(context)!.all),
                    Tab(text: AppLocalizations.of(context)!.completed),
                    Tab(text: AppLocalizations.of(context)!.cancelled),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: StreamBuilder<List<PickupRequest>>(
          stream: _pickupService.getUserPickups(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) => const PickupCardSkeleton(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final allPickups = snapshot.data!;
            final completedPickups =
                allPickups.where((p) => p.status == 'completed').toList();
            final cancelledPickups =
                allPickups.where((p) => p.status == 'cancelled').toList();

            return Column(
              children: [
                // Animated Stats Section
                if (_showStats) _buildAnimatedStatsSection(allPickups),
                // Tab View
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPickupList(allPickups),
                      _buildPickupList(completedPickups),
                      _buildPickupList(cancelledPickups),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                  Icons.inbox_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No pickups yet',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your pickup history will appear here',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedStatsSection(List<PickupRequest> pickups) {
    final completed = pickups.where((p) => p.status == 'completed').length;
    final pending = pickups.where((p) => p.status == 'pending').length;
    final inProgress = pickups.where((p) => p.status == 'assigned' || p.status == 'in_progress').length;
    final total = pickups.length;
    final completionRate = total > 0 ? (completed / total * 100) : 0.0;
    
    // Calculate eco impact
    final totalQuantity = pickups.fold<int>(0, (sum, p) => sum + (int.tryParse(p.quantity.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1));
    final co2Saved = (totalQuantity * 2.5).toStringAsFixed(1); // kg CO2
    final treesEquivalent = (totalQuantity * 0.1).toStringAsFixed(1);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main Stats Row with Glassmorphism
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.9),
                        const Color(0xFF00897B),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Circular Progress with Stats
                      Row(
                        children: [
                          // Animated Circular Progress
                          _buildCircularProgress(completionRate, completed, total),
                          const SizedBox(width: 20),
                          // Quick Stats
                          Expanded(
                            child: Column(
                              children: [
                                _buildQuickStatRow(
                                  Icons.pending_actions,
                                  'Pending',
                                  pending.toString(),
                                  Colors.amber,
                                ),
                                const SizedBox(height: 12),
                                _buildQuickStatRow(
                                  Icons.local_shipping,
                                  'In Progress',
                                  inProgress.toString(),
                                  Colors.blue,
                                ),
                                const SizedBox(height: 12),
                                _buildQuickStatRow(
                                  Icons.check_circle,
                                  'Completed',
                                  completed.toString(),
                                  Colors.lightGreenAccent,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Eco Impact Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildImpactMetric('🌍', '$co2Saved kg', 'CO₂ Saved'),
                          _buildImpactMetric('🌳', treesEquivalent, 'Trees Equiv.'),
                          _buildImpactMetric('♻️', total.toString(), 'Total Pickups'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Toggle Stats Button
                GestureDetector(
                  onTap: () => setState(() => _showStats = !_showStats),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showStats ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showStats ? 'Hide Stats' : 'Show Stats',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(double percentage, int completed, int total) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.1)),
            ),
          ),
          // Progress Circle
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage / 100),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 12,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              );
            },
          ),
          // Center Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: percentage),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Text(
                    '${value.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const Text(
                'Success Rate',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactMetric(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPickupList(List<PickupRequest> pickups) {
    if (pickups.isEmpty) {
      return _buildEmptyState();
    }

    // Group pickups by month
    final grouped = <String, List<PickupRequest>>{};
    for (var pickup in pickups) {
      final monthYear = DateFormat('MMMM yyyy').format(pickup.scheduledDate);
      grouped.putIfAbsent(monthYear, () => []);
      grouped[monthYear]!.add(pickup);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final monthYear = grouped.keys.elementAt(index);
        final monthPickups = grouped[monthYear]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                monthYear,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
            ...monthPickups.map((pickup) => _buildPickupCard(pickup)),
          ],
        );
      },
    );
  }

  Widget _buildPickupCard(PickupRequest pickup) {
    final wasteColor = AppTheme.getWasteTypeColor(pickup.wasteType);

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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Waste Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: wasteColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getWasteIcon(pickup.wasteType),
                  color: wasteColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pickup.wasteType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        StatusBadge(status: pickup.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(pickup.scheduledDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          pickup.timeSlot,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          'Qty: ${pickup.quantity}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
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
}

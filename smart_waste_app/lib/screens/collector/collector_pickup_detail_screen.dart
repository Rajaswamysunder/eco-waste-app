import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../models/pickup_request.dart';
import '../../services/pickup_service.dart';

class CollectorPickupDetailScreen extends StatefulWidget {
  final PickupRequest pickup;
  final String collectorId;
  final String collectorName;

  const CollectorPickupDetailScreen({
    super.key,
    required this.pickup,
    required this.collectorId,
    required this.collectorName,
  });

  @override
  State<CollectorPickupDetailScreen> createState() =>
      _CollectorPickupDetailScreenState();
}

class _CollectorPickupDetailScreenState
    extends State<CollectorPickupDetailScreen> {
  final PickupService _pickupService = PickupService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getStatusColor(widget.pickup.status);
    final wasteColor = AppTheme.getWasteTypeColor(widget.pickup.wasteType);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: wasteColor,
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
                actions: [
                  IconButton(
                    onPressed: () => _callUser(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Icon(Icons.phone, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [wasteColor, wasteColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
                                  child: Icon(
                                    _getWasteIcon(widget.pickup.wasteType),
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.pickup.wasteType,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Quantity: ${widget.pickup.quantity}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: widget.pickup.status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Card
                      _buildSectionTitle('Customer Details', Icons.person),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  widget.pickup.userName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pickup.userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.phone,
                                  color: AppTheme.primaryGreen,
                                  onTap: _callUser,
                                ),
                                const SizedBox(width: 8),
                                _buildActionButton(
                                  icon: Icons.message,
                                  color: AppTheme.accentBlue,
                                  onTap: _messageUser,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Schedule Card
                      _buildSectionTitle('Schedule', Icons.schedule),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.calendar_month,
                                label: 'Date',
                                value: DateFormat('EEE, MMM dd')
                                    .format(widget.pickup.scheduledDate),
                                color: AppTheme.accentBlue,
                              ),
                            ),
                            Container(
                              height: 60,
                              width: 1,
                              color: Colors.grey[200],
                            ),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.access_time,
                                label: 'Time Slot',
                                value: widget.pickup.timeSlot.toUpperCase(),
                                color: AppTheme.accentPurple,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Location Card
                      _buildSectionTitle('Pickup Location', Icons.location_on),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.accentOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: AppTheme.accentOrange,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    widget.pickup.address,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                onPressed: _openMaps,
                                gradient: AppTheme.blueGradient,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.directions,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Get Directions',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (widget.pickup.notes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSectionTitle('Customer Notes', Icons.note),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber[200]!),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.amber[700], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.pickup.notes,
                                  style: TextStyle(
                                    color: Colors.amber[900],
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: _buildActionButtons(),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    switch (widget.pickup.status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _updateStatus('cancelled'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Decline',
                    style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: GradientButton(
                onPressed: () => _updateStatus('confirmed'),
                gradient: AppTheme.primaryGradient,
                child: const Text(
                  'Accept Pickup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      case 'confirmed':
        return GradientButton(
          onPressed: () => _updateStatus('in_progress'),
          gradient: AppTheme.blueGradient,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Start Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case 'in_progress':
        return GradientButton(
          onPressed: () => _updateStatus('completed'),
          gradient: const LinearGradient(
            colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Mark as Completed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      case 'completed':
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.completedColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppTheme.completedColor),
              SizedBox(width: 8),
              Text(
                'Collection Completed',
                style: TextStyle(
                  color: AppTheme.completedColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
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

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);

    try {
      await _pickupService.updatePickupStatus(
        widget.pickup.id,
        newStatus,
        collectorId: widget.collectorId,
        collectorName: widget.collectorName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pickup marked as $newStatus'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _callUser() async {
    // TODO: Get user phone from Firestore and call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling customer...')),
    );
  }

  void _messageUser() {
    // TODO: Open SMS or chat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening messaging...')),
    );
  }

  void _openMaps() async {
    final address = Uri.encodeComponent(widget.pickup.address);
    final mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$address';

    try {
      await launchUrl(Uri.parse(mapsUrl));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps')),
        );
      }
    }
  }
}

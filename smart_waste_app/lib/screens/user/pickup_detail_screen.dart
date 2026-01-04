import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../models/pickup_request.dart';
import '../../services/pickup_service.dart';

class PickupDetailScreen extends StatefulWidget {
  final PickupRequest pickup;

  const PickupDetailScreen({super.key, required this.pickup});

  @override
  State<PickupDetailScreen> createState() => _PickupDetailScreenState();
}

class _PickupDetailScreenState extends State<PickupDetailScreen> {
  final PickupService _pickupService = PickupService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PickupRequest?>(
      stream: _pickupService.getPickupById(widget.pickup.id),
      builder: (context, snapshot) {
        final pickup = snapshot.data ?? widget.pickup;
        final statusColor = AppTheme.getStatusColor(pickup.status);
        final wasteColor = AppTheme.getWasteTypeColor(pickup.wasteType);

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
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
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  ),
                ),
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
                                  child: Icon(_getWasteIcon(pickup.wasteType), color: Colors.white, size: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pickup.wasteType, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                      Text('Quantity: ${pickup.quantity}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: statusColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('Current Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                          const SizedBox(width: 4),
                                          const Text('Live', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                StatusBadge(status: pickup.status),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildStatusTimeline(pickup.status),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Schedule', Icons.calendar_today, isDark),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Row(
                          children: [
                            Expanded(child: _buildInfoCard(icon: Icons.calendar_month, label: 'Date', value: DateFormat('EEE, MMM dd, yyyy').format(pickup.scheduledDate), color: AppTheme.accentBlue, isDark: isDark)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildInfoCard(icon: Icons.access_time, label: 'Time', value: pickup.timeSlot.toUpperCase(), color: AppTheme.accentPurple, isDark: isDark)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Pickup Location', Icons.location_on, isDark),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.location_on, color: AppTheme.accentOrange)),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Address', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 12)), const SizedBox(height: 4), Text(pickup.address, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87))])),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildMapView(pickup.address),
                          ],
                        ),
                      ),
                      if (pickup.collectorName != null) ...[
                        const SizedBox(height: 20),
                        _buildSectionTitle('Collector', Icons.person, isDark),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: Row(
                            children: [
                              Container(width: 60, height: 60, decoration: BoxDecoration(gradient: AppTheme.blueGradient, borderRadius: BorderRadius.circular(16)), child: Center(child: Text(pickup.collectorName![0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)))),
                              const SizedBox(width: 16),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(pickup.collectorName!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
                                const SizedBox(height: 4), 
                                const Text('Waste Collector', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                if (pickup.collectorPhone != null && pickup.collectorPhone!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(pickup.collectorPhone!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ])),
                              GestureDetector(
                                onTap: () => _callCollector(pickup.collectorPhone),
                                child: Container(
                                  padding: const EdgeInsets.all(14), 
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)]),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                                  ), 
                                  child: const Icon(Icons.phone, color: Colors.white, size: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (pickup.notes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionTitle('Notes', Icons.note),
                        const SizedBox(height: 12),
                        Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber[200]!)), child: Text(pickup.notes, style: TextStyle(color: Colors.amber[900], fontSize: 14, height: 1.5))),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Request ID: ${pickup.id.substring(0, 8)}...', style: TextStyle(color: Colors.grey[600], fontSize: 12)), Text('Created ${_getTimeAgo(pickup.createdAt)}', style: TextStyle(color: Colors.grey[600], fontSize: 12))]),
                      ),
                      const SizedBox(height: 24),
                      if (pickup.status == 'pending')
                        OutlinedButton.icon(
                          onPressed: () => _showCancelDialog(context, pickup.id),
                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                          label: const Text('Cancel Request', style: TextStyle(color: Colors.red)),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), minimumSize: const Size(double.infinity, 50)),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, [bool isDark = false]) {
    return Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppTheme.primaryGreen, size: 18)), const SizedBox(width: 12), Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2D3436)))]);
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = ['pending', 'confirmed', 'in_progress', 'completed'];
    final statusLabels = ['Requested', 'Assigned', 'On the Way', 'Collected'];
    final statusIcons = [Icons.description_outlined, Icons.assignment_turned_in, Icons.local_shipping, Icons.check_circle];
    int currentIndex = statuses.indexOf(currentStatus);
    if (currentStatus == 'assigned') currentIndex = 1;
    
    return Column(
      children: [
        Row(
          children: List.generate(statuses.length * 2 - 1, (index) {
            if (index.isOdd) {
              final stepIndex = index ~/ 2;
              return Expanded(child: Container(height: 3, color: stepIndex < currentIndex ? AppTheme.completedColor : Colors.grey[300]));
            } else {
              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex <= currentIndex;
              final isCurrent = stepIndex == currentIndex;
              return Container(
                width: 36, 
                height: 36, 
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.completedColor : Colors.grey[300], 
                  shape: BoxShape.circle, 
                  border: isCurrent ? Border.all(color: AppTheme.completedColor.withOpacity(0.3), width: 4) : null,
                  boxShadow: isCurrent ? [BoxShadow(color: AppTheme.completedColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)] : null,
                ), 
                child: Center(child: Icon(statusIcons[stepIndex], color: Colors.white, size: 18)),
              );
            }
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(statuses.length, (index) {
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;
            return SizedBox(
              width: 70,
              child: Text(
                statusLabels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCompleted ? AppTheme.completedColor : Colors.grey[400],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value, required Color color, bool isDark = false}) {
    return Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)), const SizedBox(height: 8), Text(label, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey, fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center)]);
  }

  IconData _getWasteIcon(String type) {
    switch (type.toLowerCase()) {
      case 'organic': return Icons.eco;
      case 'recyclable': return Icons.recycling;
      case 'e-waste': return Icons.devices;
      case 'hazardous': return Icons.warning_amber;
      default: return Icons.delete;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    return '${difference.inMinutes}m ago';
  }

  // Map of common Indian cities to coordinates
  LatLng _getCoordinatesFromAddress(String address) {
    final addressLower = address.toLowerCase();
    
    // Tamil Nadu cities
    if (addressLower.contains('trichy') || addressLower.contains('tiruchirappalli')) {
      return const LatLng(10.7905, 78.7047);
    } else if (addressLower.contains('chennai')) {
      return const LatLng(13.0827, 80.2707);
    } else if (addressLower.contains('madurai')) {
      return const LatLng(9.9252, 78.1198);
    } else if (addressLower.contains('coimbatore')) {
      return const LatLng(11.0168, 76.9558);
    } else if (addressLower.contains('salem')) {
      return const LatLng(11.6643, 78.1460);
    } else if (addressLower.contains('tirunelveli')) {
      return const LatLng(8.7139, 77.7567);
    } else if (addressLower.contains('erode')) {
      return const LatLng(11.3410, 77.7172);
    } else if (addressLower.contains('vellore')) {
      return const LatLng(12.9165, 79.1325);
    } else if (addressLower.contains('thanjavur')) {
      return const LatLng(10.7870, 79.1378);
    } else if (addressLower.contains('dindigul')) {
      return const LatLng(10.3673, 77.9803);
    }
    // Major Indian cities
    else if (addressLower.contains('bangalore') || addressLower.contains('bengaluru')) {
      return const LatLng(12.9716, 77.5946);
    } else if (addressLower.contains('hyderabad')) {
      return const LatLng(17.3850, 78.4867);
    } else if (addressLower.contains('mumbai')) {
      return const LatLng(19.0760, 72.8777);
    } else if (addressLower.contains('delhi')) {
      return const LatLng(28.7041, 77.1025);
    } else if (addressLower.contains('kolkata')) {
      return const LatLng(22.5726, 88.3639);
    } else if (addressLower.contains('pune')) {
      return const LatLng(18.5204, 73.8567);
    } else if (addressLower.contains('ahmedabad')) {
      return const LatLng(23.0225, 72.5714);
    } else if (addressLower.contains('jaipur')) {
      return const LatLng(26.9124, 75.7873);
    } else if (addressLower.contains('kochi') || addressLower.contains('cochin')) {
      return const LatLng(9.9312, 76.2673);
    }
    // Default: Trichy (your location)
    return const LatLng(10.7905, 78.7047);
  }

  Widget _buildMapView(String address) {
    final location = _getCoordinatesFromAddress(address);
    
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.smartwaste.smart_waste_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            // Open in Maps button
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _openInMaps(location, address),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions, size: 16, color: AppTheme.primaryGreen),
                      SizedBox(width: 4),
                      Text(
                        'Directions',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Map attribution
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '© OpenStreetMap',
                  style: TextStyle(fontSize: 8, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps(LatLng location, String address) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _callCollector(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      // Show dialog to enter phone number manually or show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.phone_disabled, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Collector phone number not available')),
              ],
            ),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }
    
    // Clean phone number (remove spaces, dashes, etc.)
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$cleanNumber');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Could not call $phoneNumber')),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, String pickupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)), child: Icon(Icons.cancel, color: Colors.red[400])), const SizedBox(width: 12), const Text('Cancel Request')]),
        content: const Text('Are you sure you want to cancel this pickup request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('No', style: TextStyle(color: Colors.grey[600]))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _pickupService.cancelPickup(pickupId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pickup request cancelled'), backgroundColor: Colors.orange));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

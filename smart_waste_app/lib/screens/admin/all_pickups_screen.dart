import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/pickup_service.dart';
import '../../services/admin_service.dart';
import '../../models/pickup_request.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';

class AllPickupsScreen extends StatefulWidget {
  const AllPickupsScreen({super.key});

  @override
  State<AllPickupsScreen> createState() => _AllPickupsScreenState();
}

class _AllPickupsScreenState extends State<AllPickupsScreen>
    with SingleTickerProviderStateMixin {
  final PickupService _pickupService = PickupService();
  final AdminService _adminService = AdminService();
  late TabController _tabController;
  
  // Filter options
  String _selectedWasteType = 'All';
  String _selectedArea = 'All';
  DateTime? _selectedDate;
  
  final List<String> _wasteTypes = ['All', 'Organic', 'Recyclable', 'E-Waste', 'Hazardous', 'General'];
  final List<String> _areas = ['All', 'Main Street', 'Oak Avenue', 'Pine Road', 'Elm Street', 'Cedar Lane'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF9C27B0),
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
                onPressed: _showFilterDialog,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(left: 60, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Pickups',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Monitor and manage all pickup requests',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Assigned'),
                Tab(text: 'In Progress'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            // Filter chips bar
            if (_selectedWasteType != 'All' || _selectedArea != 'All' || _selectedDate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_selectedWasteType != 'All')
                        _buildFilterChip(_selectedWasteType, () {
                          setState(() => _selectedWasteType = 'All');
                        }),
                      if (_selectedArea != 'All')
                        _buildFilterChip(_selectedArea, () {
                          setState(() => _selectedArea = 'All');
                        }),
                      if (_selectedDate != null)
                        _buildFilterChip(
                          DateFormat('MMM dd').format(_selectedDate!),
                          () {
                            setState(() => _selectedDate = null);
                          },
                        ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedWasteType = 'All';
                            _selectedArea = 'All';
                            _selectedDate = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear all'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPickupsList('pending'),
                  _buildPickupsListMulti(['assigned', 'confirmed']), // Both assigned & confirmed
                  _buildPickupsList('in_progress'),
                  _buildPickupsList('completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupsList(String status) {
    return StreamBuilder<List<PickupRequest>>(
      stream: _pickupService.getPickupsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
          );
        }

        var pickups = snapshot.data ?? [];
        
        // Apply filters
        if (_selectedWasteType != 'All') {
          pickups = pickups.where((p) => 
            p.wasteType.toLowerCase() == _selectedWasteType.toLowerCase()).toList();
        }
        if (_selectedArea != 'All') {
          pickups = pickups.where((p) => 
            p.street?.toLowerCase().contains(_selectedArea.toLowerCase()) ?? false).toList();
        }
        if (_selectedDate != null) {
          pickups = pickups.where((p) => 
            p.scheduledDate.year == _selectedDate!.year &&
            p.scheduledDate.month == _selectedDate!.month &&
            p.scheduledDate.day == _selectedDate!.day).toList();
        }

        if (pickups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status == 'completed' ? Icons.check_circle : Icons.inbox,
                    size: 48,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${status.replaceAll('_', ' ')} pickups',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: pickups.length,
          itemBuilder: (context, index) =>
              _buildPickupCard(pickups[index], status),
        );
      },
    );
  }

  // For tabs that need multiple statuses (e.g., Assigned tab shows both 'assigned' and 'confirmed')
  Widget _buildPickupsListMulti(List<String> statuses) {
    return StreamBuilder<List<PickupRequest>>(
      stream: _pickupService.getPickupsByStatuses(statuses),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
          );
        }

        var pickups = snapshot.data ?? [];
        
        // Apply filters
        if (_selectedWasteType != 'All') {
          pickups = pickups.where((p) => 
            p.wasteType.toLowerCase() == _selectedWasteType.toLowerCase()).toList();
        }
        if (_selectedArea != 'All') {
          pickups = pickups.where((p) => 
            p.street?.toLowerCase().contains(_selectedArea.toLowerCase()) ?? false).toList();
        }
        if (_selectedDate != null) {
          pickups = pickups.where((p) => 
            p.scheduledDate.year == _selectedDate!.year &&
            p.scheduledDate.month == _selectedDate!.month &&
            p.scheduledDate.day == _selectedDate!.day).toList();
        }

        if (pickups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.inbox,
                    size: 48,
                    color: Color(0xFF9C27B0),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No assigned pickups',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: pickups.length,
          itemBuilder: (context, index) =>
              _buildPickupCard(pickups[index], pickups[index].status),
        );
      },
    );
  }

  Widget _buildPickupCard(PickupRequest pickup, String status) {
    final wasteColor = AppTheme.getWasteTypeColor(pickup.wasteType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [wasteColor.withOpacity(0.1), wasteColor.withOpacity(0.05)],
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Qty: ${pickup.quantity}',
                          style: TextStyle(
                            color: Colors.grey[600],
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.person_outline, pickup.userName),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone_outlined, pickup.userPhone),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, pickup.address),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  '${DateFormat('EEE, MMM dd').format(pickup.scheduledDate)} • ${pickup.timeSlot.toUpperCase()}',
                ),
                const SizedBox(height: 8),
                // Always show collector assignment status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: pickup.collectorName != null 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: pickup.collectorName != null 
                        ? Colors.green.withOpacity(0.3) 
                        : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        pickup.collectorName != null 
                          ? Icons.local_shipping 
                          : Icons.person_off,
                        size: 16,
                        color: pickup.collectorName != null 
                          ? Colors.green[700] 
                          : Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pickup.collectorName != null 
                            ? 'Assigned to: ${pickup.collectorName}'
                            : 'Not assigned to any collector',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: pickup.collectorName != null 
                              ? Colors.green[700] 
                              : Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (pickup.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, color: Colors.amber[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pickup.notes,
                            style: TextStyle(color: Colors.amber[900], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Delete button for admin
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _deletePickup(pickup),
                    icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 18),
                    label: Text('Delete Pickup',
                        style: TextStyle(color: Colors.red[400])),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (status == 'pending')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _assignCollector(pickup),
                  icon: const Icon(Icons.person_add, color: Colors.white, size: 18),
                  label: const Text('Assign Collector',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pendingColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Delete pickup with confirmation
  Future<void> _deletePickup(PickupRequest pickup) async {
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
              child: Icon(Icons.delete_forever, color: Colors.red[400]),
            ),
            const SizedBox(width: 12),
            const Text('Delete Pickup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to permanently delete this pickup?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pickup.wasteType} - Qty: ${pickup.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('User: ${pickup.userName}'),
                  Text('Status: ${pickup.status}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone!',
              style: TextStyle(color: Colors.red[600], fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _pickupService.deletePickup(pickup.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pickup deleted successfully'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting pickup: $e'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700], fontSize: 13),
          ),
        ),
      ],
    );
  }

  Future<void> _assignCollector(PickupRequest pickup) async {
    // Get collectors for the pickup's street
    final collectorsSnapshot = await _adminService.getAllCollectors().first;
    final collectors = collectorsSnapshot
        .where((c) =>
            c.assignedStreet == pickup.street || c.assignedStreet == null)
        .toList();

    if (!mounted) return;

    if (collectors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No collectors available for this street'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    UserModel? selectedCollector;

    final result = await showDialog<UserModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Collector'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<UserModel>(
                  value: selectedCollector,
                  decoration: const InputDecoration(
                    labelText: 'Select Collector',
                    border: OutlineInputBorder(),
                  ),
                  items: collectors.map((collector) {
                    return DropdownMenuItem(
                      value: collector,
                      child: Text(
                        '${collector.name} (${collector.assignedStreet ?? 'No street'})',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCollector = value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedCollector),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _pickupService.assignCollector(
        pickup.id,
        result.uid,
        result.name,
        collectorPhone: result.phone,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pickup assigned to ${result.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
        labelStyle: const TextStyle(color: Color(0xFF9C27B0)),
        deleteIconColor: const Color(0xFF9C27B0),
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    String tempWasteType = _selectedWasteType;
    String tempArea = _selectedArea;
    DateTime? tempDate = _selectedDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_list, color: Color(0xFF9C27B0)),
                ),
                const SizedBox(width: 12),
                const Text('Filter Pickups'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Waste Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempWasteType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.delete_outline),
                    ),
                    items: _wasteTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => tempWasteType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Area/Street', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: tempArea,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    items: _areas.map((area) {
                      return DropdownMenuItem(value: area, child: Text(area));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => tempArea = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Scheduled Date', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: tempDate ?? DateTime.now(),
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );
                      if (date != null) {
                        setDialogState(() => tempDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            tempDate != null 
                              ? DateFormat('MMM dd, yyyy').format(tempDate!)
                              : 'Select date',
                            style: TextStyle(
                              color: tempDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          if (tempDate != null)
                            IconButton(
                              onPressed: () {
                                setDialogState(() => tempDate = null);
                              },
                              icon: const Icon(Icons.clear, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedWasteType = tempWasteType;
                    _selectedArea = tempArea;
                    _selectedDate = tempDate;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply Filters'),
              ),
            ],
          );
        },
      ),
    );
  }
}

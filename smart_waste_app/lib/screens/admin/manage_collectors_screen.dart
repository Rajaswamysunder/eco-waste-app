import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/pickup_service.dart';
import '../../models/user_model.dart';
import '../../models/pickup_request.dart';

class ManageCollectorsScreen extends StatefulWidget {
  const ManageCollectorsScreen({super.key});

  @override
  State<ManageCollectorsScreen> createState() => _ManageCollectorsScreenState();
}

class _ManageCollectorsScreenState extends State<ManageCollectorsScreen> {
  final AdminService _adminService = AdminService();
  final PickupService _pickupService = PickupService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Collectors'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCollectorDialog,
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Collector', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _adminService.getAllCollectors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final collectors = snapshot.data ?? [];

          if (collectors.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_pin_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No collectors found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Promote users to collectors from Manage Users',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: collectors.length,
            itemBuilder: (context, index) =>
                _buildCollectorCard(collectors[index]),
          );
        },
      ),
    );
  }

  Widget _buildCollectorCard(UserModel collector) {
    // Determine status based on if collector has vehicle and street assigned
    final bool isActive = collector.assignedStreet != null && collector.vehicleNumber != null;
    // Use real online status from Firestore
    final bool isOnline = collector.isOnline;
    // Check if last seen was within last 5 minutes for extra validation
    final bool recentlyActive = collector.lastSeen != null && 
        DateTime.now().difference(collector.lastSeen!).inMinutes < 5;
    
    return StreamBuilder<List<PickupRequest>>(
      stream: _pickupService.getPickupsByCollector(collector.uid),
      builder: (context, pickupSnapshot) {
        final assignedPickups = pickupSnapshot.data?.where((p) => 
          p.status == 'assigned' || p.status == 'in_progress').length ?? 0;
        final completedPickups = pickupSnapshot.data?.where((p) => 
          p.status == 'completed').length ?? 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.indigo,
                          radius: 24,
                          child: Text(
                            collector.name.isNotEmpty
                                ? collector.name[0].toUpperCase()
                                : 'C',
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  collector.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Incomplete',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            collector.email,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnline ? Icons.wifi : Icons.wifi_off,
                            size: 12,
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Pickup Stats Row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Assigned', assignedPickups.toString(), Colors.orange),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildStatItem('Completed', completedPickups.toString(), Colors.green),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildStatItem('Total', (assignedPickups + completedPickups).toString(), Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(collector.phone),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        collector.assignedStreet ?? 'No street assigned',
                        style: TextStyle(
                          color: collector.assignedStreet != null
                              ? Colors.black
                              : Colors.red,
                          fontWeight: collector.assignedStreet != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        collector.vehicleNumber != null
                            ? '${collector.vehicleType ?? 'Vehicle'} - ${collector.vehicleNumber}'
                            : 'No vehicle assigned',
                        style: TextStyle(
                          color: collector.vehicleNumber != null
                              ? Colors.black
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _assignStreet(collector),
                    icon: const Icon(Icons.edit_location),
                    label: Text(collector.assignedStreet != null
                        ? 'Change Street'
                        : 'Assign Street'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _assignStreet(UserModel collector) async {
    final streets = await _adminService.getAllStreets();
    String? selectedStreet = collector.assignedStreet;

    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Street to ${collector.name}'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStreet,
                  decoration: const InputDecoration(
                    labelText: 'Select Street',
                    border: OutlineInputBorder(),
                  ),
                  items: streets.map((street) {
                    return DropdownMenuItem(
                      value: street,
                      child: Text(street),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedStreet = value);
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
            onPressed: () => Navigator.pop(context, selectedStreet),
            child: const Text('Assign'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _adminService.assignStreetToCollector(collector.uid, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${collector.name} assigned to $result'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showAddCollectorDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final vehicleNumberController = TextEditingController();
    String? selectedStreet;
    String? selectedVehicleType;

    final streets = await _adminService.getAllStreets();
    final vehicleTypes = _adminService.getVehicleTypes();

    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Color(0xFF2E7D32),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Add New Collector',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Personal Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Enter collector\'s full name',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Enter a valid email address',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        if (!value!.contains('@')) return 'Invalid email format (must contain @)';
                        if (!value.contains('.')) return 'Invalid email format (must contain domain)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone *',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Phone must be 10 digits',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Phone is required';
                        if (value!.length < 10) return 'Phone must be at least 10 digits';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Address *',
                        prefixIcon: const Icon(Icons.home),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Full residential address',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Address is required' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Vehicle Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatefulBuilder(
                      builder: (context, setDialogState) {
                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: selectedVehicleType,
                              decoration: InputDecoration(
                                labelText: 'Vehicle Type',
                                prefixIcon: const Icon(Icons.local_shipping),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: vehicleTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() => selectedVehicleType = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: vehicleNumberController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                labelText: 'Vehicle Number',
                                hintText: 'e.g., TN 01 AB 1234',
                                prefixIcon: const Icon(Icons.confirmation_number),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                helperText: 'Format: State Code + Number',
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Assignment (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: selectedStreet,
                              decoration: InputDecoration(
                                labelText: 'Assign Street',
                                prefixIcon: const Icon(Icons.map),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                helperText: 'Select a street to assign',
                              ),
                              items: streets.map((street) {
                                return DropdownMenuItem(
                                  value: street,
                                  child: Text(street),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() => selectedStreet = value);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Required field indicator
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '* indicates required fields. Vehicle and street can be added later.',
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(context, true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Add Collector'),
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
    );

    if (result == true) {
      try {
        await _adminService.createCollector(
          email: emailController.text.trim(),
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
          assignedStreet: selectedStreet,
          vehicleNumber: vehicleNumberController.text.trim().isNotEmpty
              ? vehicleNumberController.text.trim()
              : null,
          vehicleType: selectedVehicleType,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Collector ${nameController.text} added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding collector: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

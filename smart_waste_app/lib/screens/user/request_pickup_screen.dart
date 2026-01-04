import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/pickup_service.dart';
import '../../models/pickup_request.dart';
import 'location_picker_screen.dart';

class RequestPickupScreen extends StatefulWidget {
  const RequestPickupScreen({super.key});

  @override
  State<RequestPickupScreen> createState() => _RequestPickupScreenState();
}

class _RequestPickupScreenState extends State<RequestPickupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedWasteType = 'Organic';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  bool _useProfileAddress = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _wasteTypes = [
    {
      'name': 'Organic',
      'icon': Icons.eco,
      'emoji': '🌱',
      'color': AppTheme.organicColor,
      'description': 'Food waste, garden waste, biodegradables',
    },
    {
      'name': 'Recyclable',
      'icon': Icons.recycling,
      'emoji': '♻️',
      'color': AppTheme.recyclableColor,
      'description': 'Paper, plastic, glass, metal',
    },
    {
      'name': 'E-Waste',
      'icon': Icons.devices,
      'emoji': '💻',
      'color': AppTheme.ewasteColor,
      'description': 'Electronics, batteries, cables',
    },
    {
      'name': 'Hazardous',
      'icon': Icons.warning_amber,
      'emoji': '⚠️',
      'color': AppTheme.hazardousColor,
      'description': 'Chemicals, paint, medical waste',
    },
    {
      'name': 'General',
      'icon': Icons.delete,
      'emoji': '🗑️',
      'color': Colors.grey,
      'description': 'Mixed or non-recyclable waste',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Pre-fill address from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        _addressController.text = user.address;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _addressController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3436),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3436),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialAddress: _addressController.text,
        ),
      ),
    );
    
    if (result != null && result['address'] != null) {
      setState(() {
        _addressController.text = result['address'];
        _useProfileAddress = false;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) throw Exception('User not logged in');

      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final pickupService = PickupService();
      await pickupService.createPickupRequest(
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        address: _addressController.text.trim(),
        wasteType: _selectedWasteType,
        quantity: _quantityController.text.trim(),
        scheduledDate: scheduledDateTime,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.completedColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.completedColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Request Submitted! 🎉',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your pickup request has been submitted successfully. You will be notified once a collector confirms your request.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                text: 'Done',
                icon: Icons.home,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
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
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(left: 60, top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Pickup',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Schedule your waste collection',
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
          ),

          // Form
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Waste Type Selection
                      const Text(
                        'Select Waste Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 130,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _wasteTypes.length,
                          itemBuilder: (context, index) {
                            final type = _wasteTypes[index];
                            final isSelected =
                                type['name'] == _selectedWasteType;
                            return GestureDetector(
                              onTap: () => setState(
                                  () => _selectedWasteType = type['name']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 120,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? type['color'].withOpacity(0.15)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? type['color']
                                        : Colors.grey[200]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color:
                                                type['color'].withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      type['emoji'],
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      type['name'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? type['color']
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle,
                                          color: type['color'], size: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getSelectedWasteType()['color']
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: _getSelectedWasteType()['color'],
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _getSelectedWasteType()['description'],
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quantity
                      _buildSectionTitle('Quantity'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _quantityController,
                        hint: 'e.g., 2 bags, 5kg, 1 box',
                        icon: Icons.scale,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Date & Time
                      _buildSectionTitle('Schedule'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateTimePicker(
                              icon: Icons.calendar_today,
                              label: DateFormat('EEE, MMM d').format(_selectedDate),
                              onTap: _selectDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateTimePicker(
                              icon: Icons.access_time,
                              label: _selectedTime.format(context),
                              onTap: _selectTime,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Address
                      _buildSectionTitle('Pickup Address'),
                      const SizedBox(height: 12),
                      Container(
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
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: _useProfileAddress,
                              onChanged: (value) {
                                setState(() {
                                  _useProfileAddress = value!;
                                  if (value) {
                                    final user =
                                        Provider.of<UserProvider>(context,
                                                listen: false)
                                            .user;
                                    _addressController.text =
                                        user?.address ?? '';
                                  }
                                });
                              },
                              title: const Text(
                                'Use profile address',
                                style: TextStyle(fontSize: 14),
                              ),
                              activeColor: AppTheme.primaryGreen,
                              controlAffinity: ListTileControlAffinity.leading,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: TextFormField(
                                controller: _addressController,
                                maxLines: 2,
                                enabled: !_useProfileAddress,
                                decoration: InputDecoration(
                                  hintText: 'Enter pickup address',
                                  prefixIcon: const Icon(Icons.location_on,
                                      color: AppTheme.primaryGreen),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: AppTheme.primaryGreen, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: _useProfileAddress
                                      ? Colors.grey[100]
                                      : Colors.white,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: OutlinedButton.icon(
                                onPressed: _openLocationPicker,
                                icon: const Icon(Icons.map, color: AppTheme.primaryGreen),
                                label: const Text(
                                  'Pick from Map',
                                  style: TextStyle(color: AppTheme.primaryGreen),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.primaryGreen),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Notes
                      _buildSectionTitle('Additional Notes (Optional)'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _notesController,
                        hint: 'Any special instructions for the collector...',
                        icon: Icons.note_alt_outlined,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: 'Submit Request',
                          icon: Icons.send_rounded,
                          onPressed: _isLoading ? null : _submitRequest,
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3436),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDateTimePicker({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getSelectedWasteType() {
    return _wasteTypes.firstWhere(
      (type) => type['name'] == _selectedWasteType,
      orElse: () => _wasteTypes[0],
    );
  }
}

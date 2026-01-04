import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/pickup_service.dart';
import '../../services/reward_service.dart';
import '../../models/user_model.dart';
import '../../models/reward_request.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  bool _notificationsEnabled = true;
  
  // Profile image
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  // Real stats
  int _totalPickups = 0;
  int _completedPickups = 0;
  double _co2Saved = 0;
  int _ecoScore = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PickupService _pickupService = PickupService();
  final RewardService _rewardService = RewardService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    _loadUserStats();
  }
  
  Future<void> _loadUserStats() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;
    
    try {
      final stats = await _pickupService.getUserStats(user.uid);
      if (mounted) {
        setState(() {
          _totalPickups = stats['total'] ?? 0;
          _completedPickups = stats['completed'] ?? 0;
          // Estimate CO2 saved: ~2kg per pickup
          _co2Saved = _completedPickups * 2.0;
          // Calculate eco score: 10 points per completed pickup + bonus for volume
          _ecoScore = (_completedPickups * 10) + (_completedPickups ~/ 5) * 5;
        });
      }
    } catch (e) {
      // Stats will remain at 0
    }
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Profile Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a photo from camera or gallery',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (Provider.of<UserProvider>(context, listen: false).user?.profileImageUrl != null)
                  _buildImagePickerOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfileImage();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper to build profile image from Base64 or URL
  Widget _buildProfileImage(String imageData, String name, {double size = 100}) {
    try {
      // Check if it's a Base64 data URI
      if (imageData.startsWith('data:image')) {
        // Extract the base64 part after the comma
        final base64String = imageData.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(name, size),
        );
      } else {
        // It's a regular URL (for backward compatibility)
        return Image.network(
          imageData,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => _buildInitialAvatar(name, size),
        );
      }
    } catch (e) {
      return _buildInitialAvatar(name, size);
    }
  }

  Widget _buildInitialAvatar(String name, double size) {
    return Container(
      width: size,
      height: size,
      color: AppTheme.primaryGreen.withOpacity(0.1),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadProfileImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to pick image: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) return;

      // Read image and convert to Base64 (FREE - stored in Firestore)
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      
      // Check if image is too large (Firestore has 1MB limit per document)
      if (base64Image.length > 500000) {
        throw Exception('Image is too large. Please choose a smaller image.');
      }

      // Update Firestore with Base64 image
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.updateProfileImage(user.uid, base64Image);

      // Update local user
      final updatedUser = user.copyWith(profileImageUrl: base64Image);
      userProvider.setUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile photo updated!'),
              ],
            ),
            backgroundColor: AppTheme.completedColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Upload failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _selectedImage = null;
        });
      }
    }
  }

  Future<void> _removeProfileImage() async {
    setState(() => _isUploadingImage = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) return;

      // Remove from Firestore (no Firebase Storage to delete with Base64 approach)
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.removeProfileImage(user.uid);

      // Update local user - set profileImageUrl to null
      final updatedUser = UserModel(
        uid: user.uid,
        email: user.email,
        name: user.name,
        phone: user.phone,
        address: user.address,
        role: user.role,
        assignedStreet: user.assignedStreet,
        vehicleNumber: user.vehicleNumber,
        vehicleType: user.vehicleType,
        profileImageUrl: null,
        createdAt: user.createdAt,
        isOnline: user.isOnline,
        lastSeen: user.lastSeen,
      );
      userProvider.setUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile photo removed!'),
              ],
            ),
            backgroundColor: AppTheme.completedColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to remove: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;

      if (currentUser == null) throw Exception('User not found');

      await authService.updateUserProfile(
        uid: currentUser.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      // Update local user data
      final updatedUser = UserModel(
        uid: currentUser.uid,
        email: currentUser.email,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        role: currentUser.role,
        assignedStreet: currentUser.assignedStreet,
        createdAt: currentUser.createdAt,
      );
      userProvider.setUser(updatedUser);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 280,
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
            actions: [
              IconButton(
                onPressed: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar with Profile Image
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: _isUploadingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryGreen,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : _selectedImage != null
                                      ? ClipOval(
                                          child: Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                            width: 100,
                                            height: 100,
                                          ),
                                        )
                                      : user?.profileImageUrl != null
                                          ? ClipOval(
                                              child: _buildProfileImage(user!.profileImageUrl!, user.name),
                                            )
                                          : Center(
                                              child: Text(
                                                user?.name.isNotEmpty == true
                                                    ? user!.name[0].toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryGreen,
                                                ),
                                              ),
                                            ),
                            ),
                            // Camera icon overlay
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.role.toUpperCase() ?? 'USER',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Info Section
                      _buildSectionHeader('Account Information', Icons.person),
                      const SizedBox(height: 12),
                      Container(
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
                            _buildProfileField(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user?.email ?? '',
                              isEditable: false,
                            ),
                            const Divider(height: 1),
                            _buildEditableField(
                              icon: Icons.person_outline,
                              label: 'Full Name',
                              controller: _nameController,
                              isEditing: _isEditing,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contact Info Section
                      _buildSectionHeader('Contact Details', Icons.phone),
                      const SizedBox(height: 12),
                      Container(
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
                            _buildEditableField(
                              icon: Icons.phone_outlined,
                              label: 'Phone Number',
                              controller: _phoneController,
                              isEditing: _isEditing,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const Divider(height: 1),
                            _buildEditableField(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              controller: _addressController,
                              isEditing: _isEditing,
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your address';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Stats Section (Only for Users)
                      if (user?.role == 'user') ...[
                        _buildSectionHeader('Activity Stats', Icons.analytics),
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
                                child: _buildStatItem(
                                  icon: Icons.delete_sweep,
                                  label: 'Total Pickups',
                                  value: '$_totalPickups',
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 60,
                                color: Colors.grey[200],
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.eco,
                                  label: 'CO₂ Saved',
                                  value: '${_co2Saved.toStringAsFixed(0)}kg',
                                  color: AppTheme.organicColor,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 60,
                                color: Colors.grey[200],
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.star,
                                  label: 'Eco Score',
                                  value: '$_ecoScore',
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Rewards Section
                        _buildSectionHeader('Eco Rewards', Icons.card_giftcard),
                        const SizedBox(height: 12),
                        _buildRewardsSection(),

                        const SizedBox(height: 24),
                      ],
                      const SizedBox(height: 24),

                      // Member Since
                      Center(
                        child: Text(
                          'Member since ${_formatDate(user?.createdAt ?? DateTime.now())}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button (only when editing)
                      if (_isEditing)
                        GradientButton(
                          text: 'Save Changes',
                          icon: Icons.save,
                          onPressed: _isLoading ? null : _saveProfile,
                          isLoading: _isLoading,
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

  Widget _buildSectionHeader(String title, IconData icon) {
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

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
    bool isEditable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isEditable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Verified',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Enter $label',
                    ),
                    validator: validator,
                  )
                else
                  Text(
                    controller.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          if (isEditing)
            Icon(Icons.edit, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildStatItem({
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isDark ? Colors.white : Colors.grey[600], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildRewardsSection() {
    // Define reward tiers (adjusted for 10 pts per pickup)
    final List<Map<String, dynamic>> rewards = [
      {
        'points': 20,
        'title': 'Eco Starter',
        'reward': '₹25 Grocery Voucher',
        'description': 'Redeem at local grocery stores',
        'icon': Icons.shopping_basket,
        'color': const Color(0xFF10B981),
        'gradient': [const Color(0xFF10B981), const Color(0xFF34D399)],
      },
      {
        'points': 50,
        'title': 'Green Champion',
        'reward': '₹75 Shopping Coupon',
        'description': 'Valid at partner retail stores',
        'icon': Icons.shopping_bag,
        'color': const Color(0xFF3B82F6),
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
      },
      {
        'points': 100,
        'title': 'Eco Warrior',
        'reward': '₹150 Home Essentials Kit',
        'description': 'Eco-friendly home products',
        'icon': Icons.home,
        'color': const Color(0xFF8B5CF6),
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
      },
      {
        'points': 200,
        'title': 'Earth Guardian',
        'reward': '₹300 + Free Month Service',
        'description': 'Premium rewards package',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFF59E0B),
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      },
    ];

    // Find current tier and next tier
    int currentTierIndex = -1;
    for (int i = rewards.length - 1; i >= 0; i--) {
      if (_ecoScore >= rewards[i]['points']) {
        currentTierIndex = i;
        break;
      }
    }
    
    final nextTierIndex = currentTierIndex + 1;
    final hasNextTier = nextTierIndex < rewards.length;
    final nextTierPoints = hasNextTier ? rewards[nextTierIndex]['points'] : 0;
    final progressToNext = hasNextTier 
        ? (_ecoScore / nextTierPoints).clamp(0.0, 1.0)
        : 1.0;

    return Column(
      children: [
        // Progress to Next Reward Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasNextTier 
                  ? (rewards[nextTierIndex]['gradient'] as List<Color>)
                  : [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (hasNextTier ? rewards[nextTierIndex]['color'] : Colors.amber).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      hasNextTier ? rewards[nextTierIndex]['icon'] : Icons.emoji_events,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasNextTier ? 'Next Reward' : '🎉 All Rewards Unlocked!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasNextTier 
                              ? rewards[nextTierIndex]['reward']
                              : 'You are an Earth Guardian!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_ecoScore pts',
                      style: TextStyle(
                        color: hasNextTier ? rewards[nextTierIndex]['color'] : Colors.amber[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              if (hasNextTier) ...[
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${nextTierPoints - _ecoScore} points to unlock',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$nextTierPoints pts',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressToNext,
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Reward Tiers List
        Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
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
                children: rewards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reward = entry.value;
                  final isUnlocked = _ecoScore >= reward['points'];
                  final isLast = index == rewards.length - 1;
                  
                  return Column(
                    children: [
                      InkWell(
                        onTap: isUnlocked ? () => _showRewardDialog(reward) : null,
                        borderRadius: BorderRadius.circular(index == 0 ? 20 : 0),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: isUnlocked 
                                      ? LinearGradient(colors: reward['gradient'])
                                      : null,
                                  color: isUnlocked ? null : (isDark ? Colors.grey[800] : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  reward['icon'],
                                  color: isUnlocked ? Colors.white : Colors.grey[400],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          reward['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: isUnlocked 
                                                ? (isDark ? Colors.white : Colors.black87) 
                                                : Colors.grey[500],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isUnlocked 
                                                ? (isDark ? Colors.green[900] : Colors.green[50])
                                                : (isDark ? Colors.grey[800] : Colors.grey[100]),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${reward['points']} pts',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isUnlocked ? Colors.green[400] : Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reward['reward'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isUnlocked ? reward['color'] : Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      reward['description'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isUnlocked)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.green[900] : Colors.green[50],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.green[400],
                                    size: 18,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.lock_outline,
                                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) Divider(height: 1, color: Theme.of(context).dividerColor),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // How to earn points tip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to earn points?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.amber[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Earn 10 points per pickup + bonus 5 points for every 5 pickups!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.palette, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 12),
            const Text('Choose Theme'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context: context,
              themeProvider: themeProvider,
              mode: ThemeMode.light,
              icon: Icons.light_mode,
              label: 'Light Mode',
              description: 'Bright and clear',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context: context,
              themeProvider: themeProvider,
              mode: ThemeMode.dark,
              icon: Icons.dark_mode,
              label: 'Dark Mode',
              description: 'Easy on the eyes',
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              context: context,
              themeProvider: themeProvider,
              mode: ThemeMode.system,
              icon: Icons.brightness_auto,
              label: 'System Default',
              description: 'Match device settings',
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
  }) {
    final isSelected = themeProvider.themeMode == mode;
    
    return InkWell(
      onTap: () {
        themeProvider.setThemeMode(mode);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('$label activated'),
              ],
            ),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  void _showRewardDialog(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: reward['gradient']),
                shape: BoxShape.circle,
              ),
              child: Icon(reward['icon'], color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              '🎉 Reward Unlocked!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: reward['color'],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reward['title'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: reward['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reward['reward'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: reward['color'],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reward['description'],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final user = Provider.of<UserProvider>(context, listen: false).user;
                  if (user == null) return;

                  Navigator.pop(context);
                  
                  try {
                    await _rewardService.createRequest(RewardRequest(
                      id: '', // Firestore will generate ID
                      userId: user.uid,
                      userName: user.name,
                      rewardTitle: reward['title'],
                      rewardPoints: reward['points'],
                      status: 'pending',
                      createdAt: DateTime.now(),
                    ));

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.celebration, color: Colors.white),
                              const SizedBox(width: 12),
                              Text('Redeem request sent for ${reward['reward']}'),
                            ],
                          ),
                          backgroundColor: reward['color'],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to send request')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: reward['color'],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Redeem Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

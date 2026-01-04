import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'about_screen.dart';
import 'help_support_screen.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  // Helper to build profile image from Base64 or URL
  Widget _buildProfileImage(String imageData, String name) {
    try {
      if (imageData.startsWith('data:image')) {
        final base64String = imageData.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: 56,
          height: 56,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        return Image.network(
          imageData,
          fit: BoxFit.cover,
          width: 56,
          height: 56,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      return Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.logout, color: Colors.red[400], size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
          style: TextStyle(color: Colors.grey, height: 1.5),
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Logout'),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                Icons.settings,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Settings',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Manage your preferences',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
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
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildSectionHeader('Account', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildProfileTile(user),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.edit_outlined,
                      iconColor: Colors.blue,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Preferences Section
                  _buildSectionHeader('Preferences', Icons.tune),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: Colors.purple,
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark theme',
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      icon: Icons.notifications_outlined,
                      iconColor: Colors.orange,
                      title: 'Notifications',
                      subtitle: 'Receive pickup reminders and updates',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.green,
                      title: 'Location Services',
                      subtitle: 'Allow app to access your location',
                      value: _locationEnabled,
                      onChanged: (value) {
                        setState(() => _locationEnabled = value);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Support Section
                  _buildSectionHeader('Support', Icons.help_outline),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.help_center_outlined,
                      iconColor: Colors.teal,
                      title: 'Help & Support',
                      subtitle: 'FAQs and customer support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      iconColor: Colors.blue,
                      title: 'About',
                      subtitle: 'App version and information',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: Colors.indigo,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () {
                        // TODO: Open privacy policy
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      iconColor: Colors.amber[700]!,
                      title: 'Terms of Service',
                      subtitle: 'Read our terms and conditions',
                      onTap: () {
                        // TODO: Open terms of service
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Logout Section
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.logout,
                      iconColor: Colors.red,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      titleColor: Colors.red,
                      showArrow: false,
                      onTap: _logout,
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // App Version
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: AppTheme.primaryGreen,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Eco Waste',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🌍 Making the planet cleaner, one pickup at a time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
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
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile(dynamic user) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: user?.profileImageUrl != null
            ? ClipOval(
                child: _buildProfileImage(user!.profileImageUrl!, user.name),
              )
            : Center(
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
      title: Text(
        user?.name ?? 'User',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user?.role.toUpperCase() ?? 'USER',
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: titleColor ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
          fontSize: 13,
        ),
      ),
      trailing: showArrow
          ? Icon(Icons.chevron_right, color: Colors.grey[400])
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[500],
          fontSize: 13,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }
}

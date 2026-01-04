import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 250,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // App Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.eco,
                            size: 50,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Smart Waste Collection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  _buildSectionHeader('About', Icons.info_outline, isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Smart Waste Collection is a comprehensive waste management solution that connects users with waste collectors for efficient and eco-friendly waste disposal. Our mission is to create a cleaner, greener environment through smart technology and community engagement.\n\nThe app enables users to schedule waste pickups, track collection status, and contribute to sustainable waste management practices.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: isDark ? Colors.white : const Color(0xFF2D3436),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Features Section
                  _buildSectionHeader('Features', Icons.star_outline, isDark),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildFeatureItem(
                          icon: Icons.calendar_month,
                          title: 'Easy Scheduling',
                          description: 'Schedule waste pickups at your convenience',
                          color: AppTheme.accentBlue,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        _buildFeatureItem(
                          icon: Icons.track_changes,
                          title: 'Real-time Tracking',
                          description: 'Track your pickup status in real-time',
                          color: AppTheme.accentPurple,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        _buildFeatureItem(
                          icon: Icons.recycling,
                          title: 'Multiple Waste Types',
                          description: 'Support for organic, recyclable, e-waste & more',
                          color: AppTheme.recyclableColor,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        _buildFeatureItem(
                          icon: Icons.notifications_active,
                          title: 'Smart Notifications',
                          description: 'Get notified about pickup updates',
                          color: AppTheme.accentOrange,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Developer Section
                  _buildSectionHeader('Developers', Icons.code, isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDeveloperCard(
                          name: 'Raja Swamy S',
                          role: 'Lead Developer',
                          avatar: 'R',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tech Stack Section
                  _buildSectionHeader('Technology', Icons.devices, isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildTechChip('Flutter', Colors.blue),
                        _buildTechChip('Firebase', Colors.orange),
                        _buildTechChip('Firestore', Colors.amber),
                        _buildTechChip('Dart', Colors.teal),
                        _buildTechChip('Google Maps', Colors.green),
                        _buildTechChip('Provider', Colors.purple),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Section
                  _buildSectionHeader('Contact Us', Icons.email_outlined, isDark),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildContactItem(
                          icon: Icons.email,
                          label: 'Email',
                          value: 'support@smartwaste.com',
                          color: Colors.red,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        _buildContactItem(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: '+91 8148155850',
                          color: AppTheme.primaryGreen,
                          isDark: isDark,
                        ),
                        Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        _buildContactItem(
                          icon: Icons.language,
                          label: 'Website',
                          value: 'www.smartwaste.com',
                          color: AppTheme.accentBlue,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Admin Access Info
                  _buildSectionHeader('Admin Access', Icons.admin_panel_settings, isDark),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.amber[900]!.withOpacity(0.3) : Colors.amber[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.amber[700]! : Colors.amber[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[700]),
                            const SizedBox(width: 8),
                            Text(
                              'How to Access Admin Panel',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.amber[300] : Colors.amber[900],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1. Register with an admin email in Firebase Console\n'
                          '2. Set user role to "admin" in Firestore users collection\n'
                          '3. Login with admin credentials\n'
                          '4. You will be automatically redirected to Admin Panel',
                          style: TextStyle(
                            color: isDark ? Colors.amber[200] : Colors.amber[900],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Admin Credentials (Demo):\n'
                          'Email: admin@smartwaste.com\n'
                          'Role: admin (set in Firestore)',
                          style: TextStyle(
                            color: isDark ? Colors.amber[300] : Colors.amber[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© 2025 Smart Waste Collection',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Made with ❤️ for a greener planet',
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required String avatar,
    required bool isDark,
  }) {
    return Row(
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
              avatar,
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
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildSocialIcon(Icons.code, Colors.grey),
            const SizedBox(width: 8),
            _buildSocialIcon(Icons.link, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildTechChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

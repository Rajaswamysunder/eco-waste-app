import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'chatbot_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Help & Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'We\'re here to help you',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
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
                  // Quick Contact
                  _buildSectionTitle('Quick Contact', isDark),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.phone,
                    title: 'Call Us',
                    subtitle: '+91 8148155805',
                    color: Colors.green,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@smartwaste.com',
                    color: Colors.blue,
                    onTap: () {},
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.chat,
                    title: 'Live Chat',
                    subtitle: 'Chat with our support team',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                      );
                    },
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Frequently Asked Questions', isDark),
                  const SizedBox(height: 12),
                  
                  _buildFAQItem(
                    question: 'How do I schedule a pickup?',
                    answer: 'Tap the "+ New Pickup" button on the home screen. Select your waste type, quantity, preferred date and time, then confirm your request. A collector will be assigned to your pickup.',
                    isDark: isDark,
                    context: context,
                  ),
                  _buildFAQItem(
                    question: 'What types of waste do you collect?',
                    answer: '• Organic Waste: Food scraps, garden waste\n• Recyclable: Paper, plastic, glass, metal\n• E-Waste: Electronics, batteries, cables\n• Hazardous: Chemicals, paints, medical waste\n• General: Mixed non-recyclable waste',
                    isDark: isDark,
                    context: context,
                  ),
                  _buildFAQItem(
                    question: 'How do I track my pickup?',
                    answer: 'Go to "Your Pickups" section on the home screen. You can see the status of all your requests. Tap on any pickup to view details including collector info and estimated arrival.',
                    isDark: isDark,
                    context: context,
                  ),
                  _buildFAQItem(
                    question: 'Can I cancel a pickup request?',
                    answer: 'Yes, you can cancel a pending pickup. Go to the pickup details and tap "Cancel Pickup". Note: Once a collector is assigned, please contact support for cancellation.',
                    isDark: isDark,
                    context: context,
                  ),
                  _buildFAQItem(
                    question: 'What are the pickup time slots?',
                    answer: '• Morning: 6:00 AM - 12:00 PM\n• Afternoon: 12:00 PM - 5:00 PM\n• Evening: 5:00 PM - 8:00 PM\n\nChoose the slot that works best for you!',
                    isDark: isDark,
                    context: context,
                  ),
                  _buildFAQItem(
                    question: 'How is my waste recycled?',
                    answer: 'Each type of waste goes through a specific recycling process:\n\n• Organic → Composting → Fertilizer\n• Recyclable → Sorted → Processed → New Products\n• E-Waste → Dismantled → Metals Recovered\n• Hazardous → Safe Disposal → Treatment',
                    isDark: isDark,
                    context: context,
                  ),
                  _buildFAQItem(
                    question: 'What is Eco Score?',
                    answer: 'Eco Score represents your environmental impact. You earn 25 points for each successful pickup + bonus 10 points for every 5 pickups!\n\n🎁 Eco Rewards:\n• 100 pts → ₹50 Grocery Voucher\n• 250 pts → ₹150 Shopping Coupon\n• 500 pts → ₹300 Home Essentials Kit\n• 1000 pts → ₹500 + Free Month Service',
                    isDark: isDark,
                    context: context,
                  ),
                  _buildFAQItem(
                    question: 'How do I redeem rewards?',
                    answer: 'Go to your Profile → Eco Rewards section. Tap on any unlocked reward to redeem it. You\'ll receive a confirmation and the reward will be processed within 3-5 business days.',
                    isDark: isDark,
                    context: context,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Troubleshooting', isDark),
                  const SizedBox(height: 12),
                  
                  _buildTroubleshootItem(
                    icon: Icons.location_off,
                    title: 'Location not detected',
                    solution: 'Enable location services in your device settings and grant permission to the app.',
                    isDark: isDark,
                  ),
                  _buildTroubleshootItem(
                    icon: Icons.notifications_off,
                    title: 'Not receiving notifications',
                    solution: 'Check notification settings in your profile and ensure notifications are enabled in device settings.',
                    isDark: isDark,
                  ),
                  _buildTroubleshootItem(
                    icon: Icons.sync_problem,
                    title: 'Pickup not updating',
                    solution: 'Pull down to refresh the screen. If the issue persists, check your internet connection.',
                    isDark: isDark,
                  ),
                  _buildTroubleshootItem(
                    icon: Icons.person_off,
                    title: 'Collector not assigned',
                    solution: 'Collectors are assigned based on availability. You\'ll be notified once assigned. Contact support if delayed beyond 24 hours.',
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('App Guide', isDark),
                  const SizedBox(height: 12),
                  
                  _buildGuideStep(
                    step: '1',
                    title: 'Create Account',
                    description: 'Sign up with your email and phone number to get started.',
                    icon: Icons.person_add,
                    isDark: isDark,
                  ),
                  _buildGuideStep(
                    step: '2',
                    title: 'Request Pickup',
                    description: 'Select waste type, quantity, and schedule a convenient time.',
                    icon: Icons.add_circle,
                    isDark: isDark,
                  ),
                  _buildGuideStep(
                    step: '3',
                    title: 'Collector Assigned',
                    description: 'A nearby collector will be assigned to your request.',
                    icon: Icons.local_shipping,
                    isDark: isDark,
                  ),
                  _buildGuideStep(
                    step: '4',
                    title: 'Waste Collected',
                    description: 'Collector picks up your waste at the scheduled time.',
                    icon: Icons.check_circle,
                    isDark: isDark,
                  ),
                  _buildGuideStep(
                    step: '5',
                    title: 'Recycled & Processed',
                    description: 'Your waste is responsibly recycled or disposed.',
                    icon: Icons.recycling,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),
                  // Feedback Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.feedback, color: Colors.white, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Have Feedback?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'d love to hear from you! Your feedback helps us improve.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showFeedbackDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('Send Feedback'),
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF2D3436),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
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
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required bool isDark,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.help_outline, color: AppTheme.primaryGreen),
          ),
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          iconColor: isDark ? Colors.white70 : Colors.black54,
          collapsedIconColor: isDark ? Colors.white70 : Colors.black54,
          children: [
            Text(
              answer,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootItem({
    required IconData icon,
    required String title,
    required String solution,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(isDark ? 0.5 : 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  solution,
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

  Widget _buildGuideStep({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryGreen, Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.feedback, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 12),
                const Text('Send Feedback'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How was your experience?'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() => selectedRating = index + 1);
                        },
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tell us more about your experience...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for your feedback!'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }
}

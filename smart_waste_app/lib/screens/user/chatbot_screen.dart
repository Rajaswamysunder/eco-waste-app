import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Send welcome message
    _addBotMessage(
      "Hello! 👋 I'm EcoBot, your Smart Waste Collection assistant.\n\n"
      "I can help you with:\n"
      "• Scheduling pickups\n"
      "• Tracking your requests\n"
      "• Eco Points & rewards\n"
      "• Waste types & recycling\n"
      "• Account issues\n\n"
      "How can I help you today?",
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getBotResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();

    // Greetings
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return "Hello! 😊 How can I assist you today?";
    }

    // Pickup scheduling
    if (message.contains('schedule') || message.contains('book') || message.contains('new pickup')) {
      return "To schedule a new pickup:\n\n"
          "1️⃣ Go to Home screen\n"
          "2️⃣ Tap the '+ New Pickup' button\n"
          "3️⃣ Select your waste type\n"
          "4️⃣ Choose quantity and time slot\n"
          "5️⃣ Confirm your address\n"
          "6️⃣ Submit your request!\n\n"
          "A collector will be assigned within 24 hours. 🚛";
    }

    // Track pickup
    if (message.contains('track') || message.contains('status') || message.contains('where is')) {
      return "To track your pickup:\n\n"
          "1️⃣ Go to Home screen\n"
          "2️⃣ Check 'Your Pickups' section\n"
          "3️⃣ Tap on any pickup to see details\n\n"
          "Status meanings:\n"
          "• 🟡 Pending - Waiting for collector\n"
          "• 🔵 Assigned - Collector assigned\n"
          "• 🟣 Confirmed - Collector confirmed\n"
          "• 🟠 In Progress - Collector on the way\n"
          "• 🟢 Completed - Pickup done!";
    }

    // Cancel pickup
    if (message.contains('cancel')) {
      return "To cancel a pickup:\n\n"
          "1️⃣ Go to your pickup details\n"
          "2️⃣ Tap 'Cancel Pickup' button\n\n"
          "⚠️ Note: You can only cancel pending pickups. "
          "If a collector is already assigned, please contact support for assistance.";
    }

    // Eco points / rewards
    if (message.contains('eco') || message.contains('point') || message.contains('reward') || message.contains('score')) {
      return "🌱 About Eco Points:\n\n"
          "You earn points for every pickup:\n"
          "• +25 points per completed pickup\n"
          "• +10 bonus every 5 pickups\n\n"
          "🎁 Redeem Rewards:\n"
          "• 100 pts → ₹50 Grocery Voucher\n"
          "• 250 pts → ₹150 Shopping Coupon\n"
          "• 500 pts → ₹300 Home Essentials\n"
          "• 1000 pts → ₹500 + Free Month!\n\n"
          "Check your points in Profile section.";
    }

    // Waste types
    if (message.contains('waste type') || message.contains('what type') || message.contains('category') || message.contains('recycle')) {
      return "♻️ We collect these waste types:\n\n"
          "🥬 Organic - Food scraps, garden waste\n"
          "📦 Recyclable - Paper, plastic, glass, metal\n"
          "📱 E-Waste - Electronics, batteries, cables\n"
          "☢️ Hazardous - Chemicals, paints, medical\n"
          "🗑️ General - Mixed non-recyclable waste\n\n"
          "Separate your waste for better recycling! 🌍";
    }

    // Time slots
    if (message.contains('time') || message.contains('slot') || message.contains('when')) {
      return "⏰ Available Pickup Time Slots:\n\n"
          "🌅 Morning: 6:00 AM - 12:00 PM\n"
          "☀️ Afternoon: 12:00 PM - 5:00 PM\n"
          "🌆 Evening: 5:00 PM - 8:00 PM\n\n"
          "Choose the slot that works best for you when scheduling!";
    }

    // Collector
    if (message.contains('collector') || message.contains('driver')) {
      return "About Collectors:\n\n"
          "🚛 Collectors are verified professionals\n"
          "📞 You can call them from pickup details\n"
          "⭐ Rate them after pickup completion\n\n"
          "Collectors are assigned based on location and availability.";
    }

    // Payment / pricing
    if (message.contains('pay') || message.contains('price') || message.contains('cost') || message.contains('fee') || message.contains('charge')) {
      return "💰 Pricing Information:\n\n"
          "Our service is currently FREE for all users!\n\n"
          "We're committed to making waste collection accessible to everyone. "
          "In the future, premium features may be available.";
    }

    // Account / profile
    if (message.contains('account') || message.contains('profile') || message.contains('password') || message.contains('email')) {
      return "👤 Account Settings:\n\n"
          "To manage your account:\n"
          "1️⃣ Go to Profile tab\n"
          "2️⃣ Tap Settings (gear icon)\n\n"
          "You can:\n"
          "• Update profile photo\n"
          "• Enable/disable dark mode\n"
          "• Manage notifications\n"
          "• Logout from your account";
    }

    // Notifications
    if (message.contains('notification') || message.contains('alert')) {
      return "🔔 Notifications:\n\n"
          "You'll receive notifications for:\n"
          "• Collector assigned to your pickup\n"
          "• Pickup status updates\n"
          "• Eco Points earned\n"
          "• Special offers & rewards\n\n"
          "Manage notifications in Settings.";
    }

    // Contact / support
    if (message.contains('contact') || message.contains('support') || message.contains('help') || message.contains('phone') || message.contains('call')) {
      return "📞 Contact Support:\n\n"
          "Phone: +91 8148155805\n"
          "Email: support@smartwaste.com\n\n"
          "Our support team is available:\n"
          "Mon-Sat: 9 AM - 6 PM\n\n"
          "For urgent issues, please call us directly!";
    }

    // Problem / issue / complaint
    if (message.contains('problem') || message.contains('issue') || message.contains('complaint') || message.contains('not working')) {
      return "😟 Sorry to hear you're having issues!\n\n"
          "Common troubleshooting:\n"
          "• Refresh the app\n"
          "• Check internet connection\n"
          "• Update to latest version\n"
          "• Clear app cache\n\n"
          "If problem persists, please contact:\n"
          "📞 +91 8148155805\n"
          "📧 support@smartwaste.com";
    }

    // Thanks
    if (message.contains('thank') || message.contains('thanks')) {
      return "You're welcome! 😊\n\nIs there anything else I can help you with?";
    }

    // Bye
    if (message.contains('bye') || message.contains('goodbye')) {
      return "Goodbye! 👋\n\nThank you for using Smart Waste Collection. "
          "Together, let's make our planet greener! 🌍💚";
    }

    // Default response
    return "I'm not sure I understand. 🤔\n\n"
        "Try asking about:\n"
        "• How to schedule a pickup\n"
        "• Track my pickup status\n"
        "• Eco points and rewards\n"
        "• Waste types we collect\n"
        "• Contact support\n\n"
        "Or type 'help' for more options!";
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Simulate bot typing delay
    Future.delayed(const Duration(milliseconds: 800), () {
      final response = _getBotResponse(text);
      setState(() {
        _isTyping = false;
      });
      _addBotMessage(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EcoBot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(isDark);
                }
                return _buildMessageBubble(_messages[index], isDark);
              },
            ),
          ),

          // Quick replies
          if (_messages.length <= 2)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickReply('Schedule pickup', isDark),
                  _buildQuickReply('Track my order', isDark),
                  _buildQuickReply('Eco points', isDark),
                  _buildQuickReply('Contact support', isDark),
                ],
              ),
            ),

          // Input field
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryGreen
                    : (isDark ? const Color(0xFF2D2D2D) : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3 + (0.4 * value)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildQuickReply(String text, bool isDark) {
    return GestureDetector(
      onTap: () {
        _messageController.text = text;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

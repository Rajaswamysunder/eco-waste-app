import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/ml/tflite_classifier_service.dart';
import '../../services/ml/chatbot_service.dart';
import '../../services/ml/predictive_analytics_service.dart';
import '../../services/ml/multi_object_detection_service.dart';
import '../../services/ml/bin_fill_detector_service.dart';
import '../../services/ml/decomposition_predictor_service.dart';
import '../../services/ml/carbon_footprint_service.dart';

/// AI Features Dashboard - Premium UI
/// Showcases all 4 custom AI/ML implementations with modern design
class AIDashboardScreen extends StatefulWidget {
  const AIDashboardScreen({super.key});

  @override
  State<AIDashboardScreen> createState() => _AIDashboardScreenState();
}

class _AIDashboardScreenState extends State<AIDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  
  final List<_AIFeature> _features = [
    _AIFeature(
      title: 'Classifier',
      subtitle: 'Image Analysis',
      icon: Icons.auto_awesome,
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    _AIFeature(
      title: 'Chatbot',
      subtitle: 'NLP Assistant',
      icon: Icons.psychology,
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
    ),
    _AIFeature(
      title: 'Analytics',
      subtitle: 'Predictions',
      icon: Icons.insights,
      gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
    ),
    _AIFeature(
      title: 'Detection',
      subtitle: 'Multi-Object',
      icon: Icons.center_focus_strong,
      gradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
    ),
    _AIFeature(
      title: 'Bin Fill',
      subtitle: 'Fill Detection',
      icon: Icons.delete_outline,
      gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    ),
    _AIFeature(
      title: 'Eco Impact',
      subtitle: 'Decomposition',
      icon: Icons.eco,
      gradient: [Color(0xFF84CC16), Color(0xFF65A30D)],
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    await TFLiteClassifierService.initialize();
    await MultiObjectDetectionService.initialize();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                : [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 20, 8),
                child: Row(
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _features[_selectedIndex].gradient,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _features[_selectedIndex].gradient[0].withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Features',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            '4 Custom ML Implementations',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _GlassIconButton(
                      icon: Icons.info_outline,
                      onTap: () => _showInfoDialog(context),
                    ),
                  ],
                ),
              ),
              
              // Feature Cards Row
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _features.length,
                  itemBuilder: (context, index) {
                    final feature = _features[index];
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _tabController.animateTo(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: isSelected ? 140 : 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(colors: feature.gradient)
                              : null,
                          color: isSelected
                              ? null
                              : (isDark ? Colors.white.withOpacity(0.08) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: feature.gradient[0].withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: Offset(0, 6),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                feature.icon,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : feature.gradient[0]),
                                size: 24,
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        feature.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        feature.subtitle,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _ClassifierTab(),
                    _ChatbotTab(),
                    _AnalyticsTab(),
                    _DetectionTab(),
                    _BinFillTab(),
                    _EcoImpactTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('AI Features'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoItem(icon: Icons.auto_awesome, color: Color(0xFF6366F1), 
                     title: 'Classifier', desc: 'HSV color + texture analysis'),
            _InfoItem(icon: Icons.psychology, color: Color(0xFF10B981),
                     title: 'Chatbot', desc: 'Pattern-based NLP engine'),
            _InfoItem(icon: Icons.insights, color: Color(0xFFF59E0B),
                     title: 'Analytics', desc: 'Real Firestore predictions'),
            _InfoItem(icon: Icons.center_focus_strong, color: Color(0xFFEF4444),
                     title: 'Detection', desc: 'Grid-based object detection'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _AIFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  
  _AIFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  
  const _GlassIconButton({required this.icon, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  
  const _InfoItem({required this.icon, required this.color, required this.title, required this.desc});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab 1: TFLite Waste Classifier - Premium UI
class _ClassifierTab extends StatefulWidget {
  const _ClassifierTab();

  @override
  State<_ClassifierTab> createState() => _ClassifierTabState();
}

class _ClassifierTabState extends State<_ClassifierTab> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  ClassificationResult? _result;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 70,
      );
      
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _result = null;
          _isProcessing = true;
        });
        
        final result = await TFLiteClassifierService.classifyImage(picked.path);
        
        setState(() {
          _result = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Section with Image
          _GlassCard(
            gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            child: Column(
              children: [
                if (_selectedImage != null)
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_isProcessing)
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Analyzing...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF6366F1).withOpacity(0.3),
                          Color(0xFF8B5CF6).withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 48,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Select an image to classify',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 16),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _GradientButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        gradient: [Colors.white, Colors.white],
                        textColor: Color(0xFF6366F1),
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _OutlineButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Results Section
          if (_result != null) ...[
            // Main Result Card
            _ResultCard(result: _result!),
            
            SizedBox(height: 16),
            
            // All Predictions
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.bar_chart_rounded, color: Color(0xFF6366F1), size: 20),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'All Predictions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...(_result!.allPredictions.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value)))
                    .map((entry) => _AnimatedProgressBar(
                      label: entry.key,
                      value: entry.value,
                      color: _getColorForLabel(entry.key),
                    )),
                ],
              ),
            ),
            
            // Analysis Details
            if (_result!.analysisDetails.isNotEmpty) ...[
              SizedBox(height: 16),
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.analytics_outlined, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Analysis Details', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _result!.analysisDetails,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _getColorForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'organic': return Color(0xFF10B981);
      case 'recyclable': return Color(0xFF3B82F6);
      case 'hazardous': return Color(0xFFEF4444);
      case 'e-waste': return Color(0xFF8B5CF6);
      default: return Color(0xFF6B7280);
    }
  }
}

class _ResultCard extends StatelessWidget {
  final ClassificationResult result;
  
  const _ResultCard({required this.result});
  
  @override
  Widget build(BuildContext context) {
    final isHuman = result.isHumanDetected;
    final color = isHuman ? Colors.orange : _getColorForLabel(result.label);
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHuman ? Icons.person : _getIconForLabel(result.label),
              color: color,
              size: 36,
            ),
          ),
          SizedBox(height: 16),
          Text(
            result.label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ConfidenceBadge(
                label: result.confidencePercent,
                color: color,
              ),
              SizedBox(width: 8),
              _ConfidenceBadge(
                label: result.confidenceLevel,
                color: result.isHighConfidence 
                    ? Colors.green 
                    : result.isMediumConfidence 
                        ? Colors.orange 
                        : Colors.red,
                isOutline: true,
              ),
            ],
          ),
          if (isHuman) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Human detected - not waste',
                    style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Color _getColorForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'organic': return Color(0xFF10B981);
      case 'recyclable': return Color(0xFF3B82F6);
      case 'hazardous': return Color(0xFFEF4444);
      case 'e-waste': return Color(0xFF8B5CF6);
      default: return Color(0xFF6B7280);
    }
  }
  
  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'organic': return Icons.eco;
      case 'recyclable': return Icons.recycling;
      case 'hazardous': return Icons.warning_amber;
      case 'e-waste': return Icons.devices;
      default: return Icons.delete_outline;
    }
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isOutline;
  
  const _ConfidenceBadge({required this.label, required this.color, this.isOutline = false});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: isOutline ? Border.all(color: color) : null,
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
}

class _AnimatedProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  
  const _AnimatedProgressBar({required this.label, required this.value, required this.color});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              Text(
                '${(value * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 2: Custom Chatbot - Premium UI
class _ChatbotTab extends StatefulWidget {
  const _ChatbotTab();

  @override
  State<_ChatbotTab> createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<_ChatbotTab> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hello! 👋 I'm your Eco Waste AI Assistant. Ask me anything about waste management, recycling, or disposal!",
    );
  }

  void _addBotMessage(String message) {
    _messages.add(ChatMessage(
      text: message,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Simulate typing delay
    await Future.delayed(Duration(milliseconds: 600));

    final response = WasteChatbotService.processMessage(text);

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: response.message,
        isUser: false,
        timestamp: DateTime.now(),
        intent: response.intent,
        confidence: response.confidence,
        suggestedActions: response.suggestedActions,
      ));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Chat Header
        Container(
          margin: EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eco Waste AI',
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
                          decoration: BoxDecoration(
                            color: Colors.lightGreenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Online • On-device NLP',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping && index == _messages.length) {
                return _TypingIndicator();
              }
              final message = _messages[index];
              return _ModernChatBubble(message: message);
            },
          ),
        ),

        // Quick Replies
        if (_messages.isNotEmpty && !_messages.last.isUser && !_isTyping)
          Container(
            height: 44,
            margin: EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: WasteChatbotService.getQuickReplies().map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: isDark ? Colors.white12 : Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _controller.text = reply;
                        _sendMessage();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Text(
                          reply,
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E1E2E) : Colors.white,
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
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about waste management...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withOpacity(0.4),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: _sendMessage,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: Radius.zero),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = (_controller.value + index * 0.2) % 1.0;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.3 + value * 0.7),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _ModernChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ModernChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                    : null,
                color: message.isUser
                    ? null
                    : (isDark ? Colors.white12 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: message.isUser ? Radius.zero : null,
                  bottomLeft: !message.isUser ? Radius.zero : null,
                ),
                boxShadow: message.isUser
                    ? [
                        BoxShadow(
                          color: Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            if (!message.isUser && message.intent != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.intent!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${((message.confidence ?? 0) * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;
  final double? confidence;
  final List<String>? suggestedActions;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.confidence,
    this.suggestedActions,
  });
}

/// Tab 3: Predictive Analytics - Premium UI
class _AnalyticsTab extends StatefulWidget {
  const _AnalyticsTab();

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  WasteSummary? _summary;
  List<WastePrediction>? _predictions;
  List<WasteInsight>? _insights;
  List<ChartDataPoint>? _chartData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      final results = await Future.wait([
        PredictiveAnalyticsService.getSummary(days: 30, userId: userId),
        PredictiveAnalyticsService.forecastWaste(daysAhead: 7, userId: userId),
        PredictiveAnalyticsService.generateInsights(userId: userId),
        PredictiveAnalyticsService.getChartData(days: 14, userId: userId),
      ]);
      
      if (mounted) {
        setState(() {
          _summary = results[0] as WasteSummary;
          _predictions = results[1] as List<WastePrediction>;
          _insights = results[2] as List<WasteInsight>;
          _chartData = results[3] as List<ChartDataPoint>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFF59E0B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Loading analytics...',
              style: TextStyle(
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Fetching data from Firestore',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }
    
    if (_error != null) {
      return Center(
        child: _GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading data', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 16),
              _GradientButton(
                icon: Icons.refresh,
                label: 'Retry',
                gradient: [Color(0xFFF59E0B), Color(0xFFD97706)],
                onTap: _loadData,
              ),
            ],
          ),
        ),
      );
    }
    
    final summary = _summary!;
    final predictions = _predictions!;
    final insights = _insights!;
    final chartData = _chartData!;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Color(0xFFF59E0B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF59E0B).withOpacity(0.3),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.insights, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Predictive Analytics',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              summary.hasData 
                                  ? '${summary.totalPickups} pickups analyzed'
                                  : 'No data yet',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _ModernStatCard(
                    title: 'Total Waste',
                    value: '${summary.totalKg}',
                    unit: 'kg',
                    icon: Icons.delete_outline,
                    gradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ModernStatCard(
                    title: 'Recycling',
                    value: '${summary.recyclingRate.toStringAsFixed(0)}',
                    unit: '%',
                    icon: Icons.recycling,
                    gradient: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ModernStatCard(
                    title: 'Daily Avg',
                    value: '${summary.avgKg}',
                    unit: 'kg',
                    icon: Icons.trending_up,
                    gradient: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _ModernStatCard(
                    title: 'Pickups',
                    value: '${summary.totalPickups}',
                    unit: '',
                    icon: Icons.local_shipping,
                    gradient: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Chart
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF59E0B).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.show_chart, color: Color(0xFFF59E0B), size: 20),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Waste Trend',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Spacer(),
                      Text('14 days', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (chartData.isNotEmpty)
                    SizedBox(
                      height: 180,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: isDark ? Colors.white10 : Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: AxisTitles(),
                            topTitles: AxisTitles(),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) => Text(
                                  '${value.toInt()}',
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: chartData.asMap().entries.map((e) {
                                return FlSpot(e.key.toDouble(), e.value.total / 1000);
                              }).toList(),
                              isCurved: true,
                              gradient: LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFF59E0B).withOpacity(0.3),
                                    Color(0xFFF59E0B).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 120,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.show_chart, size: 40, color: Colors.grey.shade400),
                            SizedBox(height: 8),
                            Text('No data yet', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Forecast
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.auto_graph, color: Color(0xFF3B82F6), size: 20),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '7-Day Forecast',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (predictions.isEmpty || !predictions.first.hasData)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Schedule more pickups to enable forecasting',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...predictions.map((pred) {
                      final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][pred.date.weekday - 1];
                      return _ForecastRow(
                        day: '$dayName ${pred.date.day}',
                        value: pred.total / 1000,
                        maxValue: 5.0,
                      );
                    }),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Insights
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'AI Insights',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...insights.map((insight) => _ModernInsightTile(insight: insight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final List<Color> gradient;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: 4),
                Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final String day;
  final double value;
  final double maxValue;

  const _ForecastRow({required this.day, required this.value, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(day, style: TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / maxValue).clamp(0.0, 1.0),
                backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(width: 12),
          Text(
            '${value.toStringAsFixed(2)} kg',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ModernInsightTile extends StatelessWidget {
  final WasteInsight insight;

  const _ModernInsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final color = insight.category == 'success'
        ? Color(0xFF10B981)
        : insight.category == 'warning'
            ? Color(0xFFF59E0B)
            : Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              insight.metric,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  insight.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 4: Multi-Object Detection - Premium UI
class _DetectionTab extends StatefulWidget {
  const _DetectionTab();

  @override
  State<_DetectionTab> createState() => _DetectionTabState();
}

class _DetectionTabState extends State<_DetectionTab> with SingleTickerProviderStateMixin {
  File? _selectedImage;
  DetectionResult? _result;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
          _result = null;
          _isProcessing = true;
        });

        final result = await MultiObjectDetectionService.detectObjects(picked.path);

        setState(() {
          _result = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Section
          _GlassCard(
            gradient: [Color(0xFFEF4444), Color(0xFFDC2626)],
            child: Column(
              children: [
                if (_selectedImage != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          height: 280,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Detection overlay
                      if (_result != null && _result!.hasDetections)
                        ..._result!.detections.map((det) {
                          final imageWidth = MediaQuery.of(context).size.width - 72;
                          final scaleX = imageWidth / (_result!.imageWidth > 0 ? _result!.imageWidth : 1);
                          final scaleY = 280.0 / (_result!.imageHeight > 0 ? _result!.imageHeight : 1);
                          return Positioned(
                            left: det.boundingBox.x * scaleX,
                            top: det.boundingBox.y * scaleY,
                            child: Container(
                              width: det.boundingBox.width * scaleX,
                              height: det.boundingBox.height * scaleY,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _getColorForLabel(det.label),
                                  width: 2.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _getColorForLabel(det.label),
                                        _getColorForLabel(det.label).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    '${det.label} ${det.confidencePercent}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      // Processing overlay
                      if (_isProcessing)
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _animController,
                                  builder: (context, child) {
                                    return Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withOpacity(_animController.value * 0.5),
                                          width: 3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.center_focus_strong,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Scanning regions...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '7×7 grid analysis',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFEF4444).withOpacity(0.2),
                          Color(0xFFDC2626).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.image_search_rounded,
                            size: 48,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Select image for detection',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Detects multiple waste objects',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _GradientButton(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        gradient: [Colors.white, Colors.white],
                        textColor: Color(0xFFEF4444),
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _OutlineButton(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Results
          if (_result != null) ...[
            // Summary Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _result!.hasDetections
                      ? [Color(0xFF10B981).withOpacity(0.15), Color(0xFF059669).withOpacity(0.05)]
                      : [Colors.grey.withOpacity(0.15), Colors.grey.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _result!.hasDetections ? Color(0xFF10B981).withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: (_result!.hasDetections ? Color(0xFF10B981) : Colors.grey).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _result!.hasDetections ? Icons.check_circle : Icons.search_off,
                      color: _result!.hasDetections ? Color(0xFF10B981) : Colors.grey,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _result!.hasDetections
                              ? '${_result!.objectCount} Objects Detected'
                              : 'No Waste Detected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Processing: ${_result!.processingTimeMs}ms',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Detected Objects Grid
            if (_result!.hasDetections) ...[
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFEF4444).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.grid_view, color: Color(0xFFEF4444), size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Detected Items',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _result!.detections.map((det) {
                        final color = _getColorForLabel(det.label);
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    det.label[0],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    det.label,
                                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  Text(
                                    det.confidencePercent,
                                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Waste Type Summary
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B5CF6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.pie_chart, color: Color(0xFF8B5CF6), size: 20),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Type Summary',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ..._result!.wasteTypeCounts.entries.map((entry) {
                      final color = _getColorForLabel(entry.key);
                      final total = _result!.objectCount;
                      final percentage = (entry.value / total * 100).toStringAsFixed(0);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w500)),
                            ),
                            Text(
                              '${entry.value}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$percentage%',
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // Analysis Details
            if (_result!.analysisDetails.isNotEmpty) ...[
              SizedBox(height: 16),
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: Colors.grey, size: 18),
                        SizedBox(width: 8),
                        Text('Analysis Log', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black26 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _result!.analysisDetails,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _getColorForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'organic': return Color(0xFF10B981);
      case 'recyclable': return Color(0xFF3B82F6);
      case 'hazardous': return Color(0xFFEF4444);
      case 'e-waste': return Color(0xFF8B5CF6);
      case 'human': return Color(0xFFF59E0B);
      default: return Color(0xFF6B7280);
    }
  }
}

// Common Reusable Widgets

class _GlassCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradient;
  
  const _GlassCard({required this.child, this.gradient});
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (gradient != null) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient!),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient![0].withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: child,
      );
    }
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color? textColor;
  final VoidCallback onTap;
  
  const _GradientButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.textColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor ?? Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _OutlineButton({required this.icon, required this.label, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ========================================
/// BIN FILL DETECTION TAB
/// AI-powered bin fill level estimation
/// ========================================
class _BinFillTab extends StatefulWidget {
  const _BinFillTab();

  @override
  State<_BinFillTab> createState() => _BinFillTabState();
}

class _BinFillTabState extends State<_BinFillTab> with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  BinFillResult? _result;
  bool _isProcessing = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = null;
      });
      await _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    setState(() => _isProcessing = true);
    
    final result = await BinFillDetectorService.detectFillLevel(_image!.path);
    
    setState(() {
      _result = result;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          _GlassCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bin Fill Detector',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI analyzes your bin to estimate fill level\nand suggest optimal pickup time',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Image Preview
          _GlassCard(
            child: AspectRatio(
              aspectRatio: 1,
              child: _image != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                        if (_isProcessing)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: Color(0xFF06B6D4)),
                                  SizedBox(height: 16),
                                  Text(
                                    'Analyzing bin...',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_result != null && !_isProcessing)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _getFillGradient(_result!.fillPercentage),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _result!.fillPercentageText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 64,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Take a photo of your bin',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _GradientButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _OutlineButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),
          
          // Results
          if (_result != null && !_isProcessing) ...[
            const SizedBox(height: 24),
            
            // Fill Level Indicator
            _GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        _result!.statusEmoji,
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _result!.statusText,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Fill Level: ${_result!.fillPercentageText}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Fill Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _result!.fillPercentage / 100,
                      minHeight: 20,
                      backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getFillColor(_result!.fillPercentage),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Empty', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Full', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Recommendation
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Text(
                        'Recommendation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    _result!.recommendation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Processing Info
            _GlassCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoChip(
                    icon: Icons.timer,
                    label: '${_result!.processingTimeMs}ms',
                    color: Color(0xFF06B6D4),
                  ),
                  _InfoChip(
                    icon: Icons.density_small,
                    label: 'Density: ${(_result!.contentDensity * 100).toStringAsFixed(0)}%',
                    color: Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _getFillGradient(double percentage) {
    if (percentage >= 75) return [Color(0xFFEF4444), Color(0xFFDC2626)];
    if (percentage >= 50) return [Color(0xFFF59E0B), Color(0xFFD97706)];
    if (percentage >= 25) return [Color(0xFF10B981), Color(0xFF059669)];
    return [Color(0xFF06B6D4), Color(0xFF0891B2)];
  }

  Color _getFillColor(double percentage) {
    if (percentage >= 75) return Color(0xFFEF4444);
    if (percentage >= 50) return Color(0xFFF59E0B);
    if (percentage >= 25) return Color(0xFF10B981);
    return Color(0xFF06B6D4);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// ========================================
/// ECO IMPACT TAB  
/// Waste decomposition & environmental impact
/// ========================================
class _EcoImpactTab extends StatefulWidget {
  const _EcoImpactTab();

  @override
  State<_EcoImpactTab> createState() => _EcoImpactTabState();
}

class _EcoImpactTabState extends State<_EcoImpactTab> with AutomaticKeepAliveClientMixin {
  final TextEditingController _wasteController = TextEditingController();
  DecompositionResult? _result;
  CarbonFootprintResult? _carbonResult;
  bool _isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCarbonFootprint();
  }

  Future<void> _loadCarbonFootprint() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final result = await CarbonFootprintService.calculateForUser(user.uid);
      if (mounted) setState(() => _carbonResult = result);
    }
  }

  Future<void> _predictDecomposition() async {
    final type = _wasteController.text.trim();
    if (type.isEmpty) return;

    setState(() => _isLoading = true);
    
    final result = await DecompositionPredictorService.predict(type);
    
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _wasteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _GlassCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF84CC16), Color(0xFF65A30D)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.eco, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  'Eco Impact Calculator',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'See how long waste takes to decompose\nand learn its environmental impact',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Carbon Footprint Summary (if available)
          if (_carbonResult != null && _carbonResult!.pickupCount > 0) ...[
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 24),
                      SizedBox(width: 8),
                      Text(
                        _carbonResult!.rank,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Score: ${_carbonResult!.ecoScore}/100',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _EcoStatChip(
                        icon: Icons.recycling,
                        value: _carbonResult!.recycledText,
                        label: 'Recycled',
                        color: Color(0xFF10B981),
                      ),
                      _EcoStatChip(
                        icon: Icons.cloud_off,
                        value: _carbonResult!.co2Text,
                        label: 'CO₂ Saved',
                        color: Color(0xFF06B6D4),
                      ),
                      _EcoStatChip(
                        icon: Icons.park,
                        value: _carbonResult!.treesText,
                        label: 'Trees Equiv',
                        color: Color(0xFF84CC16),
                      ),
                      _EcoStatChip(
                        icon: Icons.bolt,
                        value: _carbonResult!.energyText,
                        label: 'Energy',
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
          
          // Search Box
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Waste Type',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _wasteController,
                        decoration: InputDecoration(
                          hintText: 'e.g., plastic bottle, banana peel...',
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                        ),
                        onSubmitted: (_) => _predictDecomposition(),
                      ),
                    ),
                    SizedBox(width: 12),
                    InkWell(
                      onTap: _predictDecomposition,
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF84CC16), Color(0xFF65A30D)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    'Plastic bottle',
                    'Banana peel',
                    'Glass bottle',
                    'Battery',
                  ].map((type) => ActionChip(
                    label: Text(type, style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      _wasteController.text = type;
                      _predictDecomposition();
                    },
                    backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                  )).toList(),
                ),
              ],
            ),
          ),
          
          // Results
          if (_result != null && !_isLoading) ...[
            SizedBox(height: 20),
            
            // Main Result Card
            _GlassCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(_result!.categoryEmoji, style: TextStyle(fontSize: 48)),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _result!.wasteType,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getImpactColor(_result!.environmentalImpact).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_result!.impactEmoji} ${_result!.impactText}',
                                style: TextStyle(
                                  color: _getImpactColor(_result!.environmentalImpact),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)]
                            : [Colors.grey[100]!, Colors.grey[50]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.hourglass_bottom, size: 40, color: Color(0xFFF59E0B)),
                        SizedBox(height: 8),
                        Text(
                          'Decomposition Time',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _result!.displayTime,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '≈ ${_result!.lifetimeComparison}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Properties Row
            Row(
              children: [
                Expanded(
                  child: _PropertyCard(
                    icon: Icons.recycling,
                    label: 'Recyclable',
                    value: _result!.isRecyclable,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _PropertyCard(
                    icon: Icons.eco,
                    label: 'Biodegradable',
                    value: _result!.isBiodegradable,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _PropertyCard(
                    icon: Icons.warning_amber,
                    label: 'Hazardous',
                    value: _result!.isHazardous,
                    isNegative: true,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Eco Tips
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Color(0xFF10B981)),
                      SizedBox(width: 8),
                      Text(
                        'Eco Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ...(_result!.ecoTips.map((tip) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      tip,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ))),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Disposal Method
            _GlassCard(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF6366F1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_sweep, color: Color(0xFF6366F1)),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proper Disposal',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                        Text(
                          _result!.disposalMethod,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Alternatives
            if (_result!.alternatives.isNotEmpty) ...[
              SizedBox(height: 16),
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.swap_horiz, color: Color(0xFF06B6D4)),
                        SizedBox(width: 8),
                        Text(
                          'Eco-Friendly Alternatives',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _result!.alternatives.map((alt) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF06B6D4).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '✓ $alt',
                          style: TextStyle(
                            color: Color(0xFF06B6D4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _getImpactColor(EnvironmentalImpact impact) {
    switch (impact) {
      case EnvironmentalImpact.veryLow:
      case EnvironmentalImpact.low:
        return Color(0xFF10B981);
      case EnvironmentalImpact.medium:
        return Color(0xFFF59E0B);
      case EnvironmentalImpact.high:
        return Color(0xFFF97316);
      case EnvironmentalImpact.veryHigh:
      case EnvironmentalImpact.extreme:
        return Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }
}

class _EcoStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _EcoStatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final bool isNegative;

  const _PropertyCard({
    required this.icon,
    required this.label,
    required this.value,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = isNegative ? !value : value;
    final color = isPositive ? Color(0xFF10B981) : Color(0xFFEF4444);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value ? 'Yes' : 'No',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../user/user_home_screen.dart';
import '../collector/collector_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String role;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _checkTimer;
  Timer? _resendTimerRef;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Start checking for verification every 3 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEmailVerified();
    });
    
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 60);
    _resendTimerRef?.cancel();
    _resendTimerRef = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkTimer?.cancel();
    _resendTimerRef?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    if (_isLoading) return;
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final isVerified = await authService.checkEmailVerified();
      
      if (isVerified && mounted) {
        _checkTimer?.cancel();
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = await authService.getUserData(authService.currentUser!.uid);
        
        if (user != null) {
          userProvider.setUser(user);
          _navigateToHome(user.role);
        }
      }
    } catch (e) {
      debugPrint('Error checking verification: $e');
    }
  }

  Future<void> _resendVerification() async {
    if (_resendTimer > 0) return;
    
    setState(() => _isResending = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.resendEmailVerification();
      
      if (mounted) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Verification email sent!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _manualCheck() async {
    setState(() => _isLoading = true);
    await _checkEmailVerified();
    
    if (mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (!authService.isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Email not verified yet. Please check your inbox.'),
              ],
            ),
            backgroundColor: Colors.orange[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _navigateToHome(String role) {
    Widget homeScreen;
    switch (role) {
      case 'admin':
        homeScreen = const AdminHomeScreen();
        break;
      case 'collector':
        homeScreen = const CollectorHomeScreen();
        break;
      default:
        homeScreen = const UserHomeScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => homeScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Email Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'We\'ve sent a verification link to:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Email
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.info_outline, 
                                color: Colors.blue[700], size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Please check your email and click the verification link.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.folder_outlined, 
                                color: Colors.amber[700], size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Check your spam folder if you don\'t see it.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.autorenew, 
                                color: Colors.green[700], size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'This page will auto-redirect once verified.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Check Verification Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _manualCheck,
                    icon: _isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.green, strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, color: AppTheme.primaryGreen),
                    label: Text(
                      _isLoading ? 'Checking...' : 'I\'ve Verified My Email',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Resend Email Button
                TextButton.icon(
                  onPressed: (_resendTimer > 0 || _isResending) 
                      ? null 
                      : _resendVerification,
                  icon: _isResending 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white70, strokeWidth: 2),
                        )
                      : Icon(
                          Icons.email_outlined,
                          color: _resendTimer > 0 ? Colors.white38 : Colors.white,
                        ),
                  label: Text(
                    _resendTimer > 0 
                        ? 'Resend in ${_resendTimer}s'
                        : 'Resend Verification Email',
                    style: TextStyle(
                      color: _resendTimer > 0 ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Back to Login
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  label: const Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../user/user_home_screen.dart';
import '../collector/collector_home_screen.dart';
import '../admin/admin_home_screen.dart';
import 'login_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  bool _isNewUser = false;
  int _resendTimer = 0;
  String _selectedCountryCode = '+91';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        return true;
      }
      return false;
    });
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final fullPhone = '$_selectedCountryCode$phone';
      
      final existingUser = await authService.getUserByPhone(fullPhone);
      setState(() => _isNewUser = existingUser == null);

      await authService.sendOTP(
        phoneNumber: fullPhone,
        onCodeSent: (verificationId) {
          setState(() {
            _otpSent = true;
            _isLoading = false;
          });
          _startResendTimer();
          _showSuccess('OTP sent to $fullPhone');
        },
        onError: (error) {
          setState(() => _isLoading = false);
          _showError(error);
        },
        onAutoVerify: (credential) async {
          await _signInWithCredential(credential);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    if (_isNewUser) {
      if (_nameController.text.isEmpty ||
          _houseNoController.text.isEmpty ||
          _streetController.text.isEmpty ||
          _cityController.text.isEmpty ||
          _stateController.text.isEmpty ||
          _zipController.text.isEmpty) {
        _showError('Please fill in all details');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final fullPhone = '$_selectedCountryCode${_phoneController.text.trim()}';
      
      String address = '';
      if (_isNewUser) {
        address = '${_houseNoController.text.trim()}, ${_streetController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_zipController.text.trim()}';
      }

      final user = await authService.verifyOTPAndSignIn(
        otp: otp,
        name: _nameController.text.trim(),
        phone: fullPhone,
        address: address,
      );

      if (user != null && mounted) {
        userProvider.setUser(user);
        _navigateToHome(user.role);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Invalid OTP. Please try again.');
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    setState(() => _isLoading = true);
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final fullPhone = '$_selectedCountryCode${_phoneController.text.trim()}';
      
      String address = '';
      if (_isNewUser) {
        address = '${_houseNoController.text.trim()}, ${_streetController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_zipController.text.trim()}';
      }

      final user = await authService.signInWithPhoneCredential(
        credential: credential,
        name: _nameController.text.trim(),
        phone: fullPhone,
        address: address,
      );

      if (user != null && mounted) {
        userProvider.setUser(user);
        _navigateToHome(user.role);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF00D09C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, 
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Phone Icon with glow
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D09C), Color(0xFF00B386)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D09C).withOpacity(0.4),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _otpSent ? Icons.sms_outlined : Icons.phone_android,
                      color: Colors.white,
                      size: 55,
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF00D09C), Color(0xFF00E5B0)],
                    ).createShader(bounds),
                    child: Text(
                      _otpSent ? 'Verify OTP' : 'Phone Login',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    _otpSent 
                        ? 'Enter the 6-digit code sent to\n$_selectedCountryCode ${_phoneController.text}'
                        : 'Enter your phone number to receive\na one-time password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        if (!_otpSent) ...[
                          // Phone Number Input
                          Row(
                            children: [
                              // Country Code
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCountryCode,
                                    dropdownColor: const Color(0xFF1B263B),
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                    items: const [
                                      DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                                      DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                                      DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                                      DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                                    ],
                                    onChanged: (value) {
                                      setState(() => _selectedCountryCode = value!);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Phone Field
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2),
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                    counterText: '',
                                    prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacity(0.6)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: Color(0xFF00D09C), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Send OTP Button
                          _buildActionButton(
                            text: 'Send OTP',
                            icon: Icons.send_rounded,
                            onPressed: _isLoading ? null : _sendOTP,
                          ),
                        ] else ...[
                          // OTP Input
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 12,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              hintText: '• • • • • •',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 32,
                                letterSpacing: 12,
                              ),
                              counterText: '',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF00D09C), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          
                          // New user fields
                          if (_isNewUser) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D09C).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_add, color: Color(0xFF00D09C)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Welcome! Please provide your details.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _houseNoController,
                              label: 'House / Apartment No',
                              icon: Icons.home_work_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _streetController,
                              label: 'Street Name',
                              icon: Icons.add_road,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _cityController,
                                    label: 'City',
                                    icon: Icons.location_city,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _stateController,
                                    label: 'State',
                                    icon: Icons.map,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _zipController,
                              label: 'Zip Code',
                              icon: Icons.pin_drop,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          
                          // Verify OTP Button
                          _buildActionButton(
                            text: 'Verify & Login',
                            icon: Icons.verified_user,
                            onPressed: _isLoading ? null : _verifyOTP,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Resend OTP
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive? ",
                                style: TextStyle(color: Colors.white.withOpacity(0.6)),
                              ),
                              GestureDetector(
                                onTap: _resendTimer > 0 ? null : _sendOTP,
                                child: Text(
                                  _resendTimer > 0 
                                      ? 'Resend in ${_resendTimer}s'
                                      : 'Resend OTP',
                                  style: TextStyle(
                                    color: _resendTimer > 0 
                                        ? Colors.white.withOpacity(0.4)
                                        : const Color(0xFF00D09C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Change Number
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                              });
                            },
                            child: Text(
                              'Change Phone Number',
                              style: TextStyle(color: Colors.white.withOpacity(0.6)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Or divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Email Login Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_rounded, color: Colors.white.withOpacity(0.8)),
                          const SizedBox(width: 10),
                          Text(
                            'Login with Email',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00D09C), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09C),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF00D09C).withOpacity(0.5),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

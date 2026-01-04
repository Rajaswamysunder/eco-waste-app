import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Custom ActionCodeSettings for branded email verification
  ActionCodeSettings get _emailVerificationSettings => ActionCodeSettings(
    url: 'https://ecowaste.page.link/verify',
    handleCodeInApp: false,
    iOSBundleId: 'com.ecowaste.smartWasteApp',
    androidPackageName: 'com.example.smart_waste_app',
    androidInstallApp: true,
    androidMinimumVersion: '21',
  );

  // Sign up with email and send verification email
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    String role = 'user',
    String? assignedStreet,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Update display name for personalized emails
        await user.updateDisplayName(name);
        
        // Send email verification with custom settings
        await user.sendEmailVerification(_emailVerificationSettings);

        UserModel userModel = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          phone: phone,
          address: address,
          role: role,
          assignedStreet: assignedStreet,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification(_emailVerificationSettings);
    }
  }

  // Reload user to check email verification status
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Set user as online when they login
        await setOnlineStatus(user.uid, true);
        return await getUserData(user.uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============ PHONE AUTHENTICATION ============

  // Store verification ID for OTP verification
  String? _verificationId;
  int? _resendToken;

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          onAutoVerify(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP and sign in
  Future<UserModel?> verifyOTPAndSignIn({
    required String otp,
    required String name,
    required String phone,
    required String address,
  }) async {
    if (_verificationId == null) {
      throw Exception('No verification ID. Please request OTP first.');
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!doc.exists) {
          // New user - create profile
          UserModel userModel = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            name: name,
            phone: phone,
            address: address,
            role: 'user',
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
          await setOnlineStatus(user.uid, true);
          return userModel;
        } else {
          // Existing user - just login
          await setOnlineStatus(user.uid, true);
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with phone credential (for auto-verification)
  Future<UserModel?> signInWithPhoneCredential({
    required PhoneAuthCredential credential,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!doc.exists) {
          UserModel userModel = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            name: name,
            phone: phone,
            address: address,
            role: 'user',
            createdAt: DateTime.now(),
          );
          await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
          await setOnlineStatus(user.uid, true);
          return userModel;
        } else {
          await setOnlineStatus(user.uid, true);
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Check if phone number is already registered
  Future<bool> isPhoneRegistered(String phone) async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // Get user by phone number
  Future<UserModel?> getUserByPhone(String phone) async {
    final query = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return UserModel.fromMap(query.docs.first.data(), query.docs.first.id);
    }
    return null;
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    // Set user as offline before logging out
    final user = _auth.currentUser;
    if (user != null) {
      await setOnlineStatus(user.uid, false);
    }
    await _auth.signOut();
  }

  // Update online status and last seen timestamp
  Future<void> setOnlineStatus(String uid, bool isOnline) async {
    await _firestore.collection('users').doc(uid).update({
      'isOnline': isOnline,
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  // Update last seen timestamp (call periodically to keep status fresh)
  Future<void> updateLastSeen(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? address,
  }) async {
    Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (address != null) updateData['address'] = address;

    await _firestore.collection('users').doc(uid).update(updateData);
  }

  // Update profile image URL
  Future<void> updateProfileImage(String uid, String imageUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
    });
  }

  // Remove profile image
  Future<void> removeProfileImage(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'profileImageUrl': null,
    });
  }
}

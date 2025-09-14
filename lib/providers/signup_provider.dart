import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../screens/homescreen/user_home_screen.dart';

class SignupProvider with ChangeNotifier {
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isLoading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final formKey = GlobalKey<FormState>();

  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get isLoading => _isLoading;

  set email(String value) {
    _email = value.trim();
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  set confirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      final user = userCredential.user;

      if (user != null) {
        try {
          // Create user document in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': _email,
            'name': _email.split('@')[0], // Default name from email prefix
            'avatar': 'https://via.placeholder.com/50', // Default avatar
          });
        } catch (e) {
          print('Firestore error: $e');
          _showDesignedSnackBar(context, 'Failed to create user data: $e', isError: true);
          return;
        }

        _showDesignedSnackBar(context, 'Account created successfully!');
        // Delay navigation to ensure snackbar is visible
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use a stronger one.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = 'An unexpected error occurred. Please try again.';
      }
      _showDesignedSnackBar(context, message, isError: true);
    } catch (e) {
      print('Unexpected error: $e');
      _showDesignedSnackBar(context, 'An unexpected error occurred: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signupWithBiometrics(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (kIsWeb) {
      _showDesignedSnackBar(context, 'Biometric signup is not supported on web.', isError: true);
      return;
    }

    _setLoading(true);

    try {
      // Create user with Firebase
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      final user = userCredential.user;

      if (user != null) {
        try {
          // Create user document in Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': _email,
            'name': _email.split('@')[0], // Default name from email prefix
            'avatar': 'https://via.placeholder.com/50', // Default avatar
          });
        } catch (e) {
          print('Firestore error: $e');
          _showDesignedSnackBar(context, 'Failed to create user data: $e', isError: true);
          return;
        }

        // Verify biometrics
        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Enable biometrics for future logins',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (authenticated) {
          // Store email and biometric flag in secure storage
          await _storage.write(key: 'biometric_email', value: _email);
          await _storage.write(key: 'biometric_enabled', value: 'true');
          _showDesignedSnackBar(context, 'Account created with biometrics enabled!');
        } else {
          _showDesignedSnackBar(context, 'Biometric enrollment failed. Account created without biometrics.', isError: true);
        }

        // Delay navigation to ensure snackbar is visible
        await Future.delayed(Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use a stronger one.';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection.';
          break;
        default:
          message = 'An unexpected error occurred. Please try again.';
      }
      _showDesignedSnackBar(context, message, isError: true);
    } catch (e) {
      print('Unexpected error: $e');
      _showDesignedSnackBar(context, 'An unexpected error occurred: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showDesignedSnackBar(BuildContext context, String message, {bool isError = false}) {
    final colorScheme = isError
        ? (backgroundColor: Colors.red.withOpacity(0.2), borderColor: Colors.red.withOpacity(0.5), iconColor: Colors.redAccent)
        : (backgroundColor: Colors.cyan.withOpacity(0.2), borderColor: Colors.cyan.withOpacity(0.5), iconColor: Colors.cyanAccent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.backgroundColor,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(width: 1.5, color: colorScheme.borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                    color: colorScheme.iconColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, curve: Curves.easeOut),
      ),
    );
  }
}
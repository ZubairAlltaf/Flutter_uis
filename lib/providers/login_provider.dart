import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';

import '../screens/homescreen/user_home_screen.dart';

class LoginProvider with ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  final formKey = GlobalKey<FormState>();

  String get email => _email;
  String get password => _password;
  bool get isLoading => _isLoading;

  set email(String value) {
    _email = value.trim();
    notifyListeners();
  }

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _setLoading(true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      _showDesignedSnackBar(context, 'Login successful!');
      // Navigate to UserHomeScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserHomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your connection.';
          break;
        default:
          message = 'Something went wrong. Try again.';
      }
      _showDesignedSnackBar(context, message, isError: true);
    } catch (e) {
      _showDesignedSnackBar(context, 'Unexpected error occurred.', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithBiometrics(BuildContext context) async {
    if (kIsWeb) {
      _showDesignedSnackBar(context, 'Biometric login is not supported on web.', isError: true);
      return;
    }

    _setLoading(true);

    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint or use face ID to log in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        try {
          // Hardcoded credentials for demo; use secure storage in production
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          );
          _showDesignedSnackBar(context, 'Biometric login successful!');
          // Navigate to UserHomeScreen after successful biometric login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
          );
        } on FirebaseAuthException catch (e) {
          String message;
          switch (e.code) {
            case 'user-not-found':
              message = 'No user found for biometric login.';
              break;
            case 'wrong-password':
              message = 'Biometric login credentials invalid.';
              break;
            default:
              message = 'Biometric login failed.';
          }
          _showDesignedSnackBar(context, message, isError: true);
        }
      } else {
        _showDesignedSnackBar(context, 'Biometric authentication failed.', isError: true);
      }
    } catch (e) {
      _showDesignedSnackBar(context, 'Biometric error: $e', isError: true);
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
        : (backgroundColor: Colors.green.withOpacity(0.2), borderColor: Colors.green.withOpacity(0.5), iconColor: Colors.greenAccent);

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
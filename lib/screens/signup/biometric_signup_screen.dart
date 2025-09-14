import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:flutteruis/providers/signup_provider.dart';
import 'package:flutteruis/screens/login/biometric_login_screen.dart';

class BiometricSignupScreen extends StatelessWidget {
  const BiometricSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signupProvider = Provider.of<SignupProvider>(context);
    final enableBiometrics = ValueNotifier<bool>(false);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.cyan.shade300, Colors.blue.shade900],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: signupProvider.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                  SizedBox(height: 32),
                  TextFormField(
                    onChanged: (value) => signupProvider.email = value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2),
                  SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => signupProvider.password = value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.2),
                  SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => signupProvider.confirmPassword = value,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != signupProvider.password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.2),
                  SizedBox(height: 16),
                  if (!kIsWeb)
                    ValueListenableBuilder<bool>(
                      valueListenable: enableBiometrics,
                      builder: (context, value, child) {
                        return CheckboxListTile(
                          title: Text(
                            'Enable Biometric Login',
                            style: TextStyle(color: Colors.white),
                          ),
                          value: value,
                          onChanged: (newValue) {
                            enableBiometrics.value = newValue ?? false;
                          },
                          checkColor: Colors.blue.shade900,
                          activeColor: Colors.white,
                        ).animate().fadeIn(duration: 1000.ms).scale();
                      },
                    ),
                  SizedBox(height: 24),
                  signupProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => enableBiometrics.value
                            ? signupProvider.signupWithBiometrics(context)
                            : signupProvider.signUp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ).animate().fadeIn(duration: 1200.ms).scale(),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BiometricLoginScreen()),
                          );
                        },
                        child: Text(
                          'Already have an account? Sign In',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ).animate().fadeIn(duration: 1400.ms).scale(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
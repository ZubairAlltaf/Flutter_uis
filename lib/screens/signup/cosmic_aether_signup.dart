import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart';

class _GlassmorphicTextField extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Function(String) onChanged;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _GlassmorphicTextField({
    required this.hintText,
    required this.prefixIcon,
    required this.onChanged,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              width: 1.5,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            onChanged: onChanged,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon, color: Colors.white70),
              suffixIcon: suffixIcon,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}


class CosmicAetherSignup extends StatelessWidget {
  const CosmicAetherSignup({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            const _AnimatedGradientBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        'Join the Zubairdev',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              blurRadius: 10.0,
                              color: Colors.purpleAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 900.ms).slideY(begin: -0.5),
                      const SizedBox(height: 10),
                      Text(
                        'Create your account to begin the journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ).animate().fadeIn(duration: 900.ms, delay: 300.ms),
                      const SizedBox(height: 50),
                      const _CosmicSignupForm(),
                      const SizedBox(height: 30),
                      Consumer<SignupProvider>(
                        builder: (context, provider, _) {
                          return GestureDetector(
                            onTap: provider.isLoading ? null : () => provider.signUp(context),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                  colors: [Colors.purpleAccent, Colors.blueAccent],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: provider.isLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(duration: 900.ms, delay: 900.ms).slideY(begin: 0.5),
                      const SizedBox(height: 30),
                      const _SocialLoginsDivider(),
                      const SizedBox(height: 20),
                      const _SocialLoginButtons(),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {},
                        child: Text.rich(
                          TextSpan(
                            text: 'Already a member? ',
                            style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            children: const [
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 900.ms, delay: 1500.ms),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CosmicSignupForm extends StatefulWidget {
  const _CosmicSignupForm();

  @override
  State<_CosmicSignupForm> createState() => _CosmicSignupFormState();
}

class _CosmicSignupFormState extends State<_CosmicSignupForm> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignupProvider>(context, listen: false);

    return Form(
      key: provider.formKey,
      child: Column(
        children: [
          _GlassmorphicTextField(
            hintText: 'Email Address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => provider.email = value,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _GlassmorphicTextField(
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _isPasswordObscured,
            onChanged: (value) => provider.password = value,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
            ),
          ),
          const SizedBox(height: 20),
          _GlassmorphicTextField(
            hintText: 'Confirm Password',
            prefixIcon: Icons.lock_person_outlined,
            obscureText: _isConfirmPasswordObscured,
            onChanged: (value) => provider.confirmPassword = value,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm password';
              if (value != provider.password) return 'Passwords do not match';
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 900.ms, delay: 600.ms).slideY(begin: 0.5);
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  const _AnimatedGradientBackground();

  @override
  State<_AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<_AnimatedGradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_controller);
    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color(0xFF161229), Color(0xFF0A041C), Color(0xFF3F064A)],
              begin: _topAlignmentAnimation.value,
              end: _bottomAlignmentAnimation.value,
            ),
          ),
        );
      },
    );
  }
}

class _SocialLoginsDivider extends StatelessWidget {
  const _SocialLoginsDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Or continue with',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
      ],
    ).animate().fadeIn(duration: 900.ms, delay: 1200.ms);
  }
}

class _SocialLoginButtons extends StatelessWidget {
  const _SocialLoginButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          onTap: () {},
          child: const Text(
            'G',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(width: 20),
        _SocialButton(
          onTap: () {},
          child: const Icon(Icons.apple, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 20),
        _SocialButton(
          onTap: () {},
          child: const Icon(Icons.facebook, color: Colors.white, size: 28),
        ),
      ],
    ).animate().fadeIn(duration: 900.ms, delay: 1350.ms).slideY(begin: 0.5);
  }
}

class _SocialButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SocialButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.2)),
            ),
            child: Center(
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
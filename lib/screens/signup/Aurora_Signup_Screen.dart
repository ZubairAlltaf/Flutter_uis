import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart';

class AuroraSignupScreen extends StatelessWidget {
  const AuroraSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            const _AnimatedAuroraBackground(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: const _AuroraSignupPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuroraSignupPanel extends StatelessWidget {
  const _AuroraSignupPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Join Zubairdev',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(color: Colors.teal.withOpacity(0.5), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Create your account to begin the journey',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 40),
              const _AuroraSignupForm(),
              const SizedBox(height: 30),
              const _AuroraSignupButton(),
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
                          color: Colors.tealAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack);
  }
}


class _AuroraSignupForm extends StatefulWidget {
  const _AuroraSignupForm();

  @override
  State<_AuroraSignupForm> createState() => _AuroraSignupFormState();
}

class _AuroraSignupFormState extends State<_AuroraSignupForm> {
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();

    return Form(
      key: provider.formKey,
      child: Column(
        children: [
          _AuroraTextField(
            prefixIcon: Icons.email_outlined,
            hintText: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => provider.email = value,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),
          _AuroraTextField(
            prefixIcon: Icons.lock_outline,
            hintText: 'Password',
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
                size: 20,
              ),
              onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
            ),
          ),
          const SizedBox(height: 20),
          _AuroraTextField(
            prefixIcon: Icons.lock_person_outlined,
            hintText: 'Confirm Password',
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
                size: 20,
              ),
              onPressed: () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured),
            ),
          ),
        ].animate(interval: 100.ms).fadeIn(duration: 500.ms, delay: 800.ms).slideX(begin: 0.2),
      ),
    );
  }
}


class _AuroraTextField extends StatefulWidget {
  final IconData prefixIcon;
  final String hintText;
  final bool obscureText;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _AuroraTextField({
    required this.prefixIcon,
    required this.hintText,
    required this.onChanged,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  State<_AuroraTextField> createState() => _AuroraTextFieldState();
}

class _AuroraTextFieldState extends State<_AuroraTextField> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      _focusNode.hasFocus ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: CustomPaint(
        painter: _AnimatedBorderPainter(animation: _controller),
        child: TextFormField(
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          validator: widget.validator,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(widget.prefixIcon, color: Colors.white70, size: 20),
            suffixIcon: widget.suffixIcon,
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
        ),
      ),
    );
  }
}

class _AnimatedBorderPainter extends CustomPainter {
  final Animation<double> animation;
  _AnimatedBorderPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [Colors.transparent, Colors.tealAccent],
        stops: [0.0, 0.5],
        startAngle: 1.5,
        endAngle: 4.5,
        transform: GradientRotation(1.5),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path.combine(
      PathOperation.xor,
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12))),
      Path()..addRRect(RRect.fromRectAndRadius(rect.deflate(paint.strokeWidth), const Radius.circular(12))),
    );

    final animatedPath = Path();
    for (final metric in path.computeMetrics()) {
      animatedPath.addPath(
        metric.extractPath(0, metric.length * animation.value),
        Offset.zero,
      );
    }
    canvas.drawPath(animatedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _AuroraSignupButton extends StatefulWidget {
  const _AuroraSignupButton();

  @override
  State<_AuroraSignupButton> createState() => _AuroraSignupButtonState();
}

class _AuroraSignupButtonState extends State<_AuroraSignupButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: provider.isLoading ? null : () => provider.signUp(context),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.cyanAccent],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: provider.isLoading
                ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
            )
                : const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedAuroraBackground extends StatelessWidget {
  const _AnimatedAuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D122E), Color(0xFF0E2A47), Color(0xFF1E5F74)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat()).shimmer(
      duration: 10000.ms,
      colors: [
        Colors.transparent,
        Colors.tealAccent.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: [0.2, 0.5, 0.8],
    );
  }
}

class _SocialLoginsDivider extends StatelessWidget {
  const _SocialLoginsDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Or continue with', style: TextStyle(color: Colors.white.withOpacity(0.7))),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
      ],
    );
  }
}

class _SocialLoginButtons extends StatelessWidget {
  const _SocialLoginButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(onTap: () {}, child: const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))),
        const SizedBox(width: 20),
        _SocialButton(onTap: () {}, child: const Icon(Icons.apple, color: Colors.white, size: 28)),
        const SizedBox(width: 20),
        _SocialButton(onTap: () {}, child: const Icon(Icons.facebook, color: Colors.white, size: 28)),
      ],
    );
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
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(child: child),
      ),
    );
  }
}
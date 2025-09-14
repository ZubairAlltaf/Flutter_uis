// lib/screens/signup/aqueous_signup_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart'; // Your original provider

class AqueousSignupScreen extends StatefulWidget {
  const AqueousSignupScreen({super.key});

  @override
  State<AqueousSignupScreen> createState() => _AqueousSignupScreenState();
}

class _AqueousSignupScreenState extends State<AqueousSignupScreen> {
  // A controller to send tap locations to the background for ripple effects
  final StreamController<Offset> _rippleController = StreamController.broadcast();

  @override
  void dispose() {
    _rippleController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            _AqueousBackground(rippleStream: _rippleController.stream),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _AqueousSignupForm(onTap: (offset) {
                    _rippleController.add(offset);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AqueousSignupForm extends StatelessWidget {
  final ValueChanged<Offset> onTap;
  const _AqueousSignupForm({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return Form(
      key: provider.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Join Zubairdev',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Begin your journey with us today.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.blueGrey[500]),
          ),
          const SizedBox(height: 60),
          _AqueousTextField(
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onTap: onTap,
            onChanged: (value) => provider.email = value,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email cannot be empty';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _PasswordTextField(onTap: onTap),
          const SizedBox(height: 24),
          _ConfirmPasswordTextField(onTap: onTap),
          const SizedBox(height: 40),
          _AqueousActionButton(onTap: onTap),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Text(
              'Already have an account? Log In',
              style: TextStyle(color: Colors.teal.shade600, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
    );
  }
}

class _PasswordTextField extends StatefulWidget {
  final ValueChanged<Offset> onTap;
  const _PasswordTextField({required this.onTap});

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return _AqueousTextField(
      label: 'Password',
      icon: Icons.lock_outline,
      isObscured: _isObscured,
      onTap: widget.onTap,
      onChanged: (value) => provider.password = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password cannot be empty';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      suffix: IconButton(
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.blueGrey[300]),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _ConfirmPasswordTextField extends StatefulWidget {
  final ValueChanged<Offset> onTap;
  const _ConfirmPasswordTextField({required this.onTap});

  @override
  State<_ConfirmPasswordTextField> createState() => _ConfirmPasswordTextFieldState();
}

class _ConfirmPasswordTextFieldState extends State<_ConfirmPasswordTextField> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return _AqueousTextField(
      label: 'Confirm Password',
      icon: Icons.lock_person_outlined,
      isObscured: _isObscured,
      onTap: widget.onTap,
      onChanged: (value) => provider.confirmPassword = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please confirm your password';
        if (value != provider.password) return 'Passwords do not match';
        return null;
      },
      suffix: IconButton(
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.blueGrey[300]),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _AqueousTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isObscured;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<Offset> onTap;

  const _AqueousTextField({
    required this.label, required this.icon, required this.onChanged,
    required this.onTap, this.validator, this.isObscured = false,
    this.keyboardType, this.suffix,
  });

  @override
  State<_AqueousTextField> createState() => _AqueousTextFieldState();
}

class _AqueousTextFieldState extends State<_AqueousTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _isFocused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => widget.onTap(details.globalPosition),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.only(left: 16, right: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused ? Colors.teal.shade300 : Colors.white.withOpacity(0.7),
            width: 1.5,
          ),
          boxShadow: _isFocused
              ? [
            BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
            const BoxShadow(color: Colors.white, blurRadius: 20, spreadRadius: -10, offset: Offset(0, 5)),
          ]
              : [
            const BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: -5, offset: Offset(0, 10)),
          ],
        ),
        child: TextFormField(
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          validator: widget.validator,
          obscureText: widget.isObscured,
          keyboardType: widget.keyboardType,
          cursorColor: Colors.teal.shade700,
          style: TextStyle(fontSize: 16, color: Colors.blueGrey[900]),
          decoration: InputDecoration(
            icon: Icon(widget.icon, color: _isFocused ? Colors.teal.shade600 : Colors.blueGrey[300]),
            labelText: widget.label,
            labelStyle: TextStyle(color: _isFocused ? Colors.teal.shade700 : Colors.blueGrey[400]),
            border: InputBorder.none,
            suffixIcon: widget.suffix,
          ),
        ),
      ),
    );
  }
}

class _AqueousActionButton extends StatefulWidget {
  final ValueChanged<Offset> onTap;
  const _AqueousActionButton({required this.onTap});

  @override
  State<_AqueousActionButton> createState() => _AqueousActionButtonState();
}

class _AqueousActionButtonState extends State<_AqueousActionButton> with TickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();
    return GestureDetector(
      onTapDown: (details) {
        widget.onTap(details.globalPosition);
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: provider.isLoading ? null : () => provider.signUp(context),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 55,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.teal.shade400,
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: provider.isLoading
              ? AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [Colors.transparent, Colors.white30, Colors.transparent],
                  stops: [
                    _shimmerController.value - 0.5,
                    _shimmerController.value,
                    _shimmerController.value + 0.5,
                  ],
                ).createShader(bounds),
                child: Container(color: Colors.white.withOpacity(0.2)),
              );
            },
          )
              : const Center(
            child: Text(
              'Create Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Background
class _AqueousBackground extends StatefulWidget {
  final Stream<Offset> rippleStream;
  const _AqueousBackground({required this.rippleStream});

  @override
  State<_AqueousBackground> createState() => _AqueousBackgroundState();
}

class _AqueousBackgroundState extends State<_AqueousBackground> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Ripple> _ripples = [];
  late StreamSubscription<Offset> _rippleSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..addListener(_updateRipples);
    _rippleSubscription = widget.rippleStream.listen((offset) {
      _addRipple(offset);
    });
  }

  void _addRipple(Offset offset) {
    setState(() {
      _ripples.add(_Ripple(position: offset, progress: 0.0, maxRadius: 200));
      if (!_controller.isAnimating) {
        _controller.forward(from: 0.0);
      }
    });
  }

  void _updateRipples() {
    setState(() {
      for (final ripple in _ripples) {
        ripple.progress += 0.01;
      }
      _ripples.removeWhere((ripple) => ripple.progress >= 1.0);
    });
    if (_ripples.isNotEmpty && !_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rippleSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AqueousPainter(ripples: _ripples),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)],
          ),
        ),
      ),
    );
  }
}

class _AqueousPainter extends CustomPainter {
  final List<_Ripple> ripples;
  _AqueousPainter({required this.ripples});

  @override
  void paint(Canvas canvas, Size size) {
    for (final ripple in ripples) {
      final easedProgress = Curves.easeOut.transform(ripple.progress);
      final radius = easedProgress * ripple.maxRadius;
      final opacity = 1.0 - easedProgress;
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(ripple.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Ripple {
  final Offset position;
  final double maxRadius;
  double progress;
  _Ripple({required this.position, required this.progress, required this.maxRadius});
}
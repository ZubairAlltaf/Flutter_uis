// lib/screens/signup/celestial_signup_screen.dart
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart'; // Your original provider

// A palette of colors for the celestial glow effects
const List<Color> _auroraColors = [
  Color(0xFF69EACB),
  Color(0xFF76B2FE),
  Color(0xFFB39DDB),
  Color(0xFFF48FB1),
];

class CelestialSignupScreen extends StatefulWidget {
  const CelestialSignupScreen({super.key});

  @override
  State<CelestialSignupScreen> createState() => _CelestialSignupScreenState();
}

class _CelestialSignupScreenState extends State<CelestialSignupScreen> {
  // A controller to send tap locations to the background for glow pulse effects
  final StreamController<Offset> _pulseController = StreamController.broadcast();

  @override
  void dispose() {
    _pulseController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            _CelestialBackground(pulseStream: _pulseController.stream),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _CelestialSignupForm(onTap: (offset) {
                    _pulseController.add(offset);
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

class _CelestialSignupForm extends StatelessWidget {
  final ValueChanged<Offset> onTap;
  const _CelestialSignupForm({required this.onTap});

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
            'Join the Cosmos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 20),
                Shadow(color: Colors.white.withOpacity(0.5), blurRadius: 30),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your account to explore.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.blueGrey[200]),
          ),
          const SizedBox(height: 60),
          _CelestialTextField(
            label: 'Email Address',
            icon: Icons.alternate_email,
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
          _CelestialActionButton(onTap: onTap),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Text(
              'Already have an account? Log In',
              style: TextStyle(color: Colors.cyan[300], fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
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
    return _CelestialTextField(
      label: 'Password',
      icon: Icons.vpn_key_outlined,
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
    return _CelestialTextField(
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

class _CelestialTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isObscured;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<Offset> onTap;

  const _CelestialTextField({
    required this.label, required this.icon, required this.onChanged,
    required this.onTap, this.validator, this.isObscured = false,
    this.keyboardType, this.suffix,
  });

  @override
  State<_CelestialTextField> createState() => _CelestialTextFieldState();
}

class _CelestialTextFieldState extends State<_CelestialTextField> {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.only(left: 16, right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isFocused ? Colors.cyanAccent.withOpacity(0.8) : Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: TextFormField(
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              validator: widget.validator,
              obscureText: widget.isObscured,
              keyboardType: widget.keyboardType,
              cursorColor: Colors.cyanAccent,
              style: TextStyle(fontSize: 16, color: Colors.grey[200]),
              decoration: InputDecoration(
                icon: Icon(widget.icon, color: _isFocused ? Colors.cyanAccent : Colors.blueGrey[300]),
                labelText: widget.label,
                labelStyle: TextStyle(color: _isFocused ? Colors.cyan[300] : Colors.blueGrey[300]),
                border: InputBorder.none,
                suffixIcon: widget.suffix,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CelestialActionButton extends StatefulWidget {
  final ValueChanged<Offset> onTap;
  const _CelestialActionButton({required this.onTap});

  @override
  State<_CelestialActionButton> createState() => _CelestialActionButtonState();
}

class _CelestialActionButtonState extends State<_CelestialActionButton> with TickerProviderStateMixin {
  late final AnimationController _cometController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _cometController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
  }

  @override
  void dispose() {
    _cometController.dispose();
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.cyan.withOpacity(0.25),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: provider.isLoading
                  ? AnimatedBuilder(
                animation: _cometController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      transform: GradientRotation(_cometController.value * 2 * pi),
                      colors: const [
                        Colors.transparent,
                        Colors.white70,
                        Colors.transparent,
                      ],
                      stops: const [0.4, 0.5, 0.6],
                    ).createShader(bounds),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
              )
                  : const Center(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Background with Animated Aurora
class _CelestialBackground extends StatefulWidget {
  final Stream<Offset> pulseStream;
  const _CelestialBackground({required this.pulseStream});

  @override
  State<_CelestialBackground> createState() => _CelestialBackgroundState();
}

class _CelestialBackgroundState extends State<_CelestialBackground> with TickerProviderStateMixin {
  late final AnimationController _auroraController;
  late final AnimationController _pulseUpdateController;
  final List<_GlowPulse> _pulses = [];
  late StreamSubscription<Offset> _pulseSubscription;

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _pulseUpdateController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..addListener(_updatePulses);

    _pulseSubscription = widget.pulseStream.listen((offset) {
      _addPulse(offset);
    });
  }

  void _addPulse(Offset offset) {
    setState(() {
      final color = _auroraColors[Random().nextInt(_auroraColors.length)];
      _pulses.add(_GlowPulse(position: offset, color: color));
      if (!_pulseUpdateController.isAnimating) {
        _pulseUpdateController.forward(from: 0.0);
      }
    });
  }

  void _updatePulses() {
    setState(() {
      for (final pulse in _pulses) {
        pulse.progress = _pulseUpdateController.value;
      }
      _pulses.removeWhere((pulse) => pulse.progress >= 1.0);
    });
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _pulseUpdateController.dispose();
    _pulseSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark space color
        Container(color: const Color(0xff0d1127)),
        // Animated Aurora effect
        AnimatedBuilder(
          animation: _auroraController,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                return SweepGradient(
                  center: Alignment.center,
                  transform: GradientRotation(_auroraController.value * 2 * pi),
                  colors: _auroraColors.map((c) => c.withOpacity(0.5)).toList(),
                ).createShader(bounds);
              },
              child: Container(color: Colors.white),
            );
          },
        ),
        // Interactive glow pulses drawn on top
        IgnorePointer(
          child: CustomPaint(
            painter: _CelestialPainter(pulses: _pulses),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }
}

class _CelestialPainter extends CustomPainter {
  final List<_GlowPulse> pulses;
  _CelestialPainter({required this.pulses});

  @override
  void paint(Canvas canvas, Size size) {
    for (final pulse in pulses) {
      final easedProgress = Curves.easeOutCubic.transform(pulse.progress);
      final radius = easedProgress * 300;
      final opacity = 1.0 - easedProgress;

      final paint = Paint()
        ..color = pulse.color.withOpacity(opacity * 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      canvas.drawCircle(pulse.position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CelestialPainter oldDelegate) => true;
}

class _GlowPulse {
  final Offset position;
  final Color color;
  double progress = 0.0;
  _GlowPulse({required this.position, required this.color});
}
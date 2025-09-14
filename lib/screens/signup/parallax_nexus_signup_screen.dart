// lib/screens/signup/parallax_nexus_signup_screen.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart'; // Your original provider

class ParallaxNexusSignupScreen extends StatefulWidget {
  const ParallaxNexusSignupScreen({super.key});

  @override
  State<ParallaxNexusSignupScreen> createState() => _ParallaxNexusSignupScreenState();
}

class _ParallaxNexusSignupScreenState extends State<ParallaxNexusSignupScreen> {
  Offset _pointerOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D051D),
        body: MouseRegion(
          onHover: (event) => setState(() => _pointerOffset = event.localPosition - Offset(size.width / 2, size.height / 2)),
          onExit: (_) => setState(() => _pointerOffset = Offset.zero),
          child: GestureDetector(
            onPanStart: (details) => setState(() => _pointerOffset = details.localPosition - Offset(size.width / 2, size.height / 2)),
            onPanUpdate: (details) => setState(() => _pointerOffset = details.localPosition - Offset(size.width / 2, size.height / 2)),
            onPanEnd: (_) => setState(() => _pointerOffset = Offset.zero),
            child: Stack(
              children: [
                // --- Parallax Layers ---

                // FIXED: Wrapped particle layers in IgnorePointer to allow clicks to pass through.
                _ParallaxLayer(offset: _pointerOffset, depth: 0.1, child: const IgnorePointer(child: _ParticleLayer(seed: 0, particleCount: 30, color: Colors.purple))),
                _ParallaxLayer(offset: _pointerOffset, depth: 0.3, child: const IgnorePointer(child: _ParticleLayer(seed: 1, particleCount: 25, color: Colors.pink))),

                // The UI Form Layer - Does NOT get IgnorePointer.
                _ParallaxLayer(offset: _pointerOffset, depth: 0.6, child: const _SignupForm()),

                // FIXED: Wrapped particle layers in IgnorePointer to allow clicks to pass through.
                _ParallaxLayer(offset: _pointerOffset, depth: 1.0, child: const IgnorePointer(child: _ParticleLayer(seed: 2, particleCount: 20, color: Colors.cyanAccent, isForeground: true))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParallaxLayer extends StatelessWidget {
  final Offset offset;
  final double depth;
  final Widget child;

  const _ParallaxLayer({required this.offset, required this.depth, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(offset.dx * depth * 0.1, offset.dy * depth * 0.1, 0),
      child: child,
    );
  }
}

class _SignupForm extends StatelessWidget {
  const _SignupForm();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: provider.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join Zubairdev',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.white24, blurRadius: 30)],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access the nexus.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 50),
                _NexusTextField(
                  label: 'Email Address',
                  icon: Icons.alternate_email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) => provider.email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email cannot be empty';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _PasswordTextField(),
                const SizedBox(height: 20),
                _ConfirmPasswordTextField(),
                const SizedBox(height: 30),
                const _NexusButton(),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: const Text('Already have an account? Log In', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ).animate(delay: 300.ms).fadeIn(duration: 800.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
          ),
        ),
      ),
    );
  }
}

class _PasswordTextField extends StatefulWidget {
  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return _NexusTextField(
      label: 'Password',
      icon: Icons.lock_outline,
      isObscured: _isObscured,
      onChanged: (value) => provider.password = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password cannot be empty';
        if (value.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      suffix: IconButton(
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _ConfirmPasswordTextField extends StatefulWidget {
  @override
  _ConfirmPasswordTextFieldState createState() => _ConfirmPasswordTextFieldState();
}

class _ConfirmPasswordTextFieldState extends State<_ConfirmPasswordTextField> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return _NexusTextField(
      label: 'Confirm Password',
      icon: Icons.lock_person_outlined,
      isObscured: _isObscured,
      onChanged: (value) => provider.confirmPassword = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please confirm your password';
        if (value != provider.password) return 'Passwords do not match';
        return null;
      },
      suffix: IconButton(
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _NexusTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isObscured;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _NexusTextField({
    required this.label, required this.icon, required this.onChanged,
    this.validator, this.isObscured = false, this.keyboardType, this.suffix,
  });

  @override
  State<_NexusTextField> createState() => _NexusTextFieldState();
}

class _NexusTextFieldState extends State<_NexusTextField> {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? Colors.cyanAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 16, spreadRadius: 2),
            ] : [],
          ),
          child: TextFormField(
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            validator: widget.validator,
            obscureText: widget.isObscured,
            keyboardType: widget.keyboardType,
            cursorColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: const TextStyle(color: Colors.white54),
              floatingLabelStyle: const TextStyle(color: Colors.cyanAccent),
              prefixIcon: Icon(widget.icon, color: _isFocused ? Colors.white : Colors.white54),
              suffixIcon: widget.suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _NexusButton extends StatefulWidget {
  const _NexusButton();

  @override
  State<_NexusButton> createState() => _NexusButtonState();
}

class _NexusButtonState extends State<_NexusButton> with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _coreController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _coreController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _coreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();
    return GestureDetector(
      onTap: provider.isLoading ? null : () => provider.signUp(context),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: const [Colors.purple, Colors.cyan],
                transform: GradientRotation(_glowController.value * 2 * pi),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.5 + _glowController.value * 0.2),
                  blurRadius: 15 + (_glowController.value * 10),
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5 + (1 - _glowController.value) * 0.2),
                  blurRadius: 15 + ((1 - _glowController.value) * 10),
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: provider.isLoading
                  ? AnimatedBuilder(
                animation: _coreController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _NexusCorePainter(animationValue: _coreController.value),
                    size: const Size(24, 24),
                  );
                },
              )
                  : const Text(
                'Create Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NexusCorePainter extends CustomPainter {
  final double animationValue;
  _NexusCorePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final eased = Curves.easeInOut.transform(animationValue);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    // Outer pulsing ring
    paint.strokeWidth = 1.0;
    paint.color = Colors.white.withOpacity(1.0 - eased);
    canvas.drawCircle(center, size.width / 2 * eased, paint);

    // Inner rotating arcs
    paint.strokeWidth = 2.0;
    paint.color = Colors.white;
    final arcSize = Size.square(size.width / 1.5);
    final rect = Rect.fromCenter(center: center, width: arcSize.width, height: arcSize.height);
    final angle = animationValue * 2 * pi;
    canvas.drawArc(rect, angle, pi * 0.8, false, paint);
    canvas.drawArc(rect, angle + pi, pi * 0.8, false, paint);
  }

  @override
  bool shouldRepaint(covariant _NexusCorePainter oldDelegate) => oldDelegate.animationValue != animationValue;
}

// Particle Background
class _ParticleLayer extends StatefulWidget {
  final int seed;
  final int particleCount;
  final Color color;
  final bool isForeground;

  const _ParticleLayer({
    required this.seed,
    required this.particleCount,
    required this.color,
    this.isForeground = false,
  });

  @override
  _ParticleLayerState createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<_ParticleLayer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _particles = List.generate(widget.particleCount, (index) => _createParticle());
  }

  _Particle _createParticle() {
    return _Particle(
      position: Offset(_random.nextDouble(), _random.nextDouble()),
      radius: _random.nextDouble() * (widget.isForeground ? 3 : 1.5) + 0.5,
      opacity: _random.nextDouble() * 0.8 + 0.2,
      velocity: Offset(
        (_random.nextDouble() - 0.5) * (widget.isForeground ? 0.05 : 0.01),
        (_random.nextDouble() - 0.5) * (widget.isForeground ? 0.05 : 0.01),
      ),
    );
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
        _updateParticles();
        return CustomPaint(
          painter: _ParticlePainter(particles: _particles, color: widget.color),
          child: Container(),
        );
      },
    );
  }

  void _updateParticles() {
    for (int i = 0; i < _particles.length; i++) {
      var p = _particles[i];
      p.position = Offset(p.position.dx + p.velocity.dx, p.position.dy + p.velocity.dy);
      if (p.position.dx < -0.1 || p.position.dx > 1.1 || p.position.dy < -0.1 || p.position.dy > 1.1) {
        _particles[i] = _createParticle()..position = Offset(_random.nextDouble(), _random.nextDouble());
      }
    }
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;
  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final particle in particles) {
      paint.color = color.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(particle.position.dx * size.width, particle.position.dy * size.height), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  Offset position;
  double radius;
  double opacity;
  Offset velocity;
  _Particle({required this.position, required this.radius, required this.opacity, required this.velocity});
}
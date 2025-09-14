import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
// NOTE: Your provided LoginProvider is assumed to be in this path.
import '../../providers/login_provider.dart';

// The class name is reverted to SupernovaLoginScreen as requested.
class SupernovaLoginScreen extends StatefulWidget {
  const SupernovaLoginScreen({super.key});

  @override
  State<SupernovaLoginScreen> createState() => _SupernovaLoginScreenState();
}

class _SupernovaLoginScreenState extends State<SupernovaLoginScreen> with TickerProviderStateMixin {
  // --- ANIMATION CONTROLLERS ---
  late final AnimationController _awakeningController; // Controls the sigil appearing and UI fade-in
  late final AnimationController _idleController;      // Controls the ambient pulsing and wisps
  late final AnimationController _submissionController;// Controls the login activation sequence

  // --- UI STATE ---
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- ANIMATION STATE ---
  final List<RuneParticle> _particles = [];
  bool _wasLoading = false;

  @override
  void initState() {
    super.initState();
    _awakeningController = AnimationController(vsync: this, duration: 2500.ms);
    _idleController = AnimationController(vsync: this, duration: 10.seconds)..repeat();
    _submissionController = AnimationController(vsync: this, duration: 3000.ms);

    final provider = Provider.of<LoginProvider>(context, listen: false);
    provider.addListener(_onProviderChange);

    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _emailController.addListener(() => _fireRune(isEmail: true));
    _passwordController.addListener(() => _fireRune(isEmail: false));

    // The sigil awakens...
    Future.delayed(500.ms, () {
      if (mounted) _awakeningController.forward();
    });
  }

  void _onProviderChange() {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    if (_wasLoading && !provider.isLoading) {
      if (FirebaseAuth.instance.currentUser != null) {
        _submissionController.forward(); // Success
      } else {
        _submissionController.reverse(); // Failure
      }
    }
    _wasLoading = provider.isLoading;
  }

  // Creates a rune particle that flows from the UI to the sigil
  void _fireRune({required bool isEmail}) {
    setState(() {
      _particles.add(RuneParticle(isEmail: isEmail));
    });
    if (_particles.length > 30) {
      _particles.removeRange(0, _particles.length - 30);
    }
  }

  @override
  void dispose() {
    Provider.of<LoginProvider>(context, listen: false).removeListener(_onProviderChange);
    _awakeningController.dispose();
    _idleController.dispose();
    _submissionController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(LoginProvider provider) {
    if (provider.formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      _submissionController.animateTo(0.5, curve: Curves.easeInOut);
      provider.login(context);
    } else {
      _submissionController.value = 0.5;
      _submissionController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF100f14), // Dark stone color
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The magical sigil background painter
            AnimatedBuilder(
              animation: Listenable.merge([_awakeningController, _idleController, _submissionController]),
              builder: (context, child) {
                for (var p in _particles) { p.update(); }
                _particles.removeWhere((p) => p.isDead);
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _SigilPainter(
                    awakeningAnim: _awakeningController,
                    idleAnim: _idleController,
                    submissionAnim: _submissionController,
                    emailFocus: _emailFocusNode.hasFocus,
                    passwordFocus: _passwordFocusNode.hasFocus,
                    particles: _particles,
                  ),
                );
              },
            ),
            // The redesigned UI Form
            FadeTransition(
              opacity: _awakeningController.drive(CurveTween(curve: Curves.easeOut)),
              child: Form(
                key: provider.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title is removed to focus on the central sigil button
                    const SizedBox(height: 80),
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hint: 'EMAIL',
                      onChanged: (v) => provider.email = v,
                      validator: (v) => v!.isEmpty ? ' ' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      hint: 'PASSWORD',
                      isPassword: true,
                      onChanged: (v) => provider.password = v,
                      validator: (v) => v!.length < 6 ? ' ' : null,
                    ),
                    const Expanded(child: SizedBox()), // Pushes the button to the bottom
                    _buildActivateButton(provider),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Redesigned text field, now a floating crystal shard
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator,
    bool isPassword = false,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color focusColor = const Color(0xFF65d8ff);
    final Color idleColor = const Color(0xFF3b5c78);
    final Color currentColor = hasFocus ? focusColor : idleColor;

    return Container(
      width: 280,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: currentColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: currentColor.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'Cinzel', // A more mystical font
              color: Colors.white, fontSize: 16, letterSpacing: 3, fontWeight: FontWeight.bold),
          cursorColor: focusColor,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 3, fontFamily: 'Cinzel'),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  // Redesigned button, now the central activation crystal
  Widget _buildActivateButton(LoginProvider provider) {
    return GestureDetector(
      onTap: () => _submit(provider),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.4),
          border: Border.all(color: const Color(0xFF65d8ff).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF65d8ff).withOpacity(0.5),
              blurRadius: 25,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'ACTIVATE',
            style: TextStyle(
                fontFamily: 'Cinzel',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(color: const Color(0xFF65d8ff), blurRadius: 10),
                ]
            ),
          ),
        ),
      ),
    );
  }
}

// THE "ARCANE SIGIL" PAINTER
class _SigilPainter extends CustomPainter {
  final Animation<double> awakeningAnim;
  final Animation<double> idleAnim;
  final Animation<double> submissionAnim;
  final bool emailFocus;
  final bool passwordFocus;
  final List<RuneParticle> particles;

  final Paint sigilPaint = Paint()..style = PaintingStyle.stroke;
  final Paint particlePaint = Paint();

  static final _random = math.Random();

  _SigilPainter({
    required this.awakeningAnim,
    required this.idleAnim,
    required this.submissionAnim,
    required this.emailFocus,
    required this.passwordFocus,
    required this.particles,
  }) : super(repaint: Listenable.merge([awakeningAnim, idleAnim, submissionAnim]));

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final awake = Curves.easeInOut.transform(awakeningAnim.value);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    final loadingProgress = Curves.easeInOut.transform(math.min(submissionAnim.value, 0.5) * 2.0);
    final successProgress = Curves.easeOutCubic.transform(math.max(0.0, submissionAnim.value - 0.5) * 2.0);
    final failureProgress = (submissionAnim.status == AnimationStatus.reverse)
        ? Curves.easeOutQuint.transform(math.max(0.0, 0.5 - submissionAnim.value) * 2.0)
        : 0.0;

    final idlePulse = (math.sin(idleAnim.value * math.pi * 2) + 1) / 2;

    // Draw the main sigil
    canvas.save();
    canvas.translate(center.dx, center.dy);

    for (int i = 0; i < 3; i++) {
      final radius = maxRadius * (0.6 + i * 0.15);
      double activation = 0;
      if (i == 0 && emailFocus) activation = 1.0;
      if (i == 1 && passwordFocus) activation = 1.0;

      final color = Color.lerp(const Color(0xFF3b5c78), const Color(0xFF65d8ff), activation)!;
      final brightness = (idlePulse * 0.2 + 0.15 + activation * 0.65) * awake * (1.0 - successProgress);

      sigilPaint.strokeWidth = 1.0 + activation * 1.5;
      sigilPaint.color = color.withOpacity(brightness);
      sigilPaint.maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 1.0 + brightness * 3.0);

      canvas.drawCircle(Offset.zero, radius, sigilPaint);

      int runeCount = (12 + i * 6);
      for(int j=0; j < runeCount; j++){
        final angle = (j / runeCount + idleAnim.value * 0.1 * (i % 2 == 0 ? 1 : -1)) * math.pi * 2;
        final start = Offset.fromDirection(angle, radius - 5);
        final end = Offset.fromDirection(angle, radius + 5);
        canvas.drawLine(start, end, sigilPaint);
      }
    }
    canvas.restore();

    if(loadingProgress > 0) {
      _drawActivation(canvas, size, loadingProgress);
    }

    for (final particle in particles) {
      final pos = particle.getCurrentPosition(size, maxRadius);
      final opacity = (1.0 - particle.progress) * 0.8;
      particlePaint.color = const Color(0xFF65d8ff).withOpacity(opacity);
      particlePaint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
      canvas.drawCircle(pos, 2.5, particlePaint);
    }

    if (successProgress > 0) _drawSuccessLight(canvas, size, successProgress);
    if (failureProgress > 0) _drawFailureCrack(canvas, size, 1.0 - failureProgress);
  }

  // *** FIXED METHOD ***
  void _drawActivation(Canvas canvas, Size size, double progress) {
    final center = size.center(Offset.zero);
    final maxRadius = math.min(size.width, size.height) * 0.45;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFFaefbff);

    final path = Path();
    const pointCount = 100;
    // First, build the entire spiral path
    for (int i = 0; i <= pointCount; i++) {
      final p = i / pointCount;
      final angle = p * math.pi * 8 + (p * 20);
      final radius = maxRadius * 0.9 * (1.0 - p);
      final pos = center + Offset.fromDirection(angle, radius);
      if (i == 0) {
        path.moveTo(pos.dx, pos.dy);
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }

    // Then, compute metrics and extract a portion based on progress
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, paint..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3));
    }
  }

  void _drawSuccessLight(Canvas canvas, Size size, double progress) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
          center, size.height * 0.8,
          [Colors.white, Colors.white.withOpacity(0.0)],
          [progress * 0.3, progress]);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawFailureCrack(Canvas canvas, Size size, double progress) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red.withOpacity(1.0 - progress);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    for(int i=0; i<5; i++) {
      final angle = _random.nextDouble() * math.pi * 2;
      final path = Path()..moveTo(0,0);
      for(int j=1; j< 5; j++){
        final length = j * 50 * (1.0-progress);
        final offsetAngle = (_random.nextDouble() - 0.5) * 1.5;
        path.lineTo(
          math.cos(angle + offsetAngle) * length,
          math.sin(angle + offsetAngle) * length,
        );
      }
      canvas.drawPath(path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SigilPainter oldDelegate) => true;
}

class RuneParticle {
  final bool isEmail;
  double progress = 0.0;
  final double speed = 0.04 + _SigilPainter._random.nextDouble() * 0.01;
  late final double endRadiusRatio;
  late final double endAngle;

  RuneParticle({required this.isEmail}) {
    endRadiusRatio = isEmail ? 0.65 : 0.8;
    endAngle = _SigilPainter._random.nextDouble() * math.pi * 2;
  }

  void update() => progress += speed;
  bool get isDead => progress >= 1.0;

  Offset getCurrentPosition(Size size, double maxRadius) {
    final startY = isEmail ? size.height * 0.5 - 155 : size.height * 0.5 - 85;
    final start = Offset(size.width * 0.5, startY);
    final end = size.center(Offset.zero) + Offset.fromDirection(endAngle, maxRadius * endRadiusRatio);
    return ui.Offset.lerp(start, end, Curves.easeIn.transform(progress))!;
  }
}
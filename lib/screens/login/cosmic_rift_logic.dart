import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/login_provider.dart';

class CosmicRiftLoginScreen extends StatefulWidget {
  const CosmicRiftLoginScreen({super.key});

  @override
  State<CosmicRiftLoginScreen> createState() => _CosmicRiftLoginScreenState();
}

class _CosmicRiftLoginScreenState extends State<CosmicRiftLoginScreen> with TickerProviderStateMixin {
  // --- ANIMATION CONTROLLERS ---
  // Controls the initial "opening" of the rift and UI fade-in
  late final AnimationController _awakeningController;
  // Controls the gentle, idle swirling of the rift and stars
  late final AnimationController _idleController;
  // Controls the animations for login submission (loading, success, failure)
  late final AnimationController _submissionController;

  // --- UI STATE ---
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- ANIMATION STATE ---
  final List<EnergyParticle> _particles = [];
  bool _wasLoading = false;

  @override
  void initState() {
    super.initState();
    _awakeningController = AnimationController(vsync: this, duration: 2500.ms);
    _idleController = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _submissionController = AnimationController(vsync: this, duration: 3000.ms);

    final provider = Provider.of<LoginProvider>(context, listen: false);
    provider.addListener(_onProviderChange);

    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _emailController.addListener(() => _fireParticle(isEmail: true));
    _passwordController.addListener(() => _fireParticle(isEmail: false));

    // The rift opens after a short delay
    Future.delayed(500.ms, () {
      if (mounted) _awakeningController.forward();
    });
  }

  void _onProviderChange() {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    if (_wasLoading && !provider.isLoading) {
      if (FirebaseAuth.instance.currentUser != null) {
        // On success, complete the animation forward
        _submissionController.forward();
      } else {
        // On failure, reverse the animation from the halfway point
        _submissionController.reverse();
      }
    }
    _wasLoading = provider.isLoading;
  }

  // Fires a particle from the text field towards the rift
  void _fireParticle({required bool isEmail}) {
    setState(() {
      _particles.add(EnergyParticle(isEmail: isEmail));
    });
    // Cull the list to prevent performance issues
    if (_particles.length > 40) {
      _particles.removeRange(0, _particles.length - 40);
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
      // Animate to the halfway point (vortex) and wait for the provider result
      _submissionController.animateTo(0.5, curve: Curves.easeIn);
      provider.login(context);
    } else {
      // If validation fails, do a quick "reject" animation
      _submissionController.value = 0.5;
      _submissionController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF01000b), // Deep space color
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // The new Cosmic Rift background painter
            AnimatedBuilder(
              animation: Listenable.merge([_awakeningController, _idleController, _submissionController]),
              builder: (context, child) {
                for (var p in _particles) { p.update(); }
                _particles.removeWhere((p) => p.isDead);
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _RiftPainter(
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
                    Text(
                      'STABILIZE THE RIFT',
                      style: TextStyle(
                          color: Colors.purple.shade100.withOpacity(0.8),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(color: const Color(0xFFc056f7), blurRadius: 10),
                            Shadow(color: const Color(0xFF7a2bb5), blurRadius: 20),
                          ]
                      ),
                    ).animate(onPlay: (c) => c.repeat())
                        .shimmer(delay: 2000.ms, duration: 1800.ms, color: Colors.white),
                    const SizedBox(height: 60),
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      hint: 'NODE-ID (EMAIL)',
                      onChanged: (v) => provider.email = v,
                      validator: (v) => v!.isEmpty ? ' ' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      hint: 'PASSKEY (PASSWORD)',
                      isPassword: true,
                      onChanged: (v) => provider.password = v,
                      validator: (v) => v!.length < 6 ? ' ' : null,
                    ),
                    const SizedBox(height: 60),
                    _buildEngageButton(provider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A redesigned, angular text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator,
    bool isPassword = false,
  }) {
    final bool hasFocus = focusNode.hasFocus;
    final Color focusColor = const Color(0xFFd06aff);
    final Color idleColor = const Color(0xFF3e2f75);
    final Color currentColor = hasFocus ? focusColor : idleColor;

    return Container(
      width: 320,
      height: 50,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: currentColor.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipPath(
        clipper: _AngularClipper(),
        child: Container(
          color: currentColor,
          padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
          child: ClipPath(
            clipper: _AngularClipper(),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 4),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                obscureText: isPassword,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2.5, fontWeight: FontWeight.w500),
                cursorColor: focusColor,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), letterSpacing: 2.5),
                ),
                onChanged: onChanged,
                validator: validator,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // A redesigned, angular button widget
  Widget _buildEngageButton(LoginProvider provider) {
    return GestureDetector(
      onTap: () => _submit(provider),
      child: Container(
        width: 250,
        height: 55,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFd06aff).withOpacity(0.6),
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipPath(
          clipper: _AngularClipper(),
          child: Container(
            color: const Color(0xFF3e2f75),
            child: Center(
              child: Text(
                'ENGAGE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                    shadows: [
                      Shadow(color: const Color(0xFFd06aff), blurRadius: 10),
                    ]
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A custom clipper for the angular UI elements
class _AngularClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(20, 0)
      ..lineTo(size.width - 20, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - 20, size.height)
      ..lineTo(20, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// THE NEW "COSMIC RIFT" PAINTER
class _RiftPainter extends CustomPainter {
  final Animation<double> awakeningAnim;
  final Animation<double> idleAnim;
  final Animation<double> submissionAnim;
  final bool emailFocus;
  final bool passwordFocus;
  final List<EnergyParticle> particles;

  List<Star> _stars = [];
  bool _starsInitialized = false;

  final Paint starPaint = Paint();
  final Paint riftPaint = Paint();
  final Paint particlePaint = Paint();

  static final _random = math.Random();

  _RiftPainter({
    required this.awakeningAnim,
    required this.idleAnim,
    required this.submissionAnim,
    required this.emailFocus,
    required this.passwordFocus,
    required this.particles,
  }) : super(repaint: Listenable.merge([awakeningAnim, idleAnim, submissionAnim]));

  @override
  void paint(Canvas canvas, Size size) {
    if (!_starsInitialized) {
      _initializeStars(size);
      _starsInitialized = true;
    }

    final center = size.center(Offset.zero);
    final awake = Curves.easeInOut.transform(awakeningAnim.value);

    // --- Submission animation values ---
    // 0.0 -> 0.5: Loading phase
    // 0.5 -> 1.0: Success phase
    final loadingProgress = Curves.easeInQuad.transform(math.min(submissionAnim.value, 0.5) * 2.0);
    final successProgress = Curves.easeOutExpo.transform(math.max(0.0, submissionAnim.value - 0.5) * 2.0);
    // 0.5 -> 0.0 on reverse: Failure phase
    final failureProgress = (submissionAnim.status == AnimationStatus.reverse)
        ? Curves.easeOutCubic.transform(math.max(0.0, 0.5 - submissionAnim.value) * 2.0)
        : 0.0;

    // 1. Draw the parallax starfield
    canvas.save();
    canvas.translate(idleAnim.value * 10, 0); // Slow horizontal drift
    for (final star in _stars) {
      final opacity = star.opacity * awake * (1.0 - successProgress);
      starPaint.color = Colors.white.withOpacity(opacity);
      // Stars get pulled into the vortex during loading
      final starPos = Offset.lerp(star.pos, center, loadingProgress * 0.8)!;
      canvas.drawCircle(starPos, star.radius, starPaint);
    }
    canvas.restore();

    // 2. Draw the Cosmic Rift
    canvas.save();
    // The rift spins faster during loading
    canvas.translate(center.dx, center.dy);
    canvas.rotate(loadingProgress * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);

    final riftWidth = (size.width * 0.2 + (math.sin(idleAnim.value * math.pi * 2) * 10)) * awake * (1.0 - successProgress);
    final path = Path()
      ..moveTo(center.dx - riftWidth / 2, 0)
      ..quadraticBezierTo(center.dx, size.height * 0.25, center.dx + riftWidth/2, size.height/2)
      ..quadraticBezierTo(center.dx, size.height * 0.75, center.dx - riftWidth/2, size.height)
      ..quadraticBezierTo(center.dx - riftWidth, size.height * 0.75, center.dx - riftWidth * 1.5, size.height/2)
      ..quadraticBezierTo(center.dx - riftWidth, size.height * 0.25, center.dx - riftWidth/2, 0);

    riftPaint.shader = ui.Gradient.radial(center, size.height, [
      Colors.white.withOpacity(0.8 * awake),
      const Color(0xFFd06aff).withOpacity(0.7 * awake),
      const Color(0xFF3e2f75).withOpacity(0.5 * awake),
      Colors.transparent,
    ], [0.0, 0.1, 0.35, 1.0]);
    riftPaint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20);
    canvas.drawPath(path, riftPaint);
    canvas.restore();

    // 3. Draw energy arcs on focus
    if (emailFocus || passwordFocus) {
      final yPos = emailFocus ? size.height * 0.5 - 92 : size.height * 0.5 + 32;
      final startPoint = Offset(center.dx - 160, yPos);
      _drawEnergyArc(canvas, size, startPoint, (emailFocus ? 1 : -1));
    }

    // 4. Draw typing particles
    for (final particle in particles) {
      final pos = particle.getCurrentPosition(size);
      particlePaint.color = Colors.white.withOpacity(1.0 - particle.progress);
      particlePaint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3);
      canvas.drawCircle(pos, 2, particlePaint);
    }

    // 5. Draw Success/Failure overlays
    if (successProgress > 0) _drawSuccessFlash(canvas, size, successProgress);
    if (failureProgress > 0) _drawFailureGlitch(canvas, size, 1.0 - failureProgress);
  }

  void _drawEnergyArc(Canvas canvas, Size size, Offset start, double direction) {
    final center = size.center(Offset.zero);
    final arcPaint = Paint()
      ..color = const Color(0xFFd06aff)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);

    final path = Path()..moveTo(start.dx, start.dy);
    final end = center + Offset(_random.nextDouble() * 20 - 10, _random.nextDouble() * 100 * direction);
    final ctrl1 = Offset.lerp(start, end, 0.3)! + Offset(_random.nextDouble() * 80, 0);
    final ctrl2 = Offset.lerp(start, end, 0.7)! - Offset(_random.nextDouble() * 80, 0);

    path.cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);
    canvas.drawPath(path, arcPaint);
  }

  void _drawSuccessFlash(Canvas canvas, Size size, double progress) {
    final center = size.center(Offset.zero);
    final radius = progress * size.width * 1.2;
    final paint = Paint()
      ..shader = ui.Gradient.radial(
          center, radius, [Colors.white, Colors.white.withOpacity(0.0)], [0.2, 1.0]);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawFailureGlitch(Canvas canvas, Size size, double progress) {
    final p = (1.0 - progress) * 0.5;
    final glitchPaint = Paint()..color = Colors.red.withOpacity(p * 0.5);
    final offset = (1.0 - p) * 15;
    for(int i=0; i < 5; i++) {
      final y = _random.nextDouble() * size.height;
      final h = _random.nextDouble() * 50;
      canvas.drawRect(
          Rect.fromLTWH(_random.nextDouble() * offset - offset/2, y, size.width, h),
          glitchPaint..blendMode = BlendMode.colorDodge
      );
    }
  }

  void _initializeStars(Size size) {
    _stars = List.generate(150, (index) {
      return Star(
        pos: Offset(_random.nextDouble() * size.width, _random.nextDouble() * size.height),
        radius: _random.nextDouble() * 1.2 + 0.2,
        opacity: _random.nextDouble() * 0.8 + 0.2,
      );
    });
    _starsInitialized = true;
  }

  @override
  bool shouldRepaint(covariant _RiftPainter oldDelegate) => true;
}

class Star {
  final Offset pos;
  final double radius;
  final double opacity;
  Star({required this.pos, required this.radius, required this.opacity});
}

class EnergyParticle {
  final bool isEmail;
  double progress = 0.0;
  final double speed = 0.03 + _RiftPainter._random.nextDouble() * 0.02;

  EnergyParticle({required this.isEmail});
  void update() => progress += speed;
  bool get isDead => progress >= 1.0;

  Offset getCurrentPosition(Size size) {
    final yPos = isEmail ? size.height * 0.5 - 92 : size.height * 0.5 + 32;
    final start = Offset(size.width * 0.5 - 160, yPos);
    final end = size.center(Offset.zero);
    return ui.Offset.lerp(start, end, progress)!;
  }
}
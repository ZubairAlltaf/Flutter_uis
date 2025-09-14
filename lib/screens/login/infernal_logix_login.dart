import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../providers/login_provider.dart';

// Represents a single star in our cosmic background.
class _Star {
  late Offset position;
  late double radius;
  late double opacity;
  // 'Depth' for parallax effect. Closer stars move faster.
  late double parallaxFactor;

  _Star(Size size) {
    position = Offset(math.Random().nextDouble() * size.width, math.Random().nextDouble() * size.height);
    radius = math.Random().nextDouble() * 1.2 + 0.2;
    opacity = math.Random().nextDouble() * 0.8 + 0.1;
    parallaxFactor = math.Random().nextDouble() * 0.4 + 0.1;
  }
}

class AetherialForgeLoginScreen extends StatefulWidget {
  const AetherialForgeLoginScreen({super.key});

  @override
  State<AetherialForgeLoginScreen> createState() => _AetherialForgeLoginScreenState();
}

class _AetherialForgeLoginScreenState extends State<AetherialForgeLoginScreen> with TickerProviderStateMixin {
  bool _obscurePassword = true;
  List<_Star> _stars = [];

  late final AnimationController _cosmicAnimationController;
  late final AnimationController _glitchController;

  @override
  void initState() {
    super.initState();
    _cosmicAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Generate stars once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _stars = List.generate(200, (index) => _Star(size));
      });
    });
  }

  @override
  void dispose() {
    _cosmicAnimationController.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF01000A),
      body: Stack(
        children: [
          _buildCosmicBackground(),
          Center(
            child: Animate(
              effects: [
                FadeEffect(duration: 800.ms, delay: 200.ms),
                ScaleEffect(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
              ],
              child: _buildLoginCard(provider),
            ),
          ),
          _buildSignatureFooter(),
        ],
      ),
    );
  }

  // ----------- UI WIDGETS & COMPONENTS ------------

  Widget _buildCosmicBackground() {
    return AnimatedBuilder(
      animation: _cosmicAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarfieldPainter(
            stars: _stars,
            animationValue: _cosmicAnimationController.value,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildLoginCard(LoginProvider provider) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom painter for the animated border and glow
          AnimatedBuilder(
            animation: _cosmicAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: _CosmicContainmentFieldPainter(
                  animationValue: _cosmicAnimationController.value,
                  glowColor: const Color(0xFF00BFFF), // DeepSkyBlue
                  borderColor: const Color(0xFF48D1CC), // MediumTurquoise
                ),
                child: const SizedBox(width: 380, height: 450),
              );
            },
          ),
          // Frosted glass effect card
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 380,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.cyanAccent.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAetherialHeader(),
                      const SizedBox(height: 28),
                      _buildInputField("👽 Celestial Handle", (val) => provider.email = val,
                              (val) => val!.isEmpty ? 'Handle cannot be empty.' : null),
                      const SizedBox(height: 20),
                      _buildPasswordField(provider),
                      const SizedBox(height: 35),
                      _buildLoginButton(provider),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAetherialHeader() {
    return Column(
      children: [
        Icon(Icons.hub_rounded, size: 40, color: Colors.white.withOpacity(0.9)),
        const SizedBox(height: 12),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Color(0xFF61A3FF), Color(0xFF8A2BE2), Color(0xFF00BFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text(
            "Aetherial Forge",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [Shadow(color: Colors.blue, blurRadius: 10)],
            ),
          ),
        ),
      ],
    ).animate(
      controller: _glitchController,
      onComplete: (c) => c.repeat(),
    ).shimmer(
      delay: 1.seconds,
      duration: 1.5.seconds,
      colors: [Colors.transparent, Colors.cyan.withOpacity(0.3), Colors.transparent],
    );
  }

  Widget _buildInputField(
      String hint,
      void Function(String) onChanged,
      String? Function(String?) validator,
      ) {
    return TextFormField(
      style: const TextStyle(color: Colors.white, letterSpacing: 0.5),
      decoration: _inputDecoration(hint),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildPasswordField(LoginProvider provider) {
    return TextFormField(
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white, letterSpacing: 0.5),
      decoration: _inputDecoration("🔑 Singularity Key").copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white70,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      onChanged: (val) => provider.password = val,
      validator: (val) => val!.length < 6 ? 'Key is too fragile.' : null,
    );
  }

  Widget _buildLoginButton(LoginProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BFFF).withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () => provider.login(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          backgroundColor: Colors.transparent, // Crucial for gradient
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00BFFF), Color(0xFF48D1CC)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            alignment: Alignment.center,
            child: provider.isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
            )
                : const Text(
              "Engage Warp",
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5);
  }

  InputDecoration _inputDecoration(String hint) {
    final borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      errorStyle: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.w500),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: borderStyle,
      enabledBorder: borderStyle,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00BFFF), width: 1.8),
      ),
    );
  }

  Widget _buildSignatureFooter() {
    return Positioned(
      bottom: 15,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          "🌌 //Zubair Dev",
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        ).animate().fadeIn(duration: 2.seconds).slideY(begin: 0.5),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double animationValue;

  final Paint _starPaint = Paint();
  final Paint _nebulaPaint = Paint();

  _StarfieldPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Pulsating Nebula
    final nebulaCenter = Offset(size.width * 0.8, size.height * 1.1);
    final nebulaRadius = size.width * 0.7 + math.sin(animationValue * 2 * math.pi) * 50;

    // The Rect that defines the coordinate space for our gradient shader.
    final shaderRect = Rect.fromCircle(center: nebulaCenter, radius: nebulaRadius);

    // The gradient. Its 'center' is relative to shaderRect (Alignment.center).
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.5, // Fills the inscribed circle of the shaderRect.
      colors: [
        const Color(0xFF8A2BE2).withOpacity(0.15), // BlueViolet
        const Color(0xFF4B0082).withOpacity(0.0), // Indigo
      ],
      stops: const [0.0, 0.7],
    );

    // Create the shader and apply it to the paint.
    _nebulaPaint.shader = gradient.createShader(shaderRect);

    // Draw the entire canvas using the paint with the configured shader.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _nebulaPaint);

    // Stars
    for (final star in stars) {
      _starPaint.color = Colors.white.withOpacity(star.opacity);
      // Parallax effect: Animate stars' position based on their 'depth'
      final newY = (star.position.dy + animationValue * 50 * star.parallaxFactor) % size.height;
      canvas.drawCircle(Offset(star.position.dx, newY), star.radius, _starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}


// 🖼️ Gravitational Lens Card Border Painter
class _CosmicContainmentFieldPainter extends CustomPainter {
  final double animationValue;
  final Color borderColor;
  final Color glowColor;

  _CosmicContainmentFieldPainter({
    required this.animationValue,
    required this.borderColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.4 + math.sin(animationValue * math.pi * 2) * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15);
    canvas.drawRRect(rrect, glowPaint);

    final borderPaint = Paint()
      ..color = borderColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);

    final Path path = Path()..addRRect(rrect.deflate(1.0));
    final PathMetrics pathMetrics = path.computeMetrics();
    final PathMetric pathMetric = pathMetrics.first;
    final double distance = pathMetric.length * (animationValue % 1.0);
    final Tangent? tangent = pathMetric.getTangentForOffset(distance);

    if (tangent != null) {
      final particlePaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, glowColor.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: tangent.position, radius: 8));
      canvas.drawCircle(tangent.position, 6, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicContainmentFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
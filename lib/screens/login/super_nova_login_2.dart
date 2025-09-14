import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Using the provider path you provided.
import '../../providers/login_provider.dart';


class SupernovaLoginScreenV4 extends StatefulWidget {
  const SupernovaLoginScreenV4({super.key});

  @override
  State<SupernovaLoginScreenV4> createState() => _SupernovaLoginScreenV4State();
}

class _SupernovaLoginScreenV4State extends State<SupernovaLoginScreenV4> {
  final _mousePosition = ValueNotifier(Offset.zero);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xff020212),
      body: MouseRegion(
        onHover: (event) => _mousePosition.value = event.position,
        child: Stack(
          children: [
            AnimatedCosmicBackground(mousePosition: _mousePosition),
            Center(
              child: buildGlassmorphicCard(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGlassmorphicCard(BuildContext context, LoginProvider provider) {
    return ValueListenableBuilder<Offset>(
      valueListenable: _mousePosition,
      builder: (context, mousePos, child) {
        final size = MediaQuery.of(context).size;
        final x = (mousePos.dx / size.width) * 2 - 1;
        final y = (mousePos.dy / size.height) * 2 - 1;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(-x * 0.1)
            ..rotateX(y * 0.1),
          alignment: FractionalOffset.center,
          child: child,
        );
      },
      child: AuroraCard(
        mousePosition: _mousePosition,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          child: Form(
            key: provider.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlitchTitle(text: 'Ignition'),
                const SizedBox(height: 35),
                CosmicTextField(
                  hintText: "Email Address",
                  prefixIcon: Icons.alternate_email_rounded,
                  onChanged: (val) => provider.email = val,
                  validator: (val) => (val == null || !val.contains('@')) ? 'Enter a valid email' : null,
                ).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideX(begin: -0.2),
                const SizedBox(height: 20),
                CosmicTextField(
                  hintText: "Password",
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                  onChanged: (val) => provider.password = val,
                  validator: (val) => (val == null || val.length < 6) ? 'Password must be 6+ characters' : null,
                ).animate(delay: 600.ms).fadeIn(duration: 500.ms).slideX(begin: 0.2),
                const SizedBox(height: 35),
                buildLoginButton(context, provider)
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .shake(hz: 2, duration: 500.ms, curve: Curves.easeInOutCubic),
              ],
            ),
          ),
        ),
      ).animate().scale(delay: 100.ms, duration: 500.ms, curve: Curves.easeOut),
    );
  }

  Widget buildLoginButton(BuildContext context, LoginProvider provider) {
    return ShockwaveButton(
      onTap: provider.isLoading ? null : () => provider.login(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xff00f2fe), Color(0xff673ab7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.6), blurRadius: 20, spreadRadius: -5, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.cyan.withOpacity(0.4), blurRadius: 20, spreadRadius: -5, offset: const Offset(0, 8)),
          ],
        ),
        child: Center(
          child: provider.isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text("Engage", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
      ),
    );
  }
}

// --- DYNAMIC UI WIDGETS ---

class GlitchTitle extends StatefulWidget {
  final String text;
  const GlitchTitle({super.key, required this.text});

  @override
  State<GlitchTitle> createState() => _GlitchTitleState();
}

class _GlitchTitleState extends State<GlitchTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
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
        final value = _controller.value;
        final glitchAmount = sin(value * pi * 4) * 2;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.cyanAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Stack(
            children: [
              // Original Text
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_outlined, size: 36),
                  SizedBox(width: 12),
                  Text('Ignition', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              // Glitch effect
              if (value > 0.95 || (value > 0.45 && value < 0.5))
                Transform.translate(
                  offset: Offset(glitchAmount, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch_outlined, size: 36, color: Colors.redAccent.withOpacity(0.5)),
                      const SizedBox(width: 12),
                      Text('Ignition', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.redAccent.withOpacity(0.5))),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ).animate(delay: 300.ms).fadeIn(duration: 600.ms).slideY(begin: 0.5, curve: Curves.easeOutCubic);
  }
}

class CosmicTextField extends StatefulWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;

  const CosmicTextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    required this.onChanged,
    this.validator,
  });

  @override
  State<CosmicTextField> createState() => _CosmicTextFieldState();
}

class _CosmicTextFieldState extends State<CosmicTextField> with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BracketPainter(_controller),
      child: TextFormField(
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        onChanged: widget.onChanged,
        validator: widget.validator,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(widget.prefixIcon, color: Colors.white70, size: 20),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Animation<double> animation;
  _BracketPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final progress = animation.value;
    if (progress == 0) return;

    const cornerSize = 10.0;
    // Top-left
    canvas.drawLine(Offset.zero, Offset(cornerSize * progress, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, cornerSize * progress), paint);
    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerSize * progress, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize * progress), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize * progress, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerSize * progress), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerSize * progress, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize * progress), paint);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) => false;
}

class ShockwaveButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ShockwaveButton({super.key, required this.child, this.onTap});

  @override
  State<ShockwaveButton> createState() => _ShockwaveButtonState();
}

class _ShockwaveButtonState extends State<ShockwaveButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShockwavePainter(_controller),
      child: ShineButton(
        onTap: _handleTap,
        child: widget.child,
      ),
    );
  }
}

class _ShockwavePainter extends CustomPainter {
  final Animation<double> animation;
  _ShockwavePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0) return;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(1.0 - animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + animation.value * 4;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(animation.value * 20), const Radius.circular(16)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShockwavePainter oldDelegate) => false;
}

class ShineButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ShineButton({super.key, required this.child, this.onTap});

  @override
  State<ShineButton> createState() => _ShineButtonState();
}

class _ShineButtonState extends State<ShineButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.purple.withOpacity(0.5),
        highlightColor: Colors.cyan.withOpacity(0.3),
        child: Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(MediaQuery.of(context).size.width * _controller.value * 2 - MediaQuery.of(context).size.width, 0),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.0)],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuroraCard extends StatefulWidget {
  final Widget child;
  final ValueNotifier<Offset> mousePosition;
  const AuroraCard({super.key, required this.child, required this.mousePosition});

  @override
  State<AuroraCard> createState() => _AuroraCardState();
}

class _AuroraCardState extends State<AuroraCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2), lowerBound: 0.98)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) => Transform.scale(scale: _pulseController.value, child: child),
      child: ValueListenableBuilder<Offset>(
        valueListenable: widget.mousePosition,
        builder: (context, mousePos, child) {
          return CustomPaint(
            painter: _AuroraPainter(mousePos),
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(25),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final Offset mousePosition;
  _AuroraPainter(this.mousePosition);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // This painter now needs the global position of the card to correctly calculate the angle
    // For simplicity, we'll assume the card is centered for this effect.
    // A more robust solution would use a GlobalKey to get the exact position.
    final globalMousePos = mousePosition;
    final cardCenter = size.center(Offset.zero);

    final angle = atan2(globalMousePos.dy - cardCenter.dy, globalMousePos.dx - cardCenter.dx);

    final paint = Paint()
      ..shader = SweepGradient(
        colors: const [Colors.cyanAccent, Colors.purpleAccent, Colors.cyanAccent],
        stops: const [0.0, 0.5, 1.0],
        center: Alignment.center,
        transform: GradientRotation(angle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(25)), paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => oldDelegate.mousePosition != mousePosition;
}

class AnimatedCosmicBackground extends StatefulWidget {
  final ValueNotifier<Offset> mousePosition;
  const AnimatedCosmicBackground({super.key, required this.mousePosition});

  @override
  State<AnimatedCosmicBackground> createState() => _AnimatedCosmicBackgroundState();
}

class _AnimatedCosmicBackgroundState extends State<AnimatedCosmicBackground> with TickerProviderStateMixin {
  late final AnimationController _starController;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    // Initialize particles with a reference to the widget's size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null) {
        setState(() {
          _particles = List.generate(300, (index) => _Particle.random(size));
        });
      }
    });
    _particles = []; // Start with an empty list
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: widget.mousePosition,
      builder: (context, mousePos, child) {
        return AnimatedBuilder(
          animation: _starController,
          builder: (context, child) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(
                particles: _particles,
                animationValue: _starController.value,
                mousePos: mousePos,
              ),
            );
          },
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  final Offset mousePos;
  final Paint _paint;

  _ParticlePainter({required this.particles, required this.animationValue, required this.mousePos})
      : _paint = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Vortex
    final vortexPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.purple.withOpacity(0.01), Colors.cyan.withOpacity(0.2)],
        transform: GradientRotation(animationValue * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.5));
    canvas.drawCircle(center, size.width * 0.5, vortexPaint);

    for (final particle in particles) {
      particle.update(mousePos, size);
      _paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(particle.position, particle.radius, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

class _Particle {
  late Offset position;
  late Offset velocity;
  double radius, opacity;
  final Offset initialPosition;

  _Particle.random(Size size)
      : initialPosition = Offset(Random().nextDouble() * size.width, Random().nextDouble() * size.height),
        radius = Random().nextDouble() * 1.2 + 0.4,
        opacity = Random().nextDouble() * 0.7 + 0.3,
        velocity = Offset.zero {
    position = initialPosition;
  }

  void update(Offset mousePos, Size size) {
    final dx = position.dx - mousePos.dx;
    final dy = position.dy - mousePos.dy;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > 0.1) {
      if (distance < 100) {
        final force = (100 - distance) / 100;
        velocity += Offset(dx / distance * force * 2, dy / distance * force * 2);
      }
    }

    velocity += (initialPosition - position) * 0.01;

    velocity *= 0.95;

    position += velocity;
  }
}

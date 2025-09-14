import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutteruis/screens/login/super_nova_login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart';

enum FormState { idle, exploding, forming, interactive }

class SupernovaSignupScreen extends StatefulWidget {
  const SupernovaSignupScreen({super.key});

  @override
  State<SupernovaSignupScreen> createState() => _SupernovaSignupScreenState();
}

class _SupernovaSignupScreenState extends State<SupernovaSignupScreen> with TickerProviderStateMixin {
  late final AnimationController _formationController;
  late final AnimationController _pulseController;
  FormState _formState = FormState.idle;
  Offset _pointerPosition = Offset.zero;

  // Pre-calculated positions for the UI elements
  final Map<String, Rect> _uiBounds = {};

  @override
  void initState() {
    super.initState();
    _formationController = AnimationController(vsync: this, duration: 2500.ms)..addStatusListener(_onFormationAnimationStatusChanged);
    _pulseController = AnimationController(vsync: this, duration: 2.seconds)..repeat(reverse: true);
  }

  void _onFormationAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _formState = FormState.interactive);
    }
  }

  @override
  void dispose() {
    _formationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _ignite() {
    if (_formState == FormState.idle) {
      setState(() => _formState = FormState.exploding);
      _formationController.forward(from: 0.0);
    }
  }

  void _calculateUiBounds(BuildContext context) {
    if (_uiBounds.isNotEmpty) return;
    final size = MediaQuery.of(context).size;
    final center = size.center(Offset.zero);
    const fieldWidth = 320.0;
    const fieldHeight = 55.0;
    _uiBounds['email'] = Rect.fromCenter(center: center - const Offset(0, 80), width: fieldWidth, height: fieldHeight);
    _uiBounds['password'] = Rect.fromCenter(center: center, width: fieldWidth, height: fieldHeight);
    _uiBounds['confirm'] = Rect.fromCenter(center: center + const Offset(0, 80), width: fieldWidth, height: fieldHeight);
    _uiBounds['button'] = Rect.fromCenter(center: center + const Offset(0, 165), width: fieldWidth, height: fieldHeight);
  }

  @override
  Widget build(BuildContext context) {
    _calculateUiBounds(context);

    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFF000005),
        body: MouseRegion(
          onHover: (e) => setState(() => _pointerPosition = e.localPosition),
          onExit: (e) => setState(() => _pointerPosition = Offset.zero),
          child: GestureDetector(
            onPanUpdate: (d) => setState(() => _pointerPosition = d.localPosition),
            onPanEnd: (d) => setState(() => _pointerPosition = Offset.zero),
            child: Stack(
              children: [
                // The main particle system and nebula painter
                CustomPaint(
                  painter: _SupernovaPainter(
                    formState: _formState,
                    animation: _formationController,
                    pulseAnimation: _pulseController,
                    pointerPosition: _pointerPosition,
                    uiBounds: _uiBounds,
                  ),
                  child: Container(),
                ),

                // The actual form widgets (invisible until interactive)
                if (_formState == FormState.interactive)
                  _InteractiveForm(uiBounds: _uiBounds),

                // The initial "Ignite" button
                if (_formState == FormState.idle)
                  Center(
                    child: _IgniteButton(
                      animation: _pulseController,
                      onPressed: _ignite,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InteractiveForm extends StatelessWidget {
  final Map<String, Rect> uiBounds;
  const _InteractiveForm({required this.uiBounds});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return Form(
      key: provider.formKey,
      child: Stack(
        children: [
          Positioned.fromRect(
            rect: uiBounds['email']!,
            child: _TransparentTextField(
              onChanged: (v) => provider.email = v,
              hintText: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Please enter a valid email';
                return null;
              },
            ),
          ),
          Positioned.fromRect(
            rect: uiBounds['password']!,
            child: _PasswordTextField(onChanged: (v) => provider.password = v),
          ),
          Positioned.fromRect(
            rect: uiBounds['confirm']!,
            child: _ConfirmPasswordTextField(onChanged: (v) => provider.confirmPassword = v),
          ),
          Positioned.fromRect(
            rect: uiBounds['button']!,
            child: _SubmitButton(),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SupernovaLoginScreen()),
                );
              },
              child: const Text('Already have an account? Log In', style: TextStyle(color: Colors.white54)),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }
}

class _PasswordTextField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _PasswordTextField({required this.onChanged});

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return _TransparentTextField(
      onChanged: widget.onChanged,
      hintText: 'Password',
      obscureText: _isObscured,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter your password';
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      },
      suffixIcon: IconButton(
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _ConfirmPasswordTextField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _ConfirmPasswordTextField({required this.onChanged});

  @override
  State<_ConfirmPasswordTextField> createState() => _ConfirmPasswordTextFieldState();
}

class _ConfirmPasswordTextFieldState extends State<_ConfirmPasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return _TransparentTextField(
      onChanged: widget.onChanged,
      hintText: 'Confirm Password',
      obscureText: _isObscured,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please confirm your password';
        if (v != provider.password) return 'Passwords do not match';
        return null;
      },
      suffixIcon: IconButton(
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _TransparentTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _TransparentTextField({
    required this.onChanged,
    required this.hintText,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      cursorColor: Colors.cyanAccent,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white24),
        border: InputBorder.none,
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();
    return GestureDetector(
      onTap: () {
        final form = provider.formKey.currentState;
        if (form != null && form.validate()) {
          provider.signUp(context);
        }
      },
      child: Center(
        child: provider.isLoading
            ? const _LoadingCore()
            : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _LoadingCore extends StatefulWidget {
  const _LoadingCore();

  @override
  State<_LoadingCore> createState() => _LoadingCoreState();
}

class _LoadingCoreState extends State<_LoadingCore> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: 2.seconds)..repeat();
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
        return CustomPaint(
          painter: _NexusCorePainter(animationValue: _controller.value),
          size: const Size(28, 28),
        );
      },
    );
  }
}

class _IgniteButton extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onPressed;

  const _IgniteButton({required this.animation, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final eased = Curves.easeInOut.transform(animation.value);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5 + eased * 0.2),
                  blurRadius: 15 + eased * 15,
                ),
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.5 + (1 - eased) * 0.2),
                  blurRadius: 15 + (1 - eased) * 15,
                ),
              ],
            ),
            child: const Text('Start', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
          );
        },
      ),
    );
  }
}

class _SupernovaPainter extends CustomPainter {
  final FormState formState;
  final Animation<double> animation;
  final Animation<double> pulseAnimation;
  final Offset pointerPosition;
  final Map<String, Rect> uiBounds;
  final List<_Particle> particles;
  final Random _random = Random(123);
  final Paint _nebulaPaint = Paint();

  _SupernovaPainter({
    required this.formState,
    required this.animation,
    required this.pulseAnimation,
    required this.pointerPosition,
    required this.uiBounds,
  }) : particles = List.generate(400, (i) => _Particle(seed: i)); // Consider reducing to 200 for performance

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Draw Nebula
    _nebulaPaint.shader = RadialGradient(
      center: Alignment.center,
      colors: const [Color(0xFF2E0749), Color(0xFF000005)],
      radius: 1.5,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _nebulaPaint);

    final t = Curves.easeInOut.transform(animation.value);

    if (formState == FormState.idle) {
      final eased = Curves.easeInOut.transform(pulseAnimation.value);
      final corePaint = Paint()..color = Colors.white;
      final glowPaint = Paint()..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + eased * 15);
      glowPaint.shader = const RadialGradient(colors: [Colors.purple, Colors.cyan]).createShader(Rect.fromCircle(center: center, radius: 10));
      canvas.drawCircle(center, 10, glowPaint);
      canvas.drawCircle(center, 3, corePaint);
    }

    for (var p in particles) {
      final startPos = p.getStartPosition(size);

      // Explosion phase
      final explosionT = (t * 2).clamp(0.0, 1.0);
      final explodedPos = Offset.lerp(center, startPos, explosionT)!;

      // Formation phase
      final formationT = (t - 0.5).clamp(0.0, 0.5) * 2;
      final endPos = p.getEndPosition(uiBounds);
      final finalPos = Offset.lerp(explodedPos, endPos, formationT)!;

      // Interactive phase
      Offset repelOffset = Offset.zero;
      if (formState == FormState.interactive && pointerPosition != Offset.zero) {
        final vector = finalPos - pointerPosition;
        final distance = vector.distance;
        if (distance < 100 && distance > 0) {
          final repelFactor = (1 - (distance / 100));
          repelOffset = (vector / distance) * repelFactor * 15.0;
        }
      }
      final interactivePos = finalPos + repelOffset;

      final paint = Paint()..color = p.color.withOpacity(1.0 - formationT);
      if (formState == FormState.interactive) {
        final distance = (pointerPosition - finalPos).distance;
        final activation = (1 - (distance / 100).clamp(0.0, 1.0));
        paint.color = p.color.withOpacity(0.5 + activation * 0.5);
      }

      canvas.drawCircle(interactivePos, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SupernovaPainter oldDelegate) => true;
}

class _Particle {
  final int seed;
  final double radius;
  final Color color;
  final String assignedRect;

  _Particle({required this.seed})
      : radius = Random(seed).nextDouble() * 1.5 + 0.5,
        color = [Colors.purple.shade200, Colors.pink.shade200, Colors.cyan.shade200][Random(seed).nextInt(3)],
        assignedRect = ['email', 'password', 'confirm', 'button'][Random(seed).nextInt(4)];

  Offset getStartPosition(Size size) {
    final random = Random(seed);
    final angle = random.nextDouble() * 2 * pi;
    final radius = size.width / 2 + random.nextDouble() * 100;
    return Offset(size.width / 2 + cos(angle) * radius, size.height / 2 + sin(angle) * radius);
  }

  Offset getEndPosition(Map<String, Rect> uiBounds) {
    final random = Random(seed);
    final rect = uiBounds[assignedRect]!;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2));
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    return metrics.getTangentForOffset(random.nextDouble() * metrics.length)!.position;
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

    paint.strokeWidth = 1.0;
    paint.color = Colors.white.withOpacity(1.0 - eased);
    canvas.drawCircle(center, size.width / 2 * eased, paint);

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
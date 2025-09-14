// lib/screens/signup/liquid_metal_signup_screen.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart'; // Your original provider

// InheritedWidget to provide pointer position to all children efficiently.
class PointerProvider extends InheritedWidget {
  final Offset pointerPosition;
  const PointerProvider({
    super.key,
    required this.pointerPosition,
    required super.child,
  });

  static Offset of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PointerProvider>()!.pointerPosition;
  }

  @override
  bool updateShouldNotify(PointerProvider oldWidget) => oldWidget.pointerPosition != pointerPosition;
}


class LiquidMetalSignupScreen extends StatefulWidget {
  const LiquidMetalSignupScreen({super.key});

  @override
  State<LiquidMetalSignupScreen> createState() => _LiquidMetalSignupScreenState();
}

class _LiquidMetalSignupScreenState extends State<LiquidMetalSignupScreen> {
  Offset _pointerPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Initialize pointer to the center for a default startup look
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() => _pointerPosition = Offset(size.width / 2, size.height * 0.4));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: MouseRegion(
        onHover: (event) => setState(() => _pointerPosition = event.position),
        child: GestureDetector(
          onPanUpdate: (details) => setState(() => _pointerPosition = details.globalPosition),
          child: PointerProvider(
            pointerPosition: _pointerPosition,
            child: const Scaffold(
              backgroundColor: Color(0xFF121418),
              body: Stack(
                children: [
                  _BokehBackground(),
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: _SignupForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupForm extends StatelessWidget {
  const _SignupForm();

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
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.grey[200]),
          ),
          const SizedBox(height: 8),
          Text(
            'Shape your digital presence.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 60),
          _LiquidTextField(
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => provider.email = value,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email cannot be empty';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 24),
          _PasswordTextField(),
          const SizedBox(height: 24),
          _ConfirmPasswordTextField(),
          const SizedBox(height: 40),
          const _LiquidButton(),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {},
            child: Text('Already have an account? Log In', style: TextStyle(color: Colors.grey[400])),
          ),
        ],
      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic),
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
    return _LiquidTextField(
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
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[600]),
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
    return _LiquidTextField(
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
        icon: Icon(_isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey[600]),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _LiquidTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isObscured;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _LiquidTextField({
    required this.label, required this.icon, required this.onChanged,
    this.validator, this.isObscured = false, this.keyboardType, this.suffix,
  });

  @override
  State<_LiquidTextField> createState() => _LiquidTextFieldState();
}

class _LiquidTextFieldState extends State<_LiquidTextField> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _globalKey = GlobalKey();
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
    return CustomPaint(
      key: _globalKey,
      painter: _LiquidPainter(
        isFocused: _isFocused,
        pointerPosition: PointerProvider.of(context),
        renderBox: () => _globalKey.currentContext?.findRenderObject() as RenderBox?,
      ),
      child: TextFormField(
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        validator: widget.validator,
        obscureText: widget.isObscured,
        keyboardType: widget.keyboardType,
        cursorColor: Colors.grey[300],
        style: TextStyle(color: Colors.grey[200]),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: Colors.grey[500]),
          floatingLabelStyle: TextStyle(color: Colors.grey[300]),
          prefixIcon: Icon(widget.icon, color: Colors.grey[600]),
          suffixIcon: widget.suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

class _LiquidButton extends StatefulWidget {
  const _LiquidButton();

  @override
  State<_LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<_LiquidButton> with TickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();
  late final AnimationController _loadingController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

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
        duration: const Duration(milliseconds: 200),
        curve: Curves.elasticOut,
        child: CustomPaint(
          key: _globalKey,
          painter: _LiquidPainter(
            isFocused: true,
            isButton: true,
            loadingValue: provider.isLoading ? _loadingController.value : null,
            pointerPosition: PointerProvider.of(context),
            renderBox: () => _globalKey.currentContext?.findRenderObject() as RenderBox?,
          ),
          child: SizedBox(
            height: 55,
            child: Center(
              child: provider.isLoading
                  ? null
                  : Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[200])),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final bool isFocused;
  final bool isButton;
  final Offset pointerPosition;
  final RenderBox? Function() renderBox;
  final double? loadingValue;

  _LiquidPainter({
    required this.isFocused,
    required this.pointerPosition,
    required this.renderBox,
    this.isButton = false,
    this.loadingValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shapeBounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final shapePath = Path()..addRRect(RRect.fromRectAndRadius(shapeBounds, const Radius.circular(12)));
    canvas.clipPath(shapePath);

    // Base Layer
    final basePaint = Paint()..color = const Color(0xFF1A1D23);
    canvas.drawRect(shapeBounds, basePaint);

    // Loading animation
    if (loadingValue != null) {
      final vortexPaint = Paint();
      final center = shapeBounds.center;
      final angle = loadingValue! * 2 * pi;
      vortexPaint.shader = SweepGradient(
        center: Alignment.center,
        colors: const [Color(0xFF333842), Color(0xFF4C525E), Color(0xFF333842)],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(angle),
      ).createShader(shapeBounds);
      canvas.drawRect(shapeBounds, vortexPaint);
    }

    // Dynamic Glare
    final box = renderBox();
    if (box != null && box.hasSize) {
      final globalPosition = box.localToGlobal(Offset.zero);
      final localPointer = pointerPosition - globalPosition;
      final glarePaint = Paint();
      final glareRadius = size.width * 0.8;
      glarePaint.shader = RadialGradient(
        center: Alignment(
          (localPointer.dx / size.width * 2) - 1,
          (localPointer.dy / size.height * 2) - 1,
        ),
        radius: 1.0,
        colors: const [Color(0x1AFFFFFF), Colors.transparent],
      ).createShader(shapeBounds);
      canvas.drawRect(shapeBounds, glarePaint);
    }

    // Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFocused ? 2.5 : 1.5
      ..color = isButton
          ? const Color(0xFF4C525E)
          : (isFocused ? const Color(0xFF4C525E) : const Color(0xFF333842));
    canvas.drawRRect(RRect.fromRectAndRadius(shapeBounds.deflate(borderPaint.strokeWidth / 2), const Radius.circular(12)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) {
    return oldDelegate.isFocused != isFocused ||
        oldDelegate.pointerPosition != pointerPosition ||
        oldDelegate.loadingValue != loadingValue;
  }
}

// Custom Background
class _BokehBackground extends StatefulWidget {
  const _BokehBackground();
  @override
  State<_BokehBackground> createState() => _BokehBackgroundState();
}

class _BokehBackgroundState extends State<_BokehBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_BokehParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
    _particles = List.generate(25, (index) => _createParticle());
  }

  _BokehParticle _createParticle() {
    return _BokehParticle(
      color: Colors.primaries[_random.nextInt(Colors.primaries.length)].withOpacity(_random.nextDouble() * 0.1 + 0.05),
      startPosition: Offset(_random.nextDouble(), _random.nextDouble()),
      endPosition: Offset(_random.nextDouble(), _random.nextDouble()),
      radius: _random.nextDouble() * 100 + 50,
      startTime: _random.nextDouble(),
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
        return CustomPaint(
          painter: _BokehPainter(particles: _particles, animationValue: _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class _BokehPainter extends CustomPainter {
  final List<_BokehParticle> particles;
  final double animationValue;
  _BokehPainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final relativeTime = (animationValue - particle.startTime + 1.0) % 1.0;
      final position = Offset.lerp(particle.startPosition, particle.endPosition, relativeTime)!;
      final paint = Paint()
        ..color = particle.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.radius * 0.5);
      canvas.drawCircle(Offset(position.dx * size.width, position.dy * size.height), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BokehPainter oldDelegate) => true;
}

class _BokehParticle {
  final Color color;
  final Offset startPosition;
  final Offset endPosition;
  final double radius;
  final double startTime;
  _BokehParticle({
    required this.color, required this.startPosition, required this.endPosition,
    required this.radius, required this.startTime,
  });
}
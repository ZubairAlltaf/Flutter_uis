// lib/screens/signup/neural_grid_signup_screen.dart
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors; // FIXED: Added this import
import '../../providers/signup_provider.dart'; // Your original provider

class NeuralGridSignupScreen extends StatelessWidget {
  const NeuralGridSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: const Scaffold(
        backgroundColor: Color(0xFF010413),
        body: Stack(
          children: [
            _NeuralGridBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: _SignupForm(),
                ),
              ),
            ),
          ],
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
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.cyanAccent.withOpacity(0.5), blurRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Initiate your access protocol.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'monospace', fontSize: 16, color: Colors.cyan.withOpacity(0.7)),
          ),
          const SizedBox(height: 50),
          _GridTextField(
            label: 'Email Address',
            icon: Icons.alternate_email,
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
          const _GridActionButton(),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {},
            child: Text(
              'Existing User? Authenticate',
              style: TextStyle(color: Colors.cyanAccent.withOpacity(0.8), fontWeight: FontWeight.w600),
            ),
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
    return _GridTextField(
      label: 'Password',
      icon: Icons.vpn_key_outlined,
      isObscured: _isObscured,
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
  @override
  _ConfirmPasswordTextFieldState createState() => _ConfirmPasswordTextFieldState();
}

class _ConfirmPasswordTextFieldState extends State<_ConfirmPasswordTextField> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignupProvider>();
    return _GridTextField(
      label: 'Confirm Password',
      icon: Icons.lock_reset,
      isObscured: _isObscured,
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

class _GridTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isObscured;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _GridTextField({
    required this.label, required this.icon, required this.onChanged,
    this.validator, this.isObscured = false, this.keyboardType, this.suffix,
  });

  @override
  State<_GridTextField> createState() => _GridTextFieldState();
}

class _GridTextFieldState extends State<_GridTextField> {
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
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused ? Colors.cyanAccent : Colors.cyan.withOpacity(0.2),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused ? [
              BoxShadow(color: Colors.cyanAccent.withOpacity(0.1), blurRadius: 12),
            ] : [],
          ),
          child: TextFormField(
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            validator: widget.validator,
            obscureText: widget.isObscured,
            keyboardType: widget.keyboardType,
            cursorColor: Colors.cyanAccent,
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(color: _isFocused ? Colors.white : Colors.blueGrey[300]),
              floatingLabelStyle: const TextStyle(color: Colors.cyanAccent),
              prefixIcon: Icon(widget.icon, color: _isFocused ? Colors.cyanAccent : Colors.blueGrey[300]),
              suffixIcon: widget.suffix,
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridActionButton extends StatefulWidget {
  const _GridActionButton();
  @override
  State<_GridActionButton> createState() => _GridActionButtonState();
}

class _GridActionButtonState extends State<_GridActionButton> with TickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();
    return GestureDetector(
      onTap: provider.isLoading ? null : () => provider.signUp(context),
      child: Container(
        height: 55,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.cyan,
          boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))],
        ),
        child: provider.isLoading
            ? AnimatedBuilder(
          animation: _scanController,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.8,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.cyan,
                            Colors.cyanAccent.withOpacity(0.8),
                            Colors.cyan,
                          ],
                          stops: [
                            _scanController.value - 0.4,
                            _scanController.value,
                            _scanController.value + 0.4,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Center(child: Text("PROCESSING...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
              ],
            );
          },
        )
            : const Center(
          child: Text(
            'Create Account',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF010413)),
          ),
        ),
      ),
    );
  }
}

// Custom Background
class _NeuralGridBackground extends StatefulWidget {
  const _NeuralGridBackground();
  @override
  State<_NeuralGridBackground> createState() => _NeuralGridBackgroundState();
}

class _NeuralGridBackgroundState extends State<_NeuralGridBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  Offset _pointerPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() => _pointerPosition = event.localPosition),
      onExit: (event) => setState(() => _pointerPosition = Offset.zero),
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _pointerPosition = details.localPosition),
        onPanEnd: (details) => setState(() => _pointerPosition = Offset.zero),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _NeuralGridPainter(
                animationValue: _controller.value,
                pointerPosition: _pointerPosition,
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

class _NeuralGridPainter extends CustomPainter {
  final double animationValue;
  final Offset pointerPosition;
  final int gridSpacing = 35;
  // FIXED: 'nodeCount' is now static const to be accessible in the initializer
  static const int nodeCount = 40;
  final List<Point<double>> nodes;
  final Random random;

  _NeuralGridPainter({required this.animationValue, required this.pointerPosition})
      : random = Random(1),
        nodes = List.generate(
          nodeCount,
              (i) => Point(Random(i).nextDouble(), Random(i + nodeCount).nextDouble()),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 0.5;
    final perspectiveMatrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateX(0.9)
      ..translate(-size.width / 2, -size.height * 1.2)
      ..scale(2.5);

    // Draw grid lines
    for (var i = 0; i < size.width / gridSpacing; i++) {
      // FIXED: Using the Vector3 class from the imported package
      final p1 = perspectiveMatrix.transform3(Vector3(i.toDouble() * gridSpacing, 0, 0));
      final p2 = perspectiveMatrix.transform3(Vector3(i.toDouble() * gridSpacing, size.height, 0));
      final p3 = perspectiveMatrix.transform3(Vector3(0, i.toDouble() * gridSpacing, 0));
      final p4 = perspectiveMatrix.transform3(Vector3(size.width, i.toDouble() * gridSpacing, 0));

      final pointerGlow = _getGlowFactor(Offset(p1.x, p1.y));
      paint.color = Color.lerp(const Color(0xFF031A3D), Colors.cyanAccent, pointerGlow)!;

      canvas.drawLine(Offset(p1.x, p1.y), Offset(p2.x, p2.y), paint);
      canvas.drawLine(Offset(p3.x, p3.y), Offset(p4.x, p4.y), paint);
    }

    // Draw nodes and connections
    for (var i = 0; i < nodeCount; i++) {
      final nodePos = Offset(nodes[i].x * size.width, nodes[i].y * size.height);
      final p = perspectiveMatrix.transform3(Vector3(nodePos.dx, nodePos.dy, 0));
      final screenPos = Offset(p.x, p.y);
      final pointerGlow = _getGlowFactor(screenPos);
      final pulse = sin((animationValue * 2 * pi) + (i * pi / 4)) / 2 + 0.5;

      // Draw connections
      final nextNodeIndex = (i + 5) % nodeCount;
      final nextNodePos = Offset(nodes[nextNodeIndex].x * size.width, nodes[nextNodeIndex].y * size.height);
      final pNext = perspectiveMatrix.transform3(Vector3(nextNodePos.dx, nextNodePos.dy, 0));
      final nextScreenPos = Offset(pNext.x, pNext.y);

      final linePaint = Paint()
        ..color = Color.lerp(const Color(0x80046A8D), Colors.cyan, pointerGlow)!.withOpacity(pulse * 0.5)
        ..strokeWidth = 1.0;
      canvas.drawLine(screenPos, nextScreenPos, linePaint);

      // Draw nodes
      final nodePaint = Paint()..color = Color.lerp(Colors.cyan, Colors.white, pulse)!.withOpacity(pointerGlow > 0.1 ? 1.0 : pulse);
      canvas.drawCircle(screenPos, (2.0 * pulse) + (4 * pointerGlow), nodePaint);
    }
  }

  double _getGlowFactor(Offset position) {
    if (pointerPosition == Offset.zero) return 0.0;
    final distance = (position - pointerPosition).distance;
    final glow = 1.0 - (distance / 200).clamp(0.0, 1.0);
    return glow * glow; // Use squared value for a sharper falloff
  }

  @override
  bool shouldRepaint(covariant _NeuralGridPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue || oldDelegate.pointerPosition != pointerPosition;
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../providers/login_provider.dart';

// Helper classes for the Neural Matrix background (Unchanged)
class _Neuron {
  Offset position;
  final List<int> connections = [];
  _Neuron(this.position);
}

class _Pulse {
  final int fromNode;
  final int toNode;
  final double startTime;
  final Duration duration;
  Color color;
  _Pulse(this.fromNode, this.toNode, this.startTime, this.duration, this.color);
}

class QuantumGateLoginScreen extends StatefulWidget {
  const QuantumGateLoginScreen({super.key});

  @override
  State<QuantumGateLoginScreen> createState() => _QuantumGateLoginScreenState();
}

class _QuantumGateLoginScreenState extends State<QuantumGateLoginScreen> with TickerProviderStateMixin {
  bool _obscurePassword = true;
  late final AnimationController _matrixController;

  final List<_Neuron> _neurons = [];
  final List<_Pulse> _pulses = [];
  final int _neuronCount = 35;

  @override
  void initState() {
    super.initState();
    _matrixController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Generate the neural network structure once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNeuralNetwork(MediaQuery.of(context).size);
      setState(() {});
    });
  }

  void _initializeNeuralNetwork(Size size) {
    final random = math.Random();
    for (int i = 0; i < _neuronCount; i++) {
      _neurons.add(_Neuron(Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      )));
    }
    for (int i = 0; i < _neuronCount; i++) {
      for (int j = i + 1; j < _neuronCount; j++) {
        final distance = (_neurons[i].position - _neurons[j].position).distance;
        if (distance < size.width * 0.3) {
          _neurons[i].connections.add(j);
        }
      }
    }
    for (int i = 0; i < _neuronCount * 1.5; i++) {
      final startNode = random.nextInt(_neurons.length);
      if (_neurons[startNode].connections.isEmpty) continue;
      final endNode = _neurons[startNode].connections[random.nextInt(_neurons[startNode].connections.length)];
      _pulses.add(_Pulse(
        startNode,
        endNode,
        random.nextDouble() * _matrixController.duration!.inSeconds,
        (1600 + random.nextInt(1000)).milliseconds,
        random.nextBool() ? const Color(0xFF9f00ff) : const Color(0xFF00d5ff),
      ));
    }
  }

  @override
  void dispose() {
    _matrixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF02001E),
      body: Stack(
        children: [
          _buildMatrixBackground(),
          Center(
            child: Animate(
              effects: [
                FadeEffect(duration: 800.ms, delay: 200.ms),
                ScaleEffect(begin: const Offset(0.95, 0.95), curve: Curves.easeOutCubic),
              ],
              child: _buildHolographicInterface(provider),
            ),
          ),
          _footerSignature(),
        ],
      ),
    );
  }

  // ----------- UI WIDGETS & COMPONENTS ------------

  Widget _buildMatrixBackground() {
    return AnimatedBuilder(
      animation: _matrixController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _NeuralMatrixPainter(
            neurons: _neurons,
            pulses: _pulses,
            animationValue: _matrixController.value,
            controller: _matrixController,
          ),
        );
      },
    );
  }

  Widget _buildHolographicInterface(LoginProvider provider) {
    // The core of the new design. A CustomPaint that projects the UI.
    return CustomPaint(
      painter: _HolographicInterfacePainter(animation: _matrixController),
      child: Container(
        width: 380,
        height: 450,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Form(
          key: provider.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuantumHeader(),
              const Spacer(),
              _buildTextField("Neural ID", (val) => provider.email = val,
                      (val) => val!.isEmpty ? 'Neural ID is required.' : null),
              const SizedBox(height: 25),
              _buildPasswordField(provider),
              const SizedBox(height: 45),
              _buildLoginButton(provider),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantumHeader() {
    return Column(
      children: [
        const Icon(Icons.hub_outlined, color: Color(0xFF00D5FF), size: 40),
        const SizedBox(height: 12),
        Text(
          'QuantumGate',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFF7DF9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
            shadows: const [Shadow(color: Color(0xFF00D5FF), blurRadius: 15)],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, curve: Curves.easeOut);
  }

  Widget _buildTextField(
      String hint,
      void Function(String) onChanged,
      String? Function(String?) validator,
      ) {
    return TextFormField(
      style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.8),
      decoration: _inputDecoration(hint),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildPasswordField(LoginProvider provider) {
    return TextFormField(
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 0.8),
      decoration: _inputDecoration("Access Key").copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF00D5FF).withOpacity(0.7),
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      onChanged: (val) => provider.password = val,
      validator: (val) => val!.length < 6 ? 'Access Key strength is insufficient.' : null,
    );
  }

  Widget _buildLoginButton(LoginProvider provider) {
    return Animate(
      effects: [FadeEffect(delay: 400.ms), SlideEffect(begin: const Offset(0, 0.5))],
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : () => provider.login(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero, // Remove padding to allow custom inner container
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0xFF00D5FF).withOpacity(0.8), width: 1.5),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00D5FF).withOpacity(0.1),
                const Color(0xFF0077FF).withOpacity(0.2),
              ],
            ),
          ),
          child: Container(
            height: 55,
            alignment: Alignment.center,
            child: provider.isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
                : const Text(
              "INTERFACE",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), letterSpacing: 0.8),
      // NO fill color for holographic effect
      filled: false,
      // Using Underline border for a cleaner, projected look
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: const Color(0xFF00D5FF).withOpacity(0.4)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF7DF9FF), width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFF5555)),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFF5555), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
    );
  }

  Widget _footerSignature() {
    return Positioned(
      bottom: 15, left: 0, right: 0,
      child: Center(
        child: Text(
          "//Zubair Dev",
          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
        ).animate().fadeIn(duration: 2.seconds).slideY(begin: 0.5),
      ),
    );
  }
}

class _HolographicInterfacePainter extends CustomPainter {
  final Animation<double> animation;
  final Paint _framePaint = Paint()..strokeWidth = 2.5..strokeCap = StrokeCap.round;
  final Paint _scanLinePaint = Paint();
  final Paint _gridPaint = Paint()..strokeWidth = 0.5;

  _HolographicInterfacePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final frameColor = const Color(0xFF00D5FF).withOpacity(0.8);
    _framePaint.color = frameColor;
    _gridPaint.color = frameColor.withOpacity(0.1);

    // 1. Draw Corner Brackets to define the projection area
    const cornerSize = 25.0;
    // Top-left
    canvas.drawLine(const Offset(0, cornerSize), const Offset(0, 0), _framePaint);
    canvas.drawLine(const Offset(0, 0), const Offset(cornerSize, 0), _framePaint);
    // Top-right
    canvas.drawLine(Offset(size.width - cornerSize, 0), Offset(size.width, 0), _framePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), _framePaint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - cornerSize), Offset(0, size.height), _framePaint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), _framePaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - cornerSize, size.height), Offset(size.width, size.height), _framePaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize), _framePaint);

    // 2. Draw subtle background grid lines
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), _gridPaint);
    }

    // 3. Draw the animated scan line
    final scanY = size.height * (math.sin(animation.value * 2 * math.pi * 3) * 0.5 + 0.5); // Fast oscillation
    final scanRect = Rect.fromLTWH(0, scanY, size.width, 40);
    _scanLinePaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, frameColor.withOpacity(0.5), Colors.transparent],
    ).createShader(scanRect);
    canvas.drawRect(scanRect, _scanLinePaint);

    // 4. Draw a subtle outer glow for the entire projection
    final glowPaint = Paint()..maskFilter = MaskFilter.blur(BlurStyle.outer, 8);
    glowPaint.shader = LinearGradient(
      colors: [frameColor.withOpacity(0.3), Colors.transparent],
      stops: const [0.0, 0.5],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(covariant _HolographicInterfacePainter oldDelegate) => false;
}

// Custom Painter for the Neural Matrix Background (Unchanged)
class _NeuralMatrixPainter extends CustomPainter {
  final List<_Neuron> neurons;
  final List<_Pulse> pulses;
  final double animationValue;
  final AnimationController controller;

  final Paint _linePaint = Paint()
    ..color = const Color(0xFF00D5FF).withOpacity(0.1)
    ..strokeWidth = 1;
  final Paint _neuronPaint = Paint()..color = const Color(0xFF00D5FF);
  final Paint _pulsePaint = Paint()..strokeCap = StrokeCap.round;

  _NeuralMatrixPainter({required this.neurons, required this.pulses, required this.animationValue, required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    if(neurons.isEmpty) return;
    for (final neuron in neurons) {
      for (final connectionIndex in neuron.connections) {
        canvas.drawLine(neuron.position, neurons[connectionIndex].position, _linePaint);
      }
    }
    for (final neuron in neurons) {
      final glowPaint = Paint()..shader = RadialGradient(colors: [
        const Color(0xFF00D5FF).withOpacity(0.3),
        Colors.transparent
      ]).createShader(Rect.fromCircle(center: neuron.position, radius: 8));
      canvas.drawCircle(neuron.position, 8, glowPaint);
      canvas.drawCircle(neuron.position, 1.5, _neuronPaint);
    }
    final currentTime = controller.duration!.inSeconds * animationValue;
    for(final pulse in pulses) {
      final pulseEndTime = pulse.startTime + pulse.duration.inMilliseconds / 1000.0;
      if(currentTime >= pulse.startTime && currentTime <= pulseEndTime) {
        final progress = (currentTime - pulse.startTime) / (pulse.duration.inMilliseconds / 1000.0);
        final currentPos = Offset.lerp(
          neurons[pulse.fromNode].position,
          neurons[pulse.toNode].position,
          Curves.easeOut.transform(progress),
        )!;
        final pulseGlow = Paint()..shader = RadialGradient(colors: [
          pulse.color.withOpacity(0.8),
          Colors.transparent
        ]).createShader(Rect.fromCircle(center: currentPos, radius: 10));
        canvas.drawCircle(currentPos, 10, pulseGlow);
        _pulsePaint.color = pulse.color;
        canvas.drawCircle(currentPos, 2.5, _pulsePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
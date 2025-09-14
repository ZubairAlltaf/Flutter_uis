// lib/screens/signup/projected_light_signup_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart'; // Your original provider

// Helper InheritedWidget to provide the pointer position to all children
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
  bool updateShouldNotify(PointerProvider oldWidget) {
    return oldWidget.pointerPosition != pointerPosition;
  }
}

class ProjectedLightSignupScreen extends StatefulWidget {
  const ProjectedLightSignupScreen({super.key});

  @override
  State<ProjectedLightSignupScreen> createState() => _ProjectedLightSignupScreenState();
}

class _ProjectedLightSignupScreenState extends State<ProjectedLightSignupScreen> {
  Offset _pointerPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Initialize pointer to the center for a default startup look
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _pointerPosition = Offset(size.width / 2, size.height / 2);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(),
      child: MouseRegion(
        onHover: (event) => setState(() => _pointerPosition = event.position),
        onExit: (event) {
          final size = MediaQuery.of(context).size;
          setState(() => _pointerPosition = Offset(size.width / 2, size.height / 2));
        },
        child: GestureDetector(
          onPanUpdate: (details) => setState(() => _pointerPosition = details.globalPosition),
          onPanEnd: (details) {
            final size = MediaQuery.of(context).size;
            setState(() => _pointerPosition = Offset(size.width / 2, size.height / 2));
          },
          child: PointerProvider(
            pointerPosition: _pointerPosition,
            child: const Scaffold(
              body: Stack(
                children: [
                  _ProjectedBackground(),
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
          _DynamicShadowWidget(
            child: Text(
              'Join Zubairdev',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.grey[200],
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _DynamicShadowWidget(
            child: Text(
              'Create your account to begin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 60),
          _ProjectedTextField(
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
          const _ProjectedButton(),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {},
            child: Text(
              'Already have an account? Log In',
              style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600),
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
    return _ProjectedTextField(
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
    return _ProjectedTextField(
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

class _ProjectedTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isObscured;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _ProjectedTextField({
    required this.label, required this.icon, required this.onChanged,
    this.validator, this.isObscured = false, this.keyboardType, this.suffix,
  });

  @override
  State<_ProjectedTextField> createState() => _ProjectedTextFieldState();
}

class _ProjectedTextFieldState extends State<_ProjectedTextField> {
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
    return _DynamicShadowWidget(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: const Color(0xFF212429),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _isFocused ? Colors.grey[700]! : Colors.transparent),
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
          ),
        ),
      ),
    );
  }
}

class _ProjectedButton extends StatefulWidget {
  const _ProjectedButton();

  @override
  State<_ProjectedButton> createState() => _ProjectedButtonState();
}

class _ProjectedButtonState extends State<_ProjectedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignupProvider>();
    return _DynamicShadowWidget(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: provider.isLoading ? null : () => provider.signUp(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 55,
          transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF2C2F36),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Center(
            child: provider.isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
                : Text(
              'Create Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[200]),
            ),
          ),
        ),
      ),
    );
  }
}

class _DynamicShadowWidget extends StatefulWidget {
  final Widget child;
  const _DynamicShadowWidget({required this.child});

  @override
  State<_DynamicShadowWidget> createState() => _DynamicShadowWidgetState();
}

class _DynamicShadowWidgetState extends State<_DynamicShadowWidget> {
  final GlobalKey _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final pointerPosition = PointerProvider.of(context);
    Offset childPosition = Offset.zero;

    // Get the widget's position on screen after it's been laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_childKey.currentContext != null) {
        final renderBox = _childKey.currentContext!.findRenderObject() as RenderBox;
        final newPosition = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
        if (newPosition != childPosition) {
          setState(() {
            childPosition = newPosition;
          });
        }
      }
    });

    final shadowOffset = childPosition == Offset.zero
        ? Offset.zero
        : Offset(
      (childPosition.dx - pointerPosition.dx) / 40,
      (childPosition.dy - pointerPosition.dy) / 40,
    );

    final shadowBlur = childPosition == Offset.zero
        ? 0.0
        : (pointerPosition - childPosition).distance / 20;

    return Stack(
      children: [
        // The shadow layer
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(shadowOffset.dx, shadowOffset.dy, 0),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: shadowBlur, sigmaY: shadowBlur),
            child: Opacity(
              opacity: 0.5,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                child: widget.child,
              ),
            ),
          ),
        ),
        // The actual content
        Container(
          key: _childKey,
          child: widget.child,
        ),
      ],
    );
  }
}

class _ProjectedBackground extends StatelessWidget {
  const _ProjectedBackground();

  @override
  Widget build(BuildContext context) {
    final pointerPosition = PointerProvider.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      color: const Color(0xFF1A1C20),
      child: Stack(
        children: [
          // Base texture/vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [Colors.grey[900]!.withOpacity(0.0), Colors.black],
              ),
            ),
          ),
          // Interactive light source
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  (pointerPosition.dx / size.width * 2) - 1,
                  (pointerPosition.dy / size.height * 2) - 1,
                ),
                radius: 0.8,
                colors: [Colors.white.withOpacity(0.04), Colors.white.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
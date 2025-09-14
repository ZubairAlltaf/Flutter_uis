// lib/screens/signup/metamorph_signup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/signup_provider.dart'; // Your original provider

class MetamorphSignupScreen extends StatelessWidget {
  const MetamorphSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupProvider(), // Using your original provider
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: const _MetamorphSignupForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetamorphSignupForm extends StatelessWidget {
  const _MetamorphSignupForm();

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
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms)
              .shimmer(color: Colors.grey[300], duration: 1200.ms)
              .then()
              .shake(hz: 2, duration: 500.ms),
          Text(
            'Create your account to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
          const SizedBox(height: 60),
          _MorphTextField(
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
          const _MetamorphActionButton(),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              // TODO: Navigate to Login Screen
            },
            child: Text(
              'Already have an account? Log In',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ].animate(interval: 100.ms).slideY(begin: 0.5, duration: 500.ms, curve: Curves.easeOutCubic).fadeIn(),
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
    return _MorphTextField(
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
        icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
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
    final provider = context.watch<SignupProvider>();
    return _MorphTextField(
      label: 'Confirm Password',
      icon: Icons.lock_outline,
      isObscured: _isObscured,
      onChanged: (value) => provider.confirmPassword = value,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please confirm your password';
        if (value != provider.password) return 'Passwords do not match';
        return null;
      },
      suffix: IconButton(
        icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
        onPressed: () => setState(() => _isObscured = !_isObscured),
      ),
    );
  }
}

class _MorphTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isObscured;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _MorphTextField({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
    this.isObscured = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  State<_MorphTextField> createState() => _MorphTextFieldState();
}

class _MorphTextFieldState extends State<_MorphTextField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    _controller.addListener(() {
      if (_controller.text.isNotEmpty != _hasText) {
        setState(() => _hasText = _controller.text.isNotEmpty);
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
    final bool showLabelAbove = _isFocused || _hasText;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            )
        ],
      ),
      child: Stack(
        children: [
          // The actual text field
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            validator: widget.validator,
            obscureText: widget.isObscured,
            keyboardType: widget.keyboardType,
            cursorColor: Colors.blue.shade700,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.fromLTRB(52, 22, 48, 14),
              border: InputBorder.none,
              errorStyle: const TextStyle(height: 0), // Hide default error text
            ),
          ),
          // Animated Label
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            top: showLabelAbove ? 6 : 18,
            left: 52,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: showLabelAbove ? 12 : 16,
                color: showLabelAbove ? Colors.blue.shade700 : Colors.grey[500],
              ),
              child: Text(widget.label),
            ),
          ),
          // Icon
          Positioned(
            left: 16,
            top: 17,
            child: Icon(
              widget.icon,
              color: _isFocused ? Colors.blue.shade700 : Colors.grey[400],
            ),
          ),
          // Suffix
          if (widget.suffix != null)
            Positioned(
              right: 8,
              top: 5,
              child: widget.suffix!,
            ),
          // Animated Underline
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isFocused ? 2.0 : 1.0,
              decoration: BoxDecoration(
                color: _isFocused ? Colors.blue.shade700 : Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _MetamorphActionButton extends StatefulWidget {
  const _MetamorphActionButton();

  @override
  State<_MetamorphActionButton> createState() => _MetamorphActionButtonState();
}

class _MetamorphActionButtonState extends State<_MetamorphActionButton> {
  bool _isPressed = false;
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
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.blue.shade600,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: provider.isLoading
                ? const _LoadingDots()
                : const Text(
              'Create Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: CircleAvatar(
            radius: 4,
            backgroundColor: Colors.white,
          ).animate(delay: (index * 200).ms, onPlay: (c) => c.repeat())
              .moveY(begin: 0, end: -5, duration: 400.ms, curve: Curves.easeInOut)
              .then()
              .moveY(begin: -5, end: 0, duration: 400.ms, curve: Curves.easeInOut),
        );
      }),
    );
  }
}
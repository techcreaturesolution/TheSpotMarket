import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

enum _AuthType { email, phone }

/// Premium Liquid Glass login and authentication screen.
/// Features true glassmorphic blur refraction, specular highlights,
/// ambient emerald glow, liquid capsule inputs, and clean typography.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.allowSkip = true});
  final bool allowSkip;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _AuthType _authType = _AuthType.email;
  bool _isSignUp = false;

  // Form & Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController(text: '+91 ');
  final _otpController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _toast(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitEmail() async {  
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthService>();
    try {
      if (_isSignUp) {
        await auth.registerWithEmail(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );
        _toast('Account created successfully! Verification email sent.');
      } else {
        await auth.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      _toast(AuthService.friendly(e), isError: true);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _toast('Please enter a valid email address first.', isError: true);
      return;
    }
    try {
      await context.read<AuthService>().sendPasswordReset(email);
      _toast('Password reset link sent to $email');
    } catch (e) {
      _toast(AuthService.friendly(e), isError: true);
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.replaceAll(' ', '');
    if (!RegExp(r'^\+\d{10,15}$').hasMatch(phone)) {
      _toast('Enter valid mobile number with country code, e.g. +919876543210', isError: true);
      return;
    }
    final auth = context.read<AuthService>();
    try {
      await auth.sendOtp(phone);
      if (!mounted) return;
      if (auth.isSignedIn) {
        Navigator.of(context).maybePop();
      } else {
        _toast('OTP verification code sent to $phone');
      }
    } catch (e) {
      _toast(AuthService.friendly(e), isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) {
      _toast('Enter complete 6-digit OTP code', isError: true);
      return;
    }
    final auth = context.read<AuthService>();
    try {
      await auth.verifyOtp(
        _otpController.text.trim(),
        displayName: _nameController.text.trim(),
      );
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      _toast(AuthService.friendly(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final busy = auth.busy;

    return Scaffold(
      backgroundColor: const Color(0xFF040A07),
      body: Stack(
        children: [
          // ===================================================================
          // 1. Ambient Liquid Background (Dynamic Color Blooms for Glass Blur)
          // ===================================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF030D08), // Obsidian emerald
                    Color(0xFF071911), // Midnight forest
                    Color(0xFF020705), // Ultra deep black
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Top-left liquid emerald bloom
                  Positioned(
                    top: -60,
                    left: -40,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF10B981).withValues(alpha: 0.22),
                            const Color(0xFF059669).withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Center-right liquid mint orb
                  Positioned(
                    top: 260,
                    right: -80,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF34D399).withValues(alpha: 0.14),
                            const Color(0xFF047857).withValues(alpha: 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom-left subtle deep teal aura
                  Positioned(
                    bottom: -50,
                    left: -50,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF10B981).withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // 2. Main Content
          // ===================================================================
          SafeArea(
            child: Column(
              children: [
                // Clean Top Bar (Icons removed as requested, clean header title only)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Center(
                    child: Text(
                      _authType == _AuthType.phone
                          ? 'Mobile OTP'
                          : (_isSignUp ? 'Sign up' : 'Log in'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),

                // Scrollable Form Area
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // 3D Liquid Glass Orb (Inspired by the reference design)
                          const _LiquidGlassOrb(size: 82),

                          // Heading: "Log in to your account ✧"
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _authType == _AuthType.phone
                                      ? 'Mobile Verification'
                                      : (_isSignUp
                                          ? 'Create your account'
                                          : 'Log in to your account'),
                                  style: const TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const _SparkleIcon(color: Color(0xFF34D399), size: 22),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Subtitle: "Welcome back! please enter your details"
                          Text(
                            _authType == _AuthType.phone
                                ? 'Fast & secure verification code sent to your phone'
                                : (_isSignUp
                                    ? 'Welcome! Please enter your details to sign up'
                                    : 'Welcome back! please enter your details'),
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ===================================================
                          // LIQUID GLASS CAPSULE INPUT FIELDS
                          // ===================================================
                          if (_authType == _AuthType.email) ...[
                            // Full Name (Only when signing up)
                            if (_isSignUp) ...[
                              _LiquidGlassInputField(
                                controller: _nameController,
                                hintText: 'Full Name',
                                prefixIcon: Icons.person_outline_rounded,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => v == null || v.trim().length < 2
                                    ? 'Enter your full name'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Email Address Field
                            _LiquidGlassInputField(
                              controller: _emailController,
                              hintText: 'Enter your email',
                              prefixIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              validator: (v) => v == null || !v.contains('@')
                                  ? 'Enter a valid email address'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            _LiquidGlassInputField(
                              controller: _passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white54,
                                  size: 19,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              validator: (v) => v == null || v.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null,
                              onFieldSubmitted: (_) => _submitEmail(),
                            ),
                            const SizedBox(height: 14),

                            // Remember Me & Forgot Password Row
                            if (!_isSignUp)
                              Row(
                                children: [
                                  // Custom Rounded Checkbox
                                  GestureDetector(
                                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            color: _rememberMe
                                                ? const Color(0xFF10B981)
                                                : Colors.white.withValues(alpha: 0.05),
                                            border: Border.all(
                                              color: _rememberMe
                                                  ? const Color(0xFF10B981)
                                                  : Colors.white30,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: _rememberMe
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 14,
                                                  color: Color(0xFF042013),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.75),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  // Forgot Password Link
                                  GestureDetector(
                                    onTap: _forgotPassword,
                                    child: const Text(
                                      'Forgot password',
                                      style: TextStyle(
                                        color: Color(0xFF34D399),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ] else ...[
                            // =================================================
                            // MOBILE OTP MODE
                            // =================================================
                            if (!auth.otpSent) ...[
                              _LiquidGlassInputField(
                                controller: _phoneController,
                                hintText: '+91 98765 43210',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'A 6-digit one-time SMS verification code will be sent to this number.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ] else ...[
                              _LiquidGlassInputField(
                                controller: _otpController,
                                hintText: 'Enter 6-digit OTP',
                                prefixIcon: Icons.pin_outlined,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: busy ? null : _sendOtp,
                                    child: const Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        color: Color(0xFF34D399),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: auth.resetOtp,
                                    child: Text(
                                      'Change Number',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],

                          const SizedBox(height: 26),

                          // ===================================================
                          // LIQUID GLASS PRIMARY ACTION BUTTON: [ Log In ]
                          // ===================================================
                          _LiquidGlassButton(
                            label: _authType == _AuthType.phone
                                ? (auth.otpSent ? 'Verify & Sign In' : 'Send OTP')
                                : (_isSignUp ? 'Sign Up' : 'Log In'),
                            isLoading: busy,
                            onTap: busy
                                ? null
                                : () {
                                    if (_authType == _AuthType.phone) {
                                      if (auth.otpSent) {
                                        _verifyOtp();
                                      } else {
                                        _sendOtp();
                                      }
                                    } else {
                                      _submitEmail();
                                    }
                                  },
                          ),

                          const SizedBox(height: 20),

                          // Switch Between Email & Mobile OTP Mode (Glass Pill)
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _authType = _authType == _AuthType.email
                                      ? _AuthType.phone
                                      : _AuthType.email;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _authType == _AuthType.email
                                          ? Icons.phone_android_rounded
                                          : Icons.mail_outline_rounded,
                                      size: 14,
                                      color: const Color(0xFF34D399),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _authType == _AuthType.email
                                          ? 'Use Mobile OTP instead'
                                          : 'Use Email & Password instead',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.75),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Footer: "Don't have an account? Sign Up"
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isSignUp
                                      ? 'Already have an account? '
                                      : "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isSignUp = !_isSignUp;
                                    });
                                  },
                                  child: Text(
                                    _isSignUp ? 'Log In' : 'Sign Up',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF34D399),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Color(0xFF34D399),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Optional Skip / Guest Mode link
                          if (widget.allowSkip) ...[
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).maybePop(),
                                child: Text(
                                  'Continue as Guest',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// Brand App Icon Header (Concentric Liquid Emerald Aura & Official App Icon)
// ==============================================================================
class _LiquidGlassOrb extends StatelessWidget {
  const _LiquidGlassOrb({this.size = 86});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(bottom: 24),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // 1. Ambient Outer Liquid Emerald Glow
            Container(
              width: size * 1.35,
              height: size * 1.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.40),
                    const Color(0xFF059669).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // 2. Official App Icon with Rounded Glass Bezel
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.50),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/app_icon.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// Sparkle Icon (✧ Accent)
// ==============================================================================
class _SparkleIcon extends StatelessWidget {
  const _SparkleIcon({required this.color, this.size = 20});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FourPointStarPainter(color: color),
      ),
    );
  }
}

class _FourPointStarPainter extends CustomPainter {
  const _FourPointStarPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final path = Path();

    // 4-point star
    path.moveTo(w * 0.5, 0);
    path.quadraticBezierTo(w * 0.5, h * 0.5, w, h * 0.5);
    path.quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, h);
    path.quadraticBezierTo(w * 0.5, h * 0.5, 0, h * 0.5);
    path.quadraticBezierTo(w * 0.5, h * 0.5, w * 0.5, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Mini companion sparkle
    final smallPath = Path();
    final sw = w * 0.35;
    final sh = h * 0.35;
    final ox = w * 0.75;
    const oy = 0.0;
    smallPath.moveTo(ox + sw * 0.5, oy);
    smallPath.quadraticBezierTo(ox + sw * 0.5, oy + sh * 0.5, ox + sw, oy + sh * 0.5);
    smallPath.quadraticBezierTo(ox + sw * 0.5, oy + sh * 0.5, ox + sw * 0.5, oy + sh);
    smallPath.quadraticBezierTo(ox + sw * 0.5, oy + sh * 0.5, ox, oy + sh * 0.5);
    smallPath.quadraticBezierTo(ox + sw * 0.5, oy + sh * 0.5, ox + sw * 0.5, oy);
    smallPath.close();

    final smallPaint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(smallPath, smallPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==============================================================================
// Liquid Glass Capsule Input Field (Frosted Blur + Specular Refraction Edge)
// ==============================================================================
class _LiquidGlassInputField extends StatefulWidget {
  const _LiquidGlassInputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final int? maxLength;

  @override
  State<_LiquidGlassInputField> createState() => _LiquidGlassInputFieldState();
}

class _LiquidGlassInputFieldState extends State<_LiquidGlassInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            // Liquid glass translucency gradient
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: _isFocused ? 0.10 : 0.06),
                Colors.white.withValues(alpha: _isFocused ? 0.04 : 0.02),
              ],
            ),
            // Specular refraction border
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFF10B981)
                  : Colors.white.withValues(alpha: 0.14),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isFocused
                    ? const Color(0xFF10B981).withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.25),
                blurRadius: _isFocused ? 16 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            maxLength: widget.maxLength,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFF10B981),
            decoration: InputDecoration(
              counterText: '',
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: false,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 18, right: 12),
                child: Icon(
                  widget.prefixIcon,
                  color: _isFocused
                      ? const Color(0xFF34D399)
                      : Colors.white.withValues(alpha: 0.55),
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 46, minHeight: 24),
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: widget.suffixIcon,
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// Liquid Glass Primary Button (Specular Sheen + Glowing Ambient Drop Shadow)
// ==============================================================================
class _LiquidGlassButton extends StatelessWidget {
  const _LiquidGlassButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF34D399), // Luminous Mint Green
            Color(0xFF10B981), // Core Emerald
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.38),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Liquid Gloss Highlight Layer (Curved glass reflection along top)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Button Content
              Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF042013)),
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF042013),
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'customer_dashboard.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkTheme;

  const LoginScreen({
    super.key,
    this.onToggleTheme,
    this.isDarkTheme = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegisterMode = false;

  // Sign In Controllers
  final TextEditingController _signInEmailController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();

  // Register Controllers (Customer only)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _meterIdController = TextEditingController();
  final TextEditingController _areaController = TextEditingController(text: 'Homagama');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regConfirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _nameController.dispose();
    _regEmailController.dispose();
    _meterIdController.dispose();
    _areaController.dispose();
    _phoneController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard(UserModel user) {
    if (!mounted) return;

    Widget target;
    switch (user.role) {
      case UserRole.customer:
        target = CustomerDashboard(
          onToggleTheme: widget.onToggleTheme ?? () {},
          isDarkTheme: widget.isDarkTheme,
        );
        break;
      case UserRole.reader:
        target = MainNavigationScreen(
          onToggleTheme: widget.onToggleTheme ?? () {},
          isDarkTheme: widget.isDarkTheme,
        );
        break;
      case UserRole.admin:
        target = AdminDashboard(
          onToggleTheme: widget.onToggleTheme ?? () {},
          isDarkTheme: widget.isDarkTheme,
        );
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => target),
      (route) => false,
    );
  }

  Future<void> _handleSignIn() async {
    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _navigateToDashboard(user);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Invalid email or password.';
      if (e.code == 'configuration-not-found' || msg.contains('CONFIGURATION_NOT_FOUND')) {
        msg = 'Firebase Authentication is not yet enabled in project metermind-29087. '
              'Please enable Email/Password provider in the Firebase Console.';
      } else if (e.code == 'user-not-found') {
        msg = 'No user account found for this email. Please register as a customer first.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Incorrect password or credentials. Please check and try again.';
      } else if (e.code == 'user-disabled') {
        msg = 'This account has been disabled. Please contact the administrator.';
      }
      setState(() {
        _errorMessage = msg;
      });
    } catch (e) {
      String errText = e.toString().replaceAll('Exception: ', '');
      if (errText.contains('CONFIGURATION_NOT_FOUND')) {
        errText = 'Firebase Authentication is not yet enabled in project metermind-29087. '
                  'Please enable Email/Password provider in the Firebase Console.';
      }
      setState(() {
        _errorMessage = errText;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _regEmailController.text.trim();
    final meterId = _meterIdController.text.trim();
    final area = _areaController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _regPasswordController.text.trim();
    final confirmPassword = _regConfirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || meterId.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields (Name, Email, Meter No, Password).';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.instance.registerCustomer(
        name: name,
        email: email,
        password: password,
        meterId: meterId,
        area: area.isNotEmpty ? area : 'Homagama',
        phone: phone,
      );
      _navigateToDashboard(user);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Could not create account.';
      if (e.code == 'configuration-not-found' || msg.contains('CONFIGURATION_NOT_FOUND')) {
        msg = 'Firebase Authentication is not yet enabled in project metermind-29087. '
              'Please enable Email/Password provider in the Firebase Console.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'This email is already registered. Please sign in instead.';
      } else if (e.code == 'weak-password') {
        msg = 'The password provided is too weak. Please choose a stronger password.';
      } else if (e.code == 'invalid-email') {
        msg = 'The email address is not formatted correctly.';
      } else if (e.code == 'operation-not-allowed') {
        msg = 'Email/Password sign-in is disabled in Firebase Console.';
      }
      setState(() {
        _errorMessage = msg;
      });
    } catch (e) {
      String errText = e.toString().replaceAll('Exception: ', '');
      if (errText.contains('CONFIGURATION_NOT_FOUND')) {
        errText = 'Firebase Authentication is not yet enabled in project metermind-29087. '
                  'Please enable Email/Password provider in the Firebase Console.';
      }
      setState(() {
        _errorMessage = errText;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController(text: _signInEmailController.text.trim());
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address to receive a secure password reset link from Firebase.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.ink,
            ),
            onPressed: () async {
              final em = emailController.text.trim();
              if (em.isEmpty) return;
              Navigator.pop(dialogCtx);
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: em);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password reset link sent to $em')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send reset link: $e')),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkTheme;
    final bg = isDark ? AppColors.darkBg : AppColors.soft;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1F000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.ink,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -1,
                          ),
                          children: const [
                            TextSpan(text: 'Meter'),
                            TextSpan(
                              text: 'Mind',
                              style: TextStyle(color: Color(0xFF8C6904)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Electricity Management & Field Intelligence',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: mutedColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Segmented Switcher: Sign In | Register as Customer
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF232D27) : const Color(0xFFE8ECE4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _isRegisterMode = false;
                              _errorMessage = null;
                            }),
                            borderRadius: BorderRadius.circular(11),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isRegisterMode
                                    ? (isDark ? cardBg : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: !_isRegisterMode
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Sign In',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: !_isRegisterMode ? FontWeight.w800 : FontWeight.w600,
                                    color: !_isRegisterMode ? textColor : mutedColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() {
                              _isRegisterMode = true;
                              _errorMessage = null;
                            }),
                            borderRadius: BorderRadius.circular(11),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isRegisterMode
                                    ? (isDark ? cardBg : Colors.white)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(11),
                                boxShadow: _isRegisterMode
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Register as Customer',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: _isRegisterMode ? FontWeight.w800 : FontWeight.w600,
                                    color: _isRegisterMode ? textColor : mutedColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Main Form Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isRegisterMode
                        ? _buildCustomerRegisterForm(textColor, mutedColor)
                        : _buildSignInForm(textColor, mutedColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(Color textColor, Color mutedColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email address',
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: _signInEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Password',
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: _signInPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.red, fontWeight: FontWeight.w600),
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: _showForgotPasswordDialog,
            child: Text(
              'Forgot password?',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7B5B00),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: AppColors.yellow),
            ),
          )
        else
          ElevatedButton(
            onPressed: _handleSignIn,
            child: const Text('Sign In'),
          ),
      ],
    );
  }

  Widget _buildCustomerRegisterForm(Color textColor, Color mutedColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Color(0xFF2A5934)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Public registration creates a Customer profile. Staff accounts are managed by Admin.',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF2A5934), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Full Name *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g. Kasun Silva',
            prefixIcon: Icon(Icons.person_outline, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        Text('Email address *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'kasun@example.com',
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        Text('Electricity Meter Number *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: _meterIdController,
          decoration: const InputDecoration(
            hintText: 'e.g. MM-04218',
            prefixIcon: Icon(Icons.speed_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Area / Town', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _areaController,
                    decoration: const InputDecoration(hintText: 'Homagama'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+94 77 000 0000'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text('Password *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: _regPasswordController,
          obscureText: _obscureRegPassword,
          decoration: InputDecoration(
            hintText: 'At least 6 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Confirm Password *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: textColor)),
        const SizedBox(height: 6),
        TextField(
          controller: _regConfirmPasswordController,
          obscureText: _obscureRegPassword,
          decoration: const InputDecoration(
            hintText: 'Re-enter password',
            prefixIcon: Icon(Icons.lock_rounded, size: 20),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.red, fontWeight: FontWeight.w600),
          ),
        ],
        const SizedBox(height: 20),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: AppColors.yellow),
            ),
          )
        else
          ElevatedButton(
            onPressed: _handleRegister,
            child: const Text('Create Customer Account'),
          ),
      ],
    );
  }
}

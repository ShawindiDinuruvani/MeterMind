import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
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
  final TextEditingController _signInEmailController =
      TextEditingController(text: 'nimal.perera@metermind.lk');
  final TextEditingController _signInPasswordController =
      TextEditingController(text: 'password123');

  // Register Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPasswordController = TextEditingController();
  final TextEditingController _regConfirmPasswordController =
      TextEditingController();
  final TextEditingController _meterIdController =
      TextEditingController(text: 'MM-04218');
  final TextEditingController _employeeCodeController =
      TextEditingController(text: 'MR002');
  final TextEditingController _areaController =
      TextEditingController(text: 'Homagama');

  UserRole _selectedRole = UserRole.customer;

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
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _meterIdController.dispose();
    _employeeCodeController.dispose();
    _areaController.dispose();
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
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign in failed. Please check your credentials.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text.trim();
    final confirmPassword = _regConfirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please complete all required fields.';
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
      final user = await AuthService.instance.registerUser(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
        meterId: _selectedRole == UserRole.customer
            ? _meterIdController.text.trim()
            : null,
        employeeCode: _selectedRole == UserRole.reader
            ? _employeeCodeController.text.trim()
            : null,
        area: _areaController.text.trim(),
      );

      _navigateToDashboard(user);
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration could not be completed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleQuickLogin(UserRole role) {
    AuthService.instance.quickDemoLogin(role);
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _navigateToDashboard(user);
    }
  }

  void _showForgotPasswordDialog() {
    final resetController =
        TextEditingController(text: _signInEmailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        title: Text(
          'Reset your password',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address to receive password reset instructions.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetController,
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(110, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Password reset instructions sent if account exists.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkTheme;
    final textColor = isDark ? AppColors.darkText : AppColors.ink;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.muted;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'ϟ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -0.8,
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
                      if (widget.onToggleTheme != null)
                        IconButton(
                          tooltip: 'Toggle Theme',
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                            size: 20,
                            color: textColor,
                          ),
                          onPressed: widget.onToggleTheme,
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  EyebrowHeader(
                    eyebrow: _isRegisterMode
                        ? 'CREATE METERMIND ACCOUNT'
                        : 'WELCOME TO METERMIND',
                    title: _isRegisterMode
                        ? 'Join the network.'
                        : 'Welcome back.',
                    subtitle: _isRegisterMode
                        ? 'Select your role and enter your details.'
                        : 'Your energy, understood.',
                  ),

                  const SizedBox(height: 18),

                  // Tab Switcher: Sign In vs Register
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF232D27)
                          : const Color(0xFFE8ECE4),
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
                                          color: Colors.black.withOpacity(0.04),
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
                                    fontWeight: !_isRegisterMode
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: !_isRegisterMode
                                        ? textColor
                                        : mutedColor,
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
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Register',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: _isRegisterMode
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: _isRegisterMode
                                        ? textColor
                                        : mutedColor,
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: borderColor),
                    ),
                    child: _isRegisterMode
                        ? _buildRegisterForm(textColor, mutedColor)
                        : _buildSignInForm(textColor, mutedColor),
                  ),

                  const SizedBox(height: 24),

                  // Quick Demo Role Switcher
                  Text(
                    'QUICK DEMO ACCESS (1-TAP)',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: mutedColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDemoCard(
                          icon: Icons.electric_bolt_rounded,
                          roleTitle: 'Field Officer',
                          subTitle: 'Meter Reader',
                          color: AppColors.yellow,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          onTap: () => _handleQuickLogin(UserRole.reader),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDemoCard(
                          icon: Icons.home_rounded,
                          roleTitle: 'Customer',
                          subTitle: 'Smart Home',
                          color: AppColors.green,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          onTap: () => _handleQuickLogin(UserRole.customer),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDemoCard(
                          icon: Icons.shield_rounded,
                          roleTitle: 'Admin',
                          subTitle: 'Operations',
                          color: AppColors.blue,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          onTap: () => _handleQuickLogin(UserRole.admin),
                        ),
                      ),
                    ],
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
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: _signInEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'you@metermind.lk',
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Password',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: _signInPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 10),
          Text(
            _errorMessage!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
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

  Widget _buildRegisterForm(Color textColor, Color mutedColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Role',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRoleChip(UserRole.customer, 'Customer', Icons.person_outline),
            const SizedBox(width: 6),
            _buildRoleChip(UserRole.reader, 'Reader', Icons.badge_outlined),
            const SizedBox(width: 6),
            _buildRoleChip(UserRole.admin, 'Admin', Icons.security_rounded),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Full Name',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'e.g. Kasun Silva',
            prefixIcon: Icon(Icons.person_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Email address',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'kasun@example.com',
            prefixIcon: Icon(Icons.email_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        if (_selectedRole == UserRole.customer) ...[
          Text(
            'Meter Number',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _meterIdController,
            decoration: const InputDecoration(
              hintText: 'e.g. MM-04218',
              prefixIcon: Icon(Icons.speed_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (_selectedRole == UserRole.reader) ...[
          Text(
            'Employee Code',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _employeeCodeController,
            decoration: const InputDecoration(
              hintText: 'e.g. MR003',
              prefixIcon: Icon(Icons.badge_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          _selectedRole == UserRole.admin ? 'Department' : 'Area / Depot',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _areaController,
          decoration: InputDecoration(
            hintText: _selectedRole == UserRole.admin
                ? 'Operations HQ'
                : 'e.g. Homagama',
            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Password',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regPasswordController,
          obscureText: _obscureRegPassword,
          decoration: InputDecoration(
            hintText: 'At least 6 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureRegPassword = !_obscureRegPassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Confirm Password',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
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
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.red,
              fontWeight: FontWeight.w600,
            ),
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
            child: const Text('Create Account'),
          ),
      ],
    );
  }

  Widget _buildRoleChip(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.yellow
                : (widget.isDarkTheme
                    ? const Color(0xFF2E3831)
                    : const Color(0xFFEFF2EB)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.ink : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.ink : AppColors.muted,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required IconData icon,
    required String roleTitle,
    required String subTitle,
    required Color color,
    required Color textColor,
    required Color mutedColor,
    required Color cardBg,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 6),
              Text(
                roleTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              Text(
                subTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  color: mutedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import 'home_screen.dart';
import 'faculty_home_screen.dart';
import 'pending_verification_screen.dart';
import 'student_registration_screen.dart';
import 'faculty_registration_screen.dart';

/// Login Screen - Entry point for user authentication.
/// Premium design with responsive layout and subtle animations.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isStudentSelected = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs
    bool isValid = true;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final session = await UserSession.getInstance();

      if (_isStudentSelected) {
        await _attemptStudentLogin(email, password, session);
      } else {
        await _attemptTeacherLogin(email, password, session);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _attemptStudentLogin(
    String email,
    String password,
    UserSession session,
  ) async {
    try {
      // Sign in with Supabase
      await SupabaseService.signIn(email: email, password: password);

      // Get student profile
      final student = await SupabaseService.getStudentProfile();

      if (student != null) {
        await session.saveStudentSession(
          studentId: student.studentId,
          email: student.varsityEmail,
          name: student.name,
          department: student.department,
          isVerified: student.isVerified,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));

          if (!student.isVerified) {
            _navigateToPendingVerification();
          } else {
            _navigateToHome();
          }
        }
      } else {
        // Signed in but no student profile - might be a teacher account
        await SupabaseService.signOut();
        setState(() => _emailError = 'No student account found for this email');
      }
    } catch (e) {
      setState(() => _emailError = 'Invalid email or password');
    }
  }

  Future<void> _attemptTeacherLogin(
    String email,
    String password,
    UserSession session,
  ) async {
    try {
      // Sign in with Supabase
      await SupabaseService.signIn(email: email, password: password);

      // Get teacher profile
      final teacher = await SupabaseService.getTeacherProfile();

      if (teacher != null) {
        await session.saveTeacherSession(
          teacherId: teacher.teacherId,
          email: teacher.email,
          name: teacher.name,
          initials: teacher.initials,
          department: teacher.department,
        );

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
          _navigateToFacultyHome();
        }
      } else {
        // Signed in but no teacher profile - might be a student account
        await SupabaseService.signOut();
        setState(() => _emailError = 'No faculty account found for this email');
      }
    } catch (e) {
      setState(() => _emailError = 'Invalid email or password');
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateToFacultyHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const FacultyHomeScreen()),
      (route) => false,
    );
  }

  void _navigateToPendingVerification() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const PendingVerificationScreen(),
      ),
      (route) => false,
    );
  }

  void _navigateToRegistration() {
    if (_isStudentSelected) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const StudentRegistrationScreen(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const FacultyRegistrationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            final isTablet =
                constraints.maxWidth > 600 && constraints.maxWidth <= 900;

            if (isWideScreen) {
              return _buildWideLayout();
            } else {
              return _buildMobileLayout(isTablet);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left side - Decorative panel
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primaryDark,
                  AppTheme.primary.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  right: -150,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  right: 50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.science_outlined,
                              size: 56,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'ResearchTech',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bridging Faculty Research\n& Student Interest',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Feature highlights
                          _buildFeatureRow(
                            Icons.search,
                            'Discover research opportunities',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureRow(
                            Icons.connect_without_contact,
                            'Connect with faculty directly',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureRow(
                            Icons.lightbulb_outline,
                            'Share your research interests',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Login form
        Expanded(
          flex: 4,
          child: Container(
            color: AppTheme.background,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(48),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isTablet) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 450 : double.infinity,
          ),
          padding: EdgeInsets.all(isTablet ? 48 : AppTheme.spacingLg),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                SizedBox(height: isTablet ? 40 : AppTheme.spacingXl),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.science_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Role toggle
          Center(
            child: ElegantRoleToggle(
              isStudentSelected: _isStudentSelected,
              onChanged: (isStudent) {
                setState(() => _isStudentSelected = isStudent);
              },
            ),
          ),
          const SizedBox(height: 32),
          // Email input
          _buildAnimatedTextField(
            controller: _emailController,
            label: _isStudentSelected ? 'Varsity Email' : 'Email',
            hint: _isStudentSelected
                ? 'Enter your varsity email'
                : 'Enter your email',
            icon: Icons.email_outlined,
            errorText: _emailError,
            onChanged: (_) => setState(() => _emailError = null),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Password input
          _buildAnimatedTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            isPassword: true,
            errorText: _passwordError,
            onChanged: (_) => setState(() => _passwordError = null),
          ),
          const SizedBox(height: 32),
          // Login button
          AnimatedButton(
            text: 'Sign In',
            onPressed: _attemptLogin,
            isLoading: _isLoading,
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          // Register link
          Center(
            child: AnimatedTextButton(
              text: "Don't have an account? Register",
              onPressed: _navigateToRegistration,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: errorText != null
                ? AppTheme.error.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        autofillHints: isPassword ? const [] : null,
        keyboardType: isPassword
            ? TextInputType.visiblePassword
            : TextInputType.emailAddress,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          prefixIcon: Icon(icon, color: AppTheme.textSecondary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.divider.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.error),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

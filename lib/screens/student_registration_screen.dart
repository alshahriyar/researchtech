import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import 'login_screen.dart';

/// Student Registration Screen
/// Premium design with responsive layout and subtle animations.
class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _studentIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedDepartment;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _studentIdError;
  String? _nameError;
  String? _departmentError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    _studentIdController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _attemptRegistration() async {
    // Clear errors
    setState(() {
      _studentIdError = null;
      _nameError = null;
      _departmentError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final studentId = _studentIdController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_validateInputs(studentId, name, email, password, confirmPassword)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if already registered
      final isRegistered = await SupabaseService.isStudentEmailRegistered(
        email,
      );
      if (isRegistered) {
        setState(() {
          _emailError = 'This email is already registered';
          _isLoading = false;
        });
        return;
      }

      // Register with Supabase
      await SupabaseService.signUpStudent(
        email: email,
        password: password,
        studentId: studentId,
        name: name,
        department: _selectedDepartment!,
      );

      // Sign out after registration (user needs to verify email and login)
      await SupabaseService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateInputs(
    String studentId,
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    bool isValid = true;

    if (studentId.isEmpty) {
      setState(() => _studentIdError = 'Student ID is required');
      isValid = false;
    }

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      isValid = false;
    }

    if (_selectedDepartment == null || _selectedDepartment!.isEmpty) {
      setState(() => _departmentError = 'Please select a department');
      isValid = false;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!Student.isValidVarsityEmail(email)) {
      setState(() => _emailError = 'Email must end with @diu.edu.bd');
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Please confirm your password');
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      isValid = false;
    }

    return isValid;
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
          flex: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
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
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.school_outlined,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Join as Student',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Discover research opportunities\nand connect with faculty',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              height: 1.5,
                            ),
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
        // Right side - Form
        Expanded(
          flex: 5,
          child: Container(
            color: AppTheme.background,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      AnimatedTextButton(
                        text: 'Already have an account? Sign in',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Form
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        padding: const EdgeInsets.all(32),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildForm(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isTablet) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Student Registration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        // Form
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : double.infinity,
                ),
                padding: EdgeInsets.all(isTablet ? 32 : AppTheme.spacingLg),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildForm(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in your details to get started',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        // Student ID
        _buildTextField(
          controller: _studentIdController,
          label: 'Student ID',
          hint: 'Enter your Student ID',
          icon: Icons.badge_outlined,
          errorText: _studentIdError,
          onChanged: (_) => setState(() => _studentIdError = null),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Name
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          errorText: _nameError,
          onChanged: (_) => setState(() => _nameError = null),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Department
        _buildDropdownField(),
        const SizedBox(height: AppTheme.spacingMd),
        // Email
        _buildTextField(
          controller: _emailController,
          label: 'Varsity Email',
          hint: 'yourname@diu.edu.bd',
          icon: Icons.email_outlined,
          helperText: 'Must end with @diu.edu.bd',
          errorText: _emailError,
          onChanged: (_) => setState(() => _emailError = null),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Password
        _buildTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Create a password',
          icon: Icons.lock_outline,
          isPassword: true,
          errorText: _passwordError,
          onChanged: (_) => setState(() => _passwordError = null),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Confirm Password
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Confirm your password',
          icon: Icons.lock_outline,
          isPassword: true,
          useConfirmObscure: true,
          errorText: _confirmPasswordError,
          onChanged: (_) => setState(() => _confirmPasswordError = null),
        ),
        const SizedBox(height: 32),
        // Register Button
        AnimatedButton(
          text: 'Create Account',
          onPressed: _attemptRegistration,
          isLoading: _isLoading,
          icon: Icons.arrow_forward,
          width: double.infinity,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Login link (mobile only)
        Center(
          child: AnimatedTextButton(
            text: 'Already have an account? Sign in',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? helperText,
    bool isPassword = false,
    bool useConfirmObscure = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final obscure = useConfirmObscure
        ? _obscureConfirmPassword
        : _obscurePassword;

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
        obscureText: isPassword && obscure,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          errorText: errorText,
          prefixIcon: Icon(icon, color: AppTheme.textSecondary),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      if (useConfirmObscure) {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      } else {
                        _obscurePassword = !_obscurePassword;
                      }
                    });
                  },
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

  Widget _buildDropdownField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _departmentError != null
                ? AppTheme.error.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        key: ValueKey(_selectedDepartment),
        initialValue: _selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Department',
          errorText: _departmentError,
          prefixIcon: const Icon(
            Icons.business_outlined,
            color: AppTheme.textSecondary,
          ),
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
        ),
        items: SupabaseService.departments
            .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedDepartment = value;
            _departmentError = null;
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/teacher.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_button.dart';
import 'login_screen.dart';

/// Faculty Registration Screen
/// Premium design with responsive layout and subtle animations.
class FacultyRegistrationScreen extends StatefulWidget {
  const FacultyRegistrationScreen({super.key});

  @override
  State<FacultyRegistrationScreen> createState() =>
      _FacultyRegistrationScreenState();
}

class _FacultyRegistrationScreenState extends State<FacultyRegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _facultyIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _initialsController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _experienceController = TextEditingController();
  final _additionalDesignationController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedDesignation;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _facultyIdError;
  String? _nameError;
  String? _initialsError;
  String? _departmentError;
  String? _designationError;
  String? _experienceError;
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
    _facultyIdController.dispose();
    _nameController.dispose();
    _initialsController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _experienceController.dispose();
    _additionalDesignationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _attemptRegistration() async {
    setState(() {
      _facultyIdError = null;
      _nameError = null;
      _initialsError = null;
      _departmentError = null;
      _designationError = null;
      _experienceError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final facultyId = _facultyIdController.text.trim();
    final name = _nameController.text.trim();
    final initials = _initialsController.text.trim().toUpperCase();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final experienceText = _experienceController.text.trim();

    if (!_validateInputs(
      facultyId,
      name,
      initials,
      email,
      password,
      confirmPassword,
      experienceText,
    )) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if already registered
      final isRegistered = await SupabaseService.isTeacherEmailRegistered(
        email,
      );
      if (isRegistered) {
        setState(() {
          _emailError = 'This email is already registered';
          _isLoading = false;
        });
        return;
      }

      final experienceYears = int.tryParse(experienceText) ?? 0;

      // Register with Supabase
      await SupabaseService.signUpTeacher(
        email: email,
        password: password,
        teacherId: facultyId,
        name: name,
        department: _selectedDepartment!,
        initials: initials,
        designation: _selectedDesignation!,
        additionalDesignation: _additionalDesignationController.text.trim(),
        experienceYears: experienceYears,
      );

      // Sign out after registration (user needs to login)
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
    String facultyId,
    String name,
    String initials,
    String email,
    String password,
    String confirmPassword,
    String experienceText,
  ) {
    bool isValid = true;

    if (facultyId.isEmpty) {
      setState(() => _facultyIdError = 'Faculty ID is required');
      isValid = false;
    }

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      isValid = false;
    }

    if (initials.isEmpty) {
      setState(() => _initialsError = 'Initials are required');
      isValid = false;
    } else if (initials.length < 2 || initials.length > 5) {
      setState(() => _initialsError = 'Initials must be 2-5 letters');
      isValid = false;
    }

    if (_selectedDesignation == null || _selectedDesignation!.isEmpty) {
      setState(() => _designationError = 'Please select a designation');
      isValid = false;
    }

    if (experienceText.isEmpty) {
      setState(() => _experienceError = 'Experience is required');
      isValid = false;
    } else {
      final years = int.tryParse(experienceText);
      if (years == null || years < 0 || years > 50) {
        setState(() => _experienceError = 'Enter valid years (0-50)');
        isValid = false;
      }
    }

    if (_selectedDepartment == null || _selectedDepartment!.isEmpty) {
      setState(() => _departmentError = 'Please select a department');
      isValid = false;
    }

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Enter a valid email');
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  left: -80,
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
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
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
                              Icons.person_outline,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Join as Faculty',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Share your research\nand connect with students',
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
                'Faculty Registration',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
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
        // Faculty ID
        _buildTextField(
          controller: _facultyIdController,
          label: 'Faculty ID',
          hint: 'Enter your Faculty ID',
          icon: Icons.badge_outlined,
          errorText: _facultyIdError,
          onChanged: (_) => setState(() => _facultyIdError = null),
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
        // Initials
        _buildTextField(
          controller: _initialsController,
          label: 'Initials',
          hint: 'e.g., AKH',
          icon: Icons.abc,
          maxLength: 5,
          helperText: '2-5 letters for identification',
          errorText: _initialsError,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) => setState(() => _initialsError = null),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Designation Dropdown
        _buildDesignationDropdown(),
        const SizedBox(height: AppTheme.spacingMd),
        // Additional Designation (Optional)
        _buildTextField(
          controller: _additionalDesignationController,
          label: 'Additional Designation Details',
          hint: 'e.g., Head of Department, PhD Coordinator',
          icon: Icons.add_circle_outline,
          helperText: 'Optional - add any additional title or role',
          onChanged: (_) {},
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Experience
        _buildTextField(
          controller: _experienceController,
          label: 'Years of Experience',
          hint: 'e.g., 5',
          icon: Icons.work_history_outlined,
          keyboardType: TextInputType.number,
          helperText: 'Teaching/research experience in years',
          errorText: _experienceError,
          onChanged: (_) => setState(() => _experienceError = null),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Department
        _buildDropdownField(),
        const SizedBox(height: AppTheme.spacingMd),
        // Email
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'yourname@example.com',
          icon: Icons.email_outlined,
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
        // Login link
        Center(
          child: AnimatedTextButton(
            text: 'Already have an account? Sign in',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? helperText,
    int? maxLength,
    bool isPassword = false,
    bool useConfirmObscure = false,
    String? errorText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType keyboardType = TextInputType.text,
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
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          errorText: errorText,
          counterText: '',
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

  Widget _buildDesignationDropdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _designationError != null
                ? AppTheme.error.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        key: ValueKey(_selectedDesignation),
        initialValue: _selectedDesignation,
        decoration: InputDecoration(
          labelText: 'Designation',
          errorText: _designationError,
          prefixIcon: const Icon(
            Icons.work_outline,
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
        items: Teacher.designations
            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedDesignation = value;
            _designationError = null;
          });
        },
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

import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import '../models/teacher.dart';

/// Edit Profile Screen
/// Allows users to edit their profile information.
/// Email and ID are read-only as per requirements.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _initialsController = TextEditingController();
  final _researchInterestController = TextEditingController();
  final _additionalDesignationController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isTeacher = false;
  String _userId = '';
  String _userEmail = '';
  String? _selectedDepartment;
  String? _selectedDesignation;

  String? _nameError;
  String? _departmentError;
  String? _initialsError;
  String? _researchInterestError;
  String? _designationError;
  String? _experienceError;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final session = await UserSession.getInstance();

    // Fetch teacher data if applicable
    Teacher? teacher;
    if (session.isTeacher) {
      teacher = await SupabaseService.getTeacherById(session.userId);
    }

    if (mounted) {
      setState(() {
        _userId = session.userId;
        _userEmail = session.userEmail;
        _isTeacher = session.isTeacher;
        _nameController.text = session.userName;
        _selectedDepartment = session.userDepartment;

        if (_isTeacher) {
          _initialsController.text = session.userInitials;
          // Load faculty-specific fields
          if (teacher != null) {
            _selectedDesignation = teacher.designation;
            _researchInterestController.text = teacher.researchInterest;
            _additionalDesignationController.text =
                teacher.additionalDesignation;
            _experienceController.text = teacher.experienceYears.toString();
          }
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _initialsController.dispose();
    _researchInterestController.dispose();
    _additionalDesignationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Clear errors
    setState(() {
      _nameError = null;
      _departmentError = null;
      _initialsError = null;
      _designationError = null;
      _experienceError = null;
    });

    final name = _nameController.text.trim();
    final initials = _initialsController.text.trim().toUpperCase();
    final experienceText = _experienceController.text.trim();

    // Validate
    bool isValid = true;

    if (name.isEmpty) {
      setState(() => _nameError = 'Name is required');
      isValid = false;
    } else if (name.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      isValid = false;
    }

    if (_selectedDepartment == null || _selectedDepartment!.isEmpty) {
      setState(() => _departmentError = 'Please select a department');
      isValid = false;
    }

    if (_isTeacher) {
      final initialsRegex = RegExp(r'^[A-Z]{2,5}$');
      if (!initialsRegex.hasMatch(initials)) {
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
    }

    if (!isValid) return;

    setState(() => _isSaving = true);

    try {
      final session = await UserSession.getInstance();

      if (_isTeacher) {
        final experienceYears = int.tryParse(experienceText) ?? 0;
        final researchInterest = _researchInterestController.text.trim();

        // Update teacher in Supabase
        final success = await SupabaseService.updateTeacher(
          name: name,
          initials: initials,
          department: _selectedDepartment!,
          designation: _selectedDesignation,
          researchInterest: researchInterest,
          additionalDesignation: _additionalDesignationController.text.trim(),
          experienceYears: experienceYears,
        );

        if (success) {
          // Update local session
          await session.saveTeacherSession(
            teacherId: _userId,
            email: _userEmail,
            name: name,
            initials: initials,
            department: _selectedDepartment!,
          );
        }
      } else {
        // Update student in Supabase
        final success = await SupabaseService.updateStudent(
          name: name,
          department: _selectedDepartment!,
        );

        if (success) {
          await session.saveStudentSession(
            studentId: _userId,
            email: _userEmail,
            name: name,
            department: _selectedDepartment!,
            isVerified: session.isVerified,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.all(isWideScreen ? 48 : AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              _getInitials(_nameController.text),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            _isTeacher ? 'Faculty Profile' : 'Student Profile',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXl),

                    // Read-only fields section
                    _buildSectionTitle('Account Information (Read-only)'),
                    const SizedBox(height: AppTheme.spacingMd),

                    // ID field (read-only)
                    TextField(
                      controller: TextEditingController(text: _userId),
                      readOnly: true,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: _isTeacher ? 'Faculty ID' : 'Student ID',
                        prefixIcon: const Icon(Icons.badge),
                        filled: true,
                        fillColor: AppTheme.divider.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Email field (read-only)
                    TextField(
                      controller: TextEditingController(text: _userEmail),
                      readOnly: true,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: AppTheme.divider.withValues(alpha: 0.3),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Editable fields section
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Name field
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        errorText: _nameError,
                      ),
                      onChanged: (_) => setState(() => _nameError = null),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    // Initials field (faculty only)
                    if (_isTeacher) ...[
                      TextField(
                        controller: _initialsController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'Initials',
                          prefixIcon: const Icon(Icons.abc),
                          hintText: 'e.g., AKH',
                          errorText: _initialsError,
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() => _initialsError = null),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],

                    // Department dropdown
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedDepartment),
                      initialValue: _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        prefixIcon: const Icon(Icons.business),
                        errorText: _departmentError,
                      ),
                      items: SupabaseService.departments
                          .map(
                            (dept) => DropdownMenuItem(
                              value: dept,
                              child: Text(dept),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDepartment = value;
                          _departmentError = null;
                        });
                      },
                    ),

                    // Faculty-specific fields: Designation and Experience
                    if (_isTeacher) ...[
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildSectionTitle('Professional Information'),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Designation dropdown
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedDesignation),
                        initialValue: _selectedDesignation,
                        decoration: InputDecoration(
                          labelText: 'Designation',
                          prefixIcon: const Icon(Icons.work),
                          errorText: _designationError,
                        ),
                        items: Teacher.designations
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDesignation = value;
                            _designationError = null;
                          });
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Additional Designation (Optional)
                      TextField(
                        controller: _additionalDesignationController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Designation Details',
                          prefixIcon: Icon(Icons.add_circle_outline),
                          hintText: 'e.g., Head of Department, PhD Coordinator',
                          helperText:
                              'Optional - add any additional title or role',
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Research Interest
                      TextField(
                        controller: _researchInterestController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Research Interest / Focus',
                          prefixIcon: const Icon(Icons.psychology),
                          hintText: 'e.g., Machine Learning, Network Security',
                          errorText: _researchInterestError,
                        ),
                        onChanged: (_) =>
                            setState(() => _researchInterestError = null),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Experience field
                      TextField(
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Years of Experience',
                          prefixIcon: const Icon(Icons.work_history),
                          hintText: 'e.g., 5',
                          helperText: 'Teaching/research experience in years',
                          errorText: _experienceError,
                        ),
                        onChanged: (_) =>
                            setState(() => _experienceError = null),
                      ),
                    ],

                    const SizedBox(height: AppTheme.spacingXl * 2),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.onPrimary,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primary,
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      return nameParts[0]
          .substring(0, nameParts[0].length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '';
  }
}

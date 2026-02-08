import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/proposal.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';

/// Create Proposal Screen
/// Premium, responsive design for creating/editing proposals.
class CreateProposalScreen extends StatefulWidget {
  final Proposal? proposal;

  const CreateProposalScreen({super.key, this.proposal});

  @override
  State<CreateProposalScreen> createState() => _CreateProposalScreenState();
}

class _CreateProposalScreenState extends State<CreateProposalScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();

  String? _selectedDepartment;
  bool _isLoading = false;
  bool _isEditing = false;

  String? _titleError;
  String? _departmentError;
  String? _descriptionError;

  String _facultyId = '';
  String _facultyName = '';
  String _facultyInitials = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.proposal != null;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadUserInfo();

    if (_isEditing) {
      _titleController.text = widget.proposal!.title;
      _descriptionController.text = widget.proposal!.description;
      _requirementsController.text = widget.proposal!.requirements;
      _selectedDepartment = widget.proposal!.department;
    }
    _fadeController.forward();
  }

  Future<void> _loadUserInfo() async {
    final session = await UserSession.getInstance();
    setState(() {
      _facultyId = session.userId;
      _facultyName = session.userName;
      _facultyInitials = session.userInitials;
      _selectedDepartment ??= session.userDepartment;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _saveProposal() async {
    setState(() {
      _titleError = null;
      _departmentError = null;
      _descriptionError = null;
    });

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final requirements = _requirementsController.text.trim();

    bool isValid = true;

    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      isValid = false;
    }

    if (_selectedDepartment == null || _selectedDepartment!.isEmpty) {
      setState(() => _departmentError = 'Please select a department');
      isValid = false;
    }

    if (description.isEmpty) {
      setState(() => _descriptionError = 'Description is required');
      isValid = false;
    } else if (description.length < 50) {
      setState(
        () => _descriptionError = 'Description must be at least 50 characters',
      );
      isValid = false;
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      bool success;

      if (_isEditing) {
        final updatedProposal = Proposal.withId(
          id: widget.proposal!.id,
          facultyId: _facultyId,
          facultyInitials: _facultyInitials,
          facultyName: _facultyName,
          title: title,
          description: description,
          department: _selectedDepartment!,
          requirements: requirements,
          createdAt: widget.proposal!.createdAt,
        );
        success = await SupabaseService.updateProposal(updatedProposal);
      } else {
        final newProposal = Proposal(
          facultyId: _facultyId,
          facultyInitials: _facultyInitials,
          facultyName: _facultyName,
          title: title,
          description: description,
          department: _selectedDepartment!,
          requirements: requirements,
        );
        success = await SupabaseService.createProposal(newProposal);
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Proposal updated successfully'
                    : 'Proposal created successfully',
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save proposal')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 900;
            final isTablet =
                constraints.maxWidth > 600 && constraints.maxWidth <= 900;

            return FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(isWideScreen, isTablet),
                  ),
                  // Form
                  SliverToBoxAdapter(child: _buildForm(isWideScreen, isTablet)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWideScreen, bool isTablet) {
    final horizontalPadding = isWideScreen ? 48.0 : (isTablet ? 32.0 : 20.0);

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Proposal' : 'Create Proposal',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing
                      ? 'Update your research proposal'
                      : 'Share your research opportunity',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: const Icon(
            Icons.close,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isWideScreen, bool isTablet) {
    final horizontalPadding = isWideScreen ? 48.0 : (isTablet ? 32.0 : 20.0);
    final maxWidth = isWideScreen ? 700.0 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          24,
          horizontalPadding,
          40,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildSectionHeader('Proposal Title', Icons.title_rounded),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: _buildInputDecoration(
                  hintText: 'Enter a descriptive title',
                  errorText: _titleError,
                ),
                onChanged: (_) => setState(() => _titleError = null),
              ),

              const SizedBox(height: 24),

              // Department
              _buildSectionHeader('Department', Icons.business_outlined),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedDepartment),
                initialValue: _selectedDepartment,
                decoration: _buildInputDecoration(
                  hintText: 'Select department',
                  errorText: _departmentError,
                ),
                items: SupabaseService.departments
                    .map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                    _departmentError = null;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Description
              _buildSectionHeader('Description', Icons.description_outlined),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                maxLength: 1000,
                decoration: _buildInputDecoration(
                  hintText: 'Describe your research proposal in detail...',
                  errorText: _descriptionError,
                  alignLabelWithHint: true,
                ),
                onChanged: (_) => setState(() => _descriptionError = null),
              ),

              const SizedBox(height: 16),

              // Requirements
              _buildSectionHeader(
                'Requirements (Optional)',
                Icons.checklist_rounded,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _requirementsController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  hintText: 'Skills, experience, or prerequisites...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProposal,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Proposal' : 'Create Proposal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    String? errorText,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      alignLabelWithHint: alignLabelWithHint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
      filled: true,
      fillColor: AppTheme.background,
    );
  }
}

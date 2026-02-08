import 'package:flutter/material.dart';
import '../models/faculty.dart';
import '../services/user_session.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart'; // Add this
import '../screens/faculty_proposals_screen.dart'; // Add this for navigation

/// Premium Route for Faculty Detail with Smooth Animation
class FacultyDetailRoute extends PageRouteBuilder {
  final Faculty faculty;
  final bool initialShowForm;

  FacultyDetailRoute({required this.faculty, this.initialShowForm = false})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withAlpha(120),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FacultyDetailPage(
            faculty: faculty,
            initialShowForm: initialShowForm,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curvedAnimation,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.95,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      );
}

/// Premium Faculty Detail Page - Clean Academic Design
class FacultyDetailPage extends StatefulWidget {
  final Faculty faculty;
  final bool initialShowForm;

  const FacultyDetailPage({
    super.key,
    required this.faculty,
    this.initialShowForm = false,
  });

  @override
  State<FacultyDetailPage> createState() => _FacultyDetailPageState();
}

class _FacultyDetailPageState extends State<FacultyDetailPage>
    with SingleTickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  String _studentId = '';
  String _varsityEmail = '';
  String _studentName = '';
  String? _descriptionError;
  bool _isSubmitting = false;
  bool _showInterestForm = false;
  bool _buttonHovered = false;

  @override
  void initState() {
    super.initState();
    _showInterestForm = widget.initialShowForm;
    _loadUserInfo();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentController.forward();
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      final session = await UserSession.getInstance();
      if (mounted) {
        setState(() {
          _studentId = session.userId;
          _varsityEmail = session.userEmail;
          _studentName = session.userName;
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future<void> _submitInterest() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      setState(() => _descriptionError = 'Please describe your interest');
      return;
    }

    if (description.length < 30) {
      setState(
        () => _descriptionError =
            'Please provide more details (min 30 characters)',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await SupabaseService.createRequest(
        teacherId: widget.faculty.id,
        description: description,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Request sent to ${widget.faculty.name}')),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        setState(() {
          _isSubmitting = false;
          _descriptionError = 'Failed to send request. Please try again.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _descriptionError = 'An error occurred. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 600;

    final dialogWidth = isWideScreen ? 520.0 : screenWidth - 40;
    final maxDialogHeight = screenHeight * 0.88;

    return GestureDetector(
      onTap: _close,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Container(
                    width: dialogWidth,
                    constraints: BoxConstraints(maxHeight: maxDialogHeight),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: _showInterestForm
                                  ? _buildInterestForm()
                                  : _buildFacultyDetails(),
                            ),
                          ),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider.withAlpha(100)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                if (_showInterestForm) ...[
                  GestureDetector(
                    onTap: () => setState(() => _showInterestForm = false),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
                Text(
                  _showInterestForm ? 'Express Interest' : 'Faculty Profile',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _close,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        // Faculty Profile Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withAlpha(200)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _getInitials(widget.faculty.name),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.faculty.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.faculty.designation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.faculty.yearsExperience} Years Experience',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        // Info Cards
        _buildInfoCard(
          'Department',
          widget.faculty.department.toUpperCase(),
          Icons.business_rounded,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Research Focus',
          widget.faculty.researchProject,
          Icons.science_rounded,
        ),
        const SizedBox(height: 12),
        _buildInfoCard('Email', widget.faculty.email, Icons.email_outlined),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to proposals screen
              Navigator.of(context).push(
                SmoothPageRoute(
                  page: FacultyProposalsScreen(
                    facultyId: widget.faculty.id,
                    facultyName: widget.faculty.name,
                    facultyInitials: _getInitials(widget.faculty.name),
                  ),
                ),
              );
            },
            icon: Icon(Icons.list_alt_rounded, size: 20),
            label: Text(
              'View Research Proposals',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: BorderSide(color: AppTheme.primary.withAlpha(100)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to proposals screen
              Navigator.of(context).push(
                SmoothPageRoute(
                  page: FacultyProposalsScreen(
                    facultyId: widget.faculty.id,
                    facultyName: widget.faculty.name,
                    facultyInitials: _getInitials(widget.faculty.name),
                  ),
                ),
              );
            },
            icon: Icon(Icons.list_alt_rounded, size: 20),
            label: Text(
              'View Research Proposals',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: BorderSide(color: AppTheme.primary.withAlpha(100)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        // Student Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildFormInfoRow(
                'Name',
                _studentName.isEmpty ? '...' : _studentName,
              ),
              Divider(height: 20, color: AppTheme.divider.withAlpha(100)),
              _buildFormInfoRow(
                'Student ID',
                _studentId.isEmpty ? '...' : _studentId,
              ),
              Divider(height: 20, color: AppTheme.divider.withAlpha(100)),
              _buildFormInfoRow(
                'Email',
                _varsityEmail.isEmpty ? '...' : _varsityEmail,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Input Fields
        _buildInputField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: 'Optional',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          controller: _emailController,
          label: 'Alternative Email',
          hint: 'Optional',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          controller: _descriptionController,
          label: 'Why are you interested?',
          hint: 'Describe your skills, experience, and motivation...',
          icon: Icons.edit_note_rounded,
          maxLines: 4,
          maxLength: 500,
          error: _descriptionError,
          onChanged: (_) {
            if (_descriptionError != null) {
              setState(() => _descriptionError = null);
            }
          },
        ),
      ],
    );
  }

  Widget _buildFormInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? error,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: error != null
                ? Border.all(color: AppTheme.error, width: 1.5)
                : null,
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 14, top: maxLines > 1 ? 14 : 0),
                child: Icon(icon, color: AppTheme.textSecondary, size: 20),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  onChanged: onChanged,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: maxLines > 1 ? 14 : 16,
                    ),
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 2),
            child: Text(
              error,
              style: const TextStyle(
                color: AppTheme.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.divider.withAlpha(100))),
      ),
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            child: GestureDetector(
              onTap: _close,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Primary Button
          Expanded(
            flex: 2,
            child: MouseRegion(
              onEnter: (_) => setState(() => _buttonHovered = true),
              onExit: (_) => setState(() => _buttonHovered = false),
              child: GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () {
                        if (_showInterestForm) {
                          _submitInterest();
                        } else {
                          setState(() => _showInterestForm = true);
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isSubmitting
                        ? AppTheme.primary.withAlpha(180)
                        : (_buttonHovered
                              ? AppTheme.primaryDark
                              : AppTheme.primary),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _buttonHovered && !_isSubmitting
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(50),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showInterestForm
                                    ? Icons.send_rounded
                                    : Icons.handshake_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _showInterestForm
                                    ? 'Submit Request'
                                    : 'Express Interest',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0].substring(0, 2).toUpperCase();
    }
    return '';
  }
}

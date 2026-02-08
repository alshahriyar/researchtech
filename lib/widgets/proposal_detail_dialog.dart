import 'package:flutter/material.dart';
import '../models/proposal.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';

/// Premium Route for Proposal Detail with Smooth Animation
class ProposalDetailRoute extends PageRouteBuilder {
  final Proposal proposal;
  final String? facultyName;

  ProposalDetailRoute({required this.proposal, this.facultyName})
    : super(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withAlpha(130),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ProposalDetailPage(
            proposal: proposal,
            facultyName: facultyName,
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
                begin: 0.96,
                end: 1.0,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      );
}

/// Proposal Detail Dialog Widget - Premium Clean Design
/// Shows full proposal details with Express Interest functionality.
class ProposalDetailDialog extends StatelessWidget {
  final Proposal proposal;
  final String? facultyName;

  const ProposalDetailDialog({
    super.key,
    required this.proposal,
    this.facultyName,
  });

  @override
  Widget build(BuildContext context) {
    // Redirect to the new route-based implementation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      Navigator.of(
        context,
      ).push(ProposalDetailRoute(proposal: proposal, facultyName: facultyName));
    });
    return const SizedBox.shrink();
  }
}

/// Premium Proposal Detail Page - Clean Academic Design
class ProposalDetailPage extends StatefulWidget {
  final Proposal proposal;
  final String? facultyName;

  const ProposalDetailPage({
    super.key,
    required this.proposal,
    this.facultyName,
  });

  @override
  State<ProposalDetailPage> createState() => _ProposalDetailPageState();
}

class _ProposalDetailPageState extends State<ProposalDetailPage>
    with SingleTickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();

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
    _contentController.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context).pop();
  }

  void _submitInterest() {
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

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
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
                Expanded(
                  child: Text('Interest sent for "${widget.proposal.title}"'),
                ),
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
      }
    });
  }

  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isWideScreen = screenWidth > 600;

    final dialogWidth = isWideScreen ? 580.0 : screenWidth - 32;
    final maxDialogHeight = screenHeight * 0.9;

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
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
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
                              child: _showInterestForm
                                  ? _buildInterestForm()
                                  : _buildProposalDetails(),
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
          bottom: BorderSide(color: AppTheme.divider.withAlpha(80)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primary.withAlpha(200)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.science_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Title and back
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_showInterestForm)
                  GestureDetector(
                    onTap: () => setState(() => _showInterestForm = false),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 14,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back to Details',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Text(
                  _showInterestForm ? 'Express Interest' : 'Research Proposal',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Close button
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

  Widget _buildProposalDetails() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Proposal Title
          Text(
            widget.proposal.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          // Tags
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildTag(
                widget.proposal.department,
                AppTheme.primary,
                Icons.business_rounded,
              ),
              _buildTag(
                widget.facultyName ?? widget.proposal.facultyName,
                const Color(0xFF43A047),
                Icons.person_outline_rounded,
              ),
              _buildTag(
                _formatDate(widget.proposal.createdAt),
                AppTheme.textSecondary,
                Icons.calendar_today_outlined,
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Description Section
          _buildSection(
            'Description',
            widget.proposal.description,
            Icons.article_outlined,
          ),
          // Requirements Section
          if (widget.proposal.requirements.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSection(
              'Requirements',
              widget.proposal.requirements,
              Icons.checklist_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Proposal Reference
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withAlpha(25)),
            ),
            child: Row(
              children: [
                Icon(Icons.science_outlined, size: 20, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.proposal.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Student Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
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
            hint: 'Optional contact number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildFormInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
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
        border: Border(top: BorderSide(color: AppTheme.divider.withAlpha(80))),
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
                                    : Icons.favorite_outline_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _showInterestForm
                                    ? 'Submit Interest'
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
}

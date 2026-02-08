import 'package:flutter/material.dart';
import '../models/faculty.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';

/// Interest Dialog Widget
/// Bottom sheet dialog for students to express interest in faculty research.
class InterestDialog extends StatefulWidget {
  final Faculty faculty;

  const InterestDialog({super.key, required this.faculty});

  @override
  State<InterestDialog> createState() => _InterestDialogState();
}

class _InterestDialogState extends State<InterestDialog> {
  final _extraPhoneController = TextEditingController();
  final _extraEmailController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _studentId;
  String? _varsityEmail;
  String? _descriptionError;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final session = await UserSession.getInstance();
    if (mounted) {
      setState(() {
        _studentId = session.userId;
        _varsityEmail = session.userEmail;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _extraPhoneController.dispose();
    _extraEmailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitInterest() {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      setState(() => _descriptionError = 'Please provide a brief description');
      return;
    }

    if (description.length < 50) {
      setState(
        () => _descriptionError = 'Description must be at least 50 characters',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Interest request sent to ${widget.faculty.name}'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLg,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'Express Interest',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            'Connect with ${widget.faculty.name}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          // Student Info Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Information',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: AppTheme.spacingSm),
                                _buildInfoRow('Student ID:', _studentId ?? ''),
                                const SizedBox(height: AppTheme.spacingXs),
                                _buildInfoRow(
                                  'Varsity Email:',
                                  _varsityEmail ?? '',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          // Extra Phone (Optional)
                          TextField(
                            controller: _extraPhoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Extra Phone Number',
                              hintText: 'Enter an optional phone number',
                              helperText: 'Optional',
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          // Extra Email (Optional)
                          TextField(
                            controller: _extraEmailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Extra Email',
                              hintText: 'Enter an optional email',
                              helperText: 'Optional',
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          // Description (Required)
                          TextField(
                            controller: _descriptionController,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: InputDecoration(
                              labelText: 'Brief Description',
                              hintText:
                                  'Describe your interest and background...',
                              alignLabelWithHint: true,
                              errorText: _descriptionError,
                            ),
                            onChanged: (_) =>
                                setState(() => _descriptionError = null),
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacingMd),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _submitInterest,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.onPrimary,
                                          ),
                                        )
                                      : const Text('Send Request'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

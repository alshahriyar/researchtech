import 'package:flutter/material.dart';
import '../models/request.dart';
import '../models/student.dart'; // Add this
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

class FacultyRequestsScreen extends StatefulWidget {
  const FacultyRequestsScreen({super.key});

  @override
  State<FacultyRequestsScreen> createState() => _FacultyRequestsScreenState();
}

class _FacultyRequestsScreenState extends State<FacultyRequestsScreen> {
  bool _isLoading = true; // Restore
  List<Request> _requests = []; // Restore
  Map<String, Student> _studentCache = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final requests = await SupabaseService.getRequestsForTeacher();

    // Clear cache to ensure fresh data
    _studentCache.clear();

    // Fetch student details
    for (var req in requests) {
      if (!_studentCache.containsKey(req.studentId)) {
        // Here req.studentId is actually the Auth User ID based on how we create requests
        final student = await SupabaseService.getStudentByAuthId(req.studentId);
        if (student != null) {
          _studentCache[req.studentId] = student;
        }
      }
    }

    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(Request request, String newStatus) async {
    final success = await SupabaseService.updateRequestStatus(
      request.id,
      newStatus,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request marked as $newStatus'),
          backgroundColor: AppTheme.success,
        ),
      );
      _loadRequests();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update status'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  void _showStudentDetails(Student? student) {
    if (student == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withAlpha(20),
                  border: Border.all(
                    color: AppTheme.primary.withAlpha(50),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name & Dept
              Text(
                student.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                student.department,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Details
              _buildDetailRow(
                Icons.badge_outlined,
                'Student ID',
                student.studentId,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.email_outlined,
                'Varsity Email',
                student.varsityEmail,
              ),
              if (student.extraEmail.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.alternate_email,
                  'Alt. Email',
                  student.extraEmail,
                ),
              ],
              if (student.extraPhone.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.phone_outlined,
                  'Phone',
                  student.extraPhone,
                ),
              ],
              const SizedBox(height: 32),
              // Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppTheme.textHint),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Student Requests',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildRequestCard(_requests[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppTheme.textSecondary.withAlpha(100),
          ),
          const SizedBox(height: 16),
          Text(
            'No requests yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Student interests will appear here',
            style: TextStyle(fontSize: 14, color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Request request) {
    final isPending = request.status == 'pending';
    final student = _studentCache[request.studentId];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.studentName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Avatar Icon
                              GestureDetector(
                                onTap: () => _showStudentDetails(student),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${request.studentDepartment} • ${request.studentEmail}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          // Extra contact info
                          if (student != null) ...[
                            if (student.extraPhone.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Phone: ${student.extraPhone}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            if (student.extraEmail.isNotEmpty &&
                                student.extraEmail != student.varsityEmail)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Alt Email: ${student.extraEmail}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(request.status).withAlpha(100),
                        ),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(request.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Message:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sent on ${_formatDate(request.createdAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          if (isPending)
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(request, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: BorderSide(color: AppTheme.error.withAlpha(100)),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(request, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

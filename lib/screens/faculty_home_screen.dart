import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/proposal.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import '../widgets/proposal_card.dart';
import '../widgets/proposal_detail_dialog.dart';
import 'create_proposal_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

/// Faculty Home Screen
/// Premium dashboard with elegant design, responsive layout, and refined aesthetics.
class FacultyHomeScreen extends StatefulWidget {
  const FacultyHomeScreen({super.key});

  @override
  State<FacultyHomeScreen> createState() => _FacultyHomeScreenState();
}

class _FacultyHomeScreenState extends State<FacultyHomeScreen>
    with SingleTickerProviderStateMixin {
  List<Proposal> _proposals = [];
  String _userName = '';
  String _userId = '';
  String _userInitials = '';

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
    _loadUserInfo();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final session = await UserSession.getInstance();
    if (mounted) {
      setState(() {
        _userName = session.userName;
        _userId = session.userId;
        _userInitials = session.userInitials;
      });
      _loadProposals();
      _fadeController.forward();
    }
  }

  Future<void> _loadProposals() async {
    if (_userId.isEmpty) return;
    final proposals = await SupabaseService.getProposalsByFacultyId(_userId);
    if (mounted) {
      setState(() {
        _proposals = proposals;
      });
    }
  }

  Future<void> _logout() async {
    final session = await UserSession.getInstance();
    await session.logout();

    // Also sign out from Supabase
    try {
      await SupabaseService.signOut();
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _editProfile() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    if (result == true) {
      _loadUserInfo();
    }
  }

  void _createProposal() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const CreateProposalScreen()),
    );
    if (result == true) {
      _loadProposals();
    }
  }

  void _editProposal(Proposal proposal) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateProposalScreen(proposal: proposal),
      ),
    );
    if (result == true) {
      _loadProposals();
    }
  }

  void _showProposalDetail(Proposal proposal) {
    Navigator.of(context).push(ProposalDetailRoute(proposal: proposal));
  }

  void _deleteProposal(Proposal proposal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Proposal'),
        content: const Text(
          'Are you sure you want to delete this proposal? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await SupabaseService.deleteProposal(proposal.id);
              if (mounted) {
                Navigator.of(context).pop();
                _loadProposals();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Proposal deleted successfully'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                  // Custom App Bar
                  SliverToBoxAdapter(
                    child: _buildHeader(isWideScreen, isTablet),
                  ),
                  // Stats Section
                  SliverToBoxAdapter(child: _buildStatsSection(isWideScreen)),
                  // Section Title
                  SliverToBoxAdapter(child: _buildSectionTitle(isWideScreen)),
                  // Proposals Grid/List
                  _proposals.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : _buildProposalsSliver(isWideScreen, isTablet),
                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader(bool isWideScreen, bool isTablet) {
    final horizontalPadding = isWideScreen ? 48.0 : (isTablet ? 32.0 : 20.0);

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        24,
        horizontalPadding,
        16,
      ),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: _editProfile,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _userInitials.isNotEmpty
                      ? _userInitials
                      : _getInitials(_userName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userName.isNotEmpty ? _userName.split(' ').first : 'Faculty',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Action buttons
          if (isWideScreen) ...[
            _buildHeaderButton(
              icon: Icons.add_rounded,
              label: 'New Proposal',
              onTap: _createProposal,
              isPrimary: true,
            ),
            const SizedBox(width: 12),
          ],
          _buildIconButton(Icons.person_outline_rounded, _editProfile),
          const SizedBox(width: 8),
          _buildIconButton(Icons.logout_rounded, _logout),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary ? AppTheme.primary : AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(color: AppTheme.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary ? Colors.white : AppTheme.textPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Icon(icon, size: 20, color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isWideScreen) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.science_outlined,
              value: '${_proposals.length}',
              label: 'Research Proposals',
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_outline_rounded,
              value:
                  '${_proposals.fold(0, (sum, p) => sum + (p.requirements.isNotEmpty ? 1 : 0))}',
              label: 'Active Projects',
              color: const Color(0xFF43A047),
            ),
          ),
          if (isWideScreen) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up_rounded,
                value: _proposals.isNotEmpty ? 'Active' : 'Start',
                label: 'Research Status',
                color: const Color(0xFF7B1FA2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(bool isWideScreen) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        28,
        horizontalPadding,
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'My Proposals',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '${_proposals.length} total',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsSliver(bool isWideScreen, bool isTablet) {
    final horizontalPadding = isWideScreen ? 44.0 : (isTablet ? 28.0 : 16.0);
    final cardWidth = isWideScreen
        ? 380.0
        : (isTablet ? 340.0 : double.infinity);

    if (isWideScreen || isTablet) {
      // Wrap layout for wide screens - uses intrinsic heights
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _proposals.map((proposal) {
              return SizedBox(
                width: cardWidth,
                child: ProposalCard(
                  proposal: proposal,
                  showActions: true,
                  onEdit: () => _editProposal(proposal),
                  onDelete: () => _deleteProposal(proposal),
                  onTap: () => _showProposalDetail(proposal),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    // List layout for mobile
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final proposal = _proposals[index];
          return ProposalCard(
            proposal: proposal,
            showActions: true,
            onEdit: () => _editProposal(proposal),
            onDelete: () => _deleteProposal(proposal),
            onTap: () => _showProposalDetail(proposal),
          );
        }, childCount: _proposals.length),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.science_outlined,
                size: 48,
                color: AppTheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Proposals Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first research proposal\nto connect with interested students',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createProposal,
              icon: const Icon(Icons.add),
              label: const Text('Create Proposal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hide FAB on wide screens since we have button in header
        if (MediaQuery.of(context).size.width > 900) {
          return const SizedBox.shrink();
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _createProposal,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Proposal'),
            elevation: 0,
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}

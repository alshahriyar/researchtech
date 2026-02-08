import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/proposal.dart';
import '../theme/app_theme.dart';
import '../widgets/proposal_card.dart';
import '../widgets/proposal_detail_dialog.dart';

/// Faculty Proposals Screen
/// Premium, responsive view of a faculty member's proposals for students.
class FacultyProposalsScreen extends StatefulWidget {
  final String facultyId;
  final String facultyName;
  final String facultyInitials;

  const FacultyProposalsScreen({
    super.key,
    required this.facultyId,
    required this.facultyName,
    required this.facultyInitials,
  });

  @override
  State<FacultyProposalsScreen> createState() => _FacultyProposalsScreenState();
}

class _FacultyProposalsScreenState extends State<FacultyProposalsScreen>
    with SingleTickerProviderStateMixin {
  List<Proposal> _proposals = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadProposals();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadProposals() async {
    final proposals = await SupabaseService.getProposalsByFacultyId(
      widget.facultyId,
    );
    if (mounted) {
      setState(() {
        _proposals = proposals;
      });
      _fadeController.forward();
    }
  }

  void _showProposalDetail(Proposal proposal) {
    Navigator.of(context).push(
      ProposalDetailRoute(proposal: proposal, facultyName: widget.facultyName),
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
                  // Faculty Info Card
                  SliverToBoxAdapter(child: _buildFacultyCard(isWideScreen)),
                  // Section Title
                  SliverToBoxAdapter(child: _buildSectionTitle(isWideScreen)),
                  // Proposals
                  _proposals.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : _buildProposalsSliver(isWideScreen, isTablet),
                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
            child: Text(
              widget.facultyInitials,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
            Icons.arrow_back,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyCard(bool isWideScreen) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary.withValues(alpha: 0.08),
              const Color(0xFF43A047).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
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
                  widget.facultyInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.facultyName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_proposals.length} Proposal${_proposals.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(bool isWideScreen) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        24,
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
            'Research Proposals',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            'Tap to view details',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildProposalsSliver(bool isWideScreen, bool isTablet) {
    final horizontalPadding = isWideScreen ? 44.0 : (isTablet ? 28.0 : 16.0);
    final cardWidth = isWideScreen
        ? 400.0
        : (isTablet ? 350.0 : double.infinity);

    if (isWideScreen || isTablet) {
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
                  showActions: false,
                  onTap: () => _showProposalDetail(proposal),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final proposal = _proposals[index];
          return ProposalCard(
            proposal: proposal,
            showActions: false,
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
              'This faculty has not posted any\nresearch proposals yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

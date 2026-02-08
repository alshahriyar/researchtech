import 'package:flutter/material.dart';
import '../models/proposal.dart';
import '../theme/app_theme.dart';

/// Premium Proposal Card - Clean Academic Design
class ProposalCard extends StatefulWidget {
  final Proposal proposal;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onInterest; // Add this

  const ProposalCard({
    super.key,
    required this.proposal,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onInterest, // Add this
  });

  @override
  State<ProposalCard> createState() => _ProposalCardState();
}

class _ProposalCardState extends State<ProposalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.primary.withAlpha(40)
                  : AppTheme.divider.withAlpha(100),
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? AppTheme.primary.withAlpha(12)
                    : Colors.black.withAlpha(8),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with title and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.proposal.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Tags row
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildTag(
                              widget.proposal.department,
                              AppTheme.primary,
                            ),
                            _buildTag(
                              widget.proposal.facultyInitials,
                              AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.showActions) ...[
                    const SizedBox(width: 8),
                    _buildActionButtons(),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              // Description
              Text(
                widget.proposal.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Requirements section
              if (widget.proposal.requirements.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildRequirements(),
              ],
              if (widget.onInterest != null) ...[
                const SizedBox(height: 16),
                _buildConnectButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectButton() {
    return MouseRegion(
      onEnter: (_) =>
          setState(() => _isHovered = true), // Reuse hover state or add new one
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onInterest,
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(50),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.handshake_outlined,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Text(
                'Express Interest',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.checklist_rounded,
              size: 14,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requirements',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.proposal.requirements,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.4,
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

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: AppTheme.primary,
          onTap: widget.onEdit,
        ),
        const SizedBox(width: 6),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: AppTheme.error,
          onTap: widget.onDelete,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/faculty_repository.dart';
import '../models/faculty.dart';
import '../theme/app_theme.dart';
import '../widgets/faculty_card.dart';
import '../widgets/faculty_detail_dialog.dart';

/// Faculty List Screen with Premium Design and Entrance Animation
class FacultyListScreen extends StatefulWidget {
  final String department;

  const FacultyListScreen({super.key, required this.department});

  @override
  State<FacultyListScreen> createState() => _FacultyListScreenState();
}

class _FacultyListScreenState extends State<FacultyListScreen>
    with SingleTickerProviderStateMixin {
  List<Faculty> _facultyList = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );
    _loadFaculty();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadFaculty() {
    final faculty = FacultyRepository.getFacultyByDepartment(widget.department);
    setState(() {
      _facultyList = faculty;
    });
    // Start entrance animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  void _showFacultyDetail(Faculty faculty, {bool showForm = false}) {
    Navigator.of(
      context,
    ).push(FacultyDetailRoute(faculty: faculty, initialShowForm: showForm));
  }

  String _getDepartmentFullName(String code) {
    switch (code.toUpperCase()) {
      case 'CSE':
        return 'Computer Science & Engineering';
      case 'SWE':
        return 'Software Engineering';
      case 'BBA':
        return 'Business Administration';
      case 'LAW':
        return 'Law & Legal Studies';
      default:
        return code;
    }
  }

  Color _getDepartmentColor(String code) {
    switch (code.toUpperCase()) {
      case 'CSE':
        return AppTheme.cseColor;
      case 'SWE':
        return AppTheme.sweColor;
      case 'BBA':
        return AppTheme.bbaColor;
      case 'LAW':
        return AppTheme.lawColor;
      default:
        return AppTheme.primary;
    }
  }

  IconData _getDepartmentIcon(String code) {
    switch (code.toUpperCase()) {
      case 'CSE':
        return Icons.computer_rounded;
      case 'SWE':
        return Icons.code_rounded;
      case 'BBA':
        return Icons.business_rounded;
      case 'LAW':
        return Icons.gavel_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 900;
                final isTablet =
                    constraints.maxWidth > 600 && constraints.maxWidth <= 900;

                return CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(isWideScreen, isTablet),
                    ),
                    // Department Info Card
                    SliverToBoxAdapter(
                      child: _buildDepartmentCard(isWideScreen),
                    ),
                    // Section Title
                    SliverToBoxAdapter(child: _buildSectionTitle(isWideScreen)),
                    // Faculty List
                    _facultyList.isEmpty
                        ? SliverFillRemaining(child: _buildEmptyState())
                        : _buildFacultySliver(isWideScreen, isTablet),
                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                );
              },
            ),
          ),
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
              widget.department,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider.withAlpha(128)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 22,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(bool isWideScreen) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;
    final deptColor = _getDepartmentColor(widget.department);

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 8),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [deptColor.withAlpha(25), deptColor.withAlpha(10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: deptColor.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [deptColor.withAlpha(38), deptColor.withAlpha(20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getDepartmentIcon(widget.department),
                color: deptColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDepartmentFullName(widget.department),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: deptColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_facultyList.length} Faculty Member${_facultyList.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: deptColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
        28,
        horizontalPadding,
        16,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getDepartmentColor(widget.department),
                  _getDepartmentColor(widget.department).withAlpha(150),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Faculty Members',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultySliver(bool isWideScreen, bool isTablet) {
    final horizontalPadding = isWideScreen ? 44.0 : (isTablet ? 28.0 : 16.0);
    final cardWidth = isWideScreen
        ? 380.0
        : (isTablet ? 340.0 : double.infinity);

    if (isWideScreen || isTablet) {
      // Wrap layout for wide screens
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _facultyList.map((faculty) {
              return SizedBox(
                width: cardWidth,
                child: FacultyCard(
                  faculty: faculty,
                  onConnect: () => _showFacultyDetail(faculty, showForm: true),
                  onTap: () => _showFacultyDetail(faculty, showForm: false),
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
          final faculty = _facultyList[index];
          return FacultyCard(
            faculty: faculty,
            onConnect: () => _showFacultyDetail(faculty, showForm: true),
            onTap: () => _showFacultyDetail(faculty, showForm: false),
          );
        }, childCount: _facultyList.length),
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
                color: _getDepartmentColor(widget.department).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_outlined,
                size: 48,
                color: _getDepartmentColor(widget.department).withAlpha(153),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Faculty Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This department doesn\'t have any\nregistered faculty members yet',
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

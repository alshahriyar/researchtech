import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/user_session.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/department_card.dart';
import '../widgets/logo.dart';
import 'faculty_proposals_screen.dart';
import 'department_proposals_screen.dart'; // Added
import 'student_requests_screen.dart'; // Added
import 'edit_profile_screen.dart';
import 'login_screen.dart';

/// Home Screen for Students
/// Premium dashboard with elegant design and refined aesthetics.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _userName = '';
  String _userDepartment = '';

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

  Future<void> _loadUserInfo() async {
    final session = await UserSession.getInstance();
    if (mounted) {
      setState(() {
        _userName = session.userName;
        _userDepartment = session.userDepartment;
      });
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
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
    final result = await Navigator.of(
      context,
    ).push<bool>(SmoothPageRoute(page: const EditProfileScreen()));
    if (result == true) {
      _loadUserInfo();
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Search by initials from Supabase
    final faculty = await SupabaseService.getTeacherByInitials(query);

    if (mounted) {
      if (faculty != null) {
        Navigator.of(context).push(
          SmoothPageRoute(
            page: FacultyProposalsScreen(
              facultyId: faculty.teacherId,
              facultyName: faculty.name,
              facultyInitials: faculty.initials,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No faculty found with those initials'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _navigateToFacultyList(String department) {
    Navigator.of(context).push(
      SmoothPageRoute(page: DepartmentProposalsScreen(department: department)),
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
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: const Logo(size: 28),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildHeader(isWideScreen, isTablet),
                  ),
                  // Quick Stats
                  SliverToBoxAdapter(child: _buildQuickStats(isWideScreen)),
                  // Search Section
                  SliverToBoxAdapter(child: _buildSearchSection(isWideScreen)),
                  // Departments Section
                  SliverToBoxAdapter(
                    child: _buildDepartmentsSection(isWideScreen, isTablet),
                  ),
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
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF43A047).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(_userName),
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
                  'Hello,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userName.isNotEmpty ? _userName.split(' ').first : 'Student',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Action buttons
          _buildIconButton(Icons.person_outline_rounded, _editProfile),
          const SizedBox(width: 8),
          _buildIconButton(Icons.notifications_outlined, () {
            Navigator.of(
              context,
            ).push(SmoothPageRoute(page: const StudentRequestsScreen()));
          }),
          const SizedBox(width: 8),
          _buildIconButton(Icons.logout_rounded, _logout),
        ],
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

  Widget _buildQuickStats(bool isWideScreen) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;
    final departmentCount = SupabaseService.departments.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.school_outlined,
              value: _userDepartment.isNotEmpty ? _userDepartment : 'N/A',
              label: 'Your Department',
              color: const Color(0xFF43A047),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.business_outlined,
              value: '$departmentCount',
              label: 'Departments',
              color: AppTheme.primary,
            ),
          ),
          if (isWideScreen) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.explore_outlined,
                value: 'Explore',
                label: 'Research Areas',
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

  Widget _buildSearchSection(bool isWideScreen) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Faculty',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Search by faculty initials to view their proposals',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchField(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          hintText: 'Enter initials (e.g., AKH)',
          hintStyle: TextStyle(color: AppTheme.textHint),
          prefixIcon: const Icon(
            Icons.person_search_outlined,
            color: AppTheme.textSecondary,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _performSearch,
            ),
          ),
          filled: true,
          fillColor: AppTheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.divider.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
          ),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildDepartmentsSection(bool isWideScreen, bool isTablet) {
    final horizontalPadding = isWideScreen ? 48.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 28, horizontalPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Explore Departments',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'Browse faculty research by department',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 20),
          // Department cards
          _buildDepartmentGrid(isWideScreen, isTablet),
        ],
      ),
    );
  }

  Widget _buildDepartmentGrid(bool isWideScreen, bool isTablet) {
    final departments = [
      {
        'title': 'CSE',
        'subtitle': 'Computer Science & Engineering',
        'icon': Icons.computer,
        'color': AppTheme.cseColor,
      },
      {
        'title': 'SWE',
        'subtitle': 'Software Engineering',
        'icon': Icons.code,
        'color': AppTheme.sweColor,
      },
      {
        'title': 'BBA',
        'subtitle': 'Business Administration',
        'icon': Icons.business,
        'color': AppTheme.bbaColor,
      },
      {
        'title': 'Law',
        'subtitle': 'Law & Legal Studies',
        'icon': Icons.gavel,
        'color': AppTheme.lawColor,
      },
    ];

    int columns = isWideScreen ? 4 : (isTablet ? 3 : 2);
    double aspectRatio = isWideScreen ? 1.1 : (isTablet ? 1.0 : 0.95);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        final dept = departments[index];
        return DepartmentCard(
          title: dept['title'] as String,
          subtitle: dept['subtitle'] as String,
          icon: dept['icon'] as IconData,
          color: dept['color'] as Color,
          onTap: () => _navigateToFacultyList(dept['title'] as String),
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

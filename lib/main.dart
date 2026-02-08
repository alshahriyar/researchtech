import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'services/supabase_service.dart';
import 'services/user_session.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/faculty_home_screen.dart';
import 'screens/pending_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (if configured)
  if (SupabaseConfig.isConfigured) {
    try {
      await SupabaseService.initialize();
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  } else {
    debugPrint(
      'WARNING: Supabase not configured. Please add your credentials to supabase_config.dart',
    );
  }

  // Check login state
  final session = await UserSession.getInstance();

  runApp(ResearchTechApp(session: session));
}

class ResearchTechApp extends StatelessWidget {
  final UserSession session;

  const ResearchTechApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResearchTech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (!session.isLoggedIn) {
      return const LoginScreen();
    }

    if (session.isTeacher) {
      return const FacultyHomeScreen();
    }

    if (!session.isVerified) {
      return const PendingVerificationScreen();
    }

    return const HomeScreen();
  }
}

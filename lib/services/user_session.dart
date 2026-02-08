import 'package:shared_preferences/shared_preferences.dart';

/// UserSession manages the logged-in user state using SharedPreferences.
class UserSession {
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyUserType = 'userType';
  static const String _keyUserId = 'userId';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserName = 'userName';
  static const String _keyUserInitials = 'userInitials';
  static const String _keyUserDepartment = 'userDepartment';
  static const String _keyIsVerified = 'isVerified';

  static const String typeStudent = 'student';
  static const String typeTeacher = 'teacher';

  final SharedPreferences _prefs;

  UserSession._(this._prefs);

  /// Factory method to create UserSession instance
  static Future<UserSession> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return UserSession._(prefs);
  }

  /// Save student session data
  Future<void> saveStudentSession({
    required String studentId,
    required String email,
    required String name,
    required String department,
    required bool isVerified,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserType, typeStudent);
    await _prefs.setString(_keyUserId, studentId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserDepartment, department);
    await _prefs.setBool(_keyIsVerified, isVerified);
  }

  /// Save teacher/faculty session data
  Future<void> saveTeacherSession({
    required String teacherId,
    required String email,
    required String name,
    required String initials,
    required String department,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserType, typeTeacher);
    await _prefs.setString(_keyUserId, teacherId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserInitials, initials);
    await _prefs.setString(_keyUserDepartment, department);
    await _prefs.setBool(_keyIsVerified, true); // Faculty are always verified
  }

  /// Check if user is logged in
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  /// Get the user type (student or teacher)
  String get userType => _prefs.getString(_keyUserType) ?? '';

  /// Check if current user is a student
  bool get isStudent => userType == typeStudent;

  /// Check if current user is a teacher/faculty
  bool get isTeacher => userType == typeTeacher;

  /// Get user ID
  String get userId => _prefs.getString(_keyUserId) ?? '';

  /// Get user email
  String get userEmail => _prefs.getString(_keyUserEmail) ?? '';

  /// Get user name
  String get userName => _prefs.getString(_keyUserName) ?? '';

  /// Get user initials (for faculty)
  String get userInitials => _prefs.getString(_keyUserInitials) ?? '';

  /// Get user department
  String get userDepartment => _prefs.getString(_keyUserDepartment) ?? '';

  /// Check if user account is verified
  bool get isVerified => _prefs.getBool(_keyIsVerified) ?? false;

  /// Clear session data (logout)
  Future<void> logout() async {
    await _prefs.clear();
  }
}

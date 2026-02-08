/// Student data model representing a registered student user.
/// Student ID and varsity email are immutable after registration.
class Student {
  final String authUserId; // Supabase Auth User ID
  final String studentId;
  final String varsityEmail;
  String name;
  String password;
  String department;
  String extraPhone;
  String extraEmail;
  bool isVerified;

  Student({
    required this.authUserId,
    required this.studentId,
    required this.varsityEmail,
    required this.name,
    required this.password,
    required this.department,
    this.extraPhone = '',
    this.extraEmail = '',
    this.isVerified = false,
  });

  /// Validates if the email ends with @diu.edu.bd
  static bool isValidVarsityEmail(String email) {
    return email.toLowerCase().endsWith('@diu.edu.bd');
  }

  /// Create Student from Supabase JSON response
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      authUserId: json['auth_user_id'] ?? '',
      studentId: json['student_id'] ?? '',
      varsityEmail: json['varsity_email'] ?? '',
      name: json['name'] ?? '',
      password: '', // Password is not stored in the response
      department: json['department'] ?? '',
      extraPhone: json['extra_phone'] ?? '',
      extraEmail: json['extra_email'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'auth_user_id': authUserId,
      'student_id': studentId,
      'varsity_email': varsityEmail.toLowerCase(),
      'name': name,
      'department': department,
      'extra_phone': extraPhone,
      'extra_email': extraEmail,
      'is_verified': isVerified,
    };
  }
}

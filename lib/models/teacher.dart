/// Teacher/Faculty data model representing a registered faculty user.
class Teacher {
  final String authUserId; // Supabase Auth User ID
  final String teacherId;
  String email;
  String name;
  String password;
  String department;
  String initials;
  String designation;
  String researchInterest; // Primary research area/focus
  String additionalDesignation; // Optional additional designation details
  int experienceYears;

  Teacher({
    required this.authUserId,
    required this.teacherId,
    required this.email,
    required this.name,
    required this.password,
    required this.department,
    required String initials,
    this.designation = 'Lecturer',
    this.researchInterest = 'General Research',
    this.additionalDesignation = '',
    this.experienceYears = 0,
  }) : initials = initials.toUpperCase();

  /// Get full designation including additional details
  String get fullDesignation {
    if (additionalDesignation.isEmpty) return designation;
    return '$designation ($additionalDesignation)';
  }

  /// Common faculty designations
  static const List<String> designations = [
    'Lecturer',
    'Senior Lecturer',
    'Assistant Professor',
    'Associate Professor',
    'Professor',
  ];

  /// Create Teacher from Supabase JSON response
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      authUserId: json['auth_user_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      password: '', // Password is not stored in the response
      department: json['department'] ?? '',
      initials: json['initials'] ?? '',
      designation: json['designation'] ?? 'Lecturer',
      researchInterest: json['research_interest'] ?? 'General Research',
      additionalDesignation: json['additional_designation'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'email': email.toLowerCase(),
      'name': name,
      'department': department,
      'initials': initials.toUpperCase(),
      'designation': designation,
      'research_interest': researchInterest,
      'additional_designation': additionalDesignation,
      'experience_years': experienceYears,
    };
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../models/proposal.dart';
import '../models/request.dart';

/// Supabase service handling all database and authentication operations.
/// Replaces the in-memory DummyDataProvider with real cloud database.
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  /// Department list (kept from original app)
  static const List<String> departments = [
    'CSE',
    'SWE',
    'BBA',
    'Law',
    'EEE',
    'Civil',
    'Pharmacy',
  ];

  static const List<String> departmentFullNames = [
    'Computer Science & Engineering',
    'Software Engineering',
    'Business Administration',
    'Law',
    'Electrical & Electronic Engineering',
    'Civil Engineering',
    'Pharmacy',
  ];

  /// Initialize Supabase - call this in main.dart
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase is not configured! Please add your credentials to supabase_config.dart',
      );
    }
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  /// Check if Supabase is configured
  static bool get isConfigured => SupabaseConfig.isConfigured;

  /// Get current authenticated user
  static User? get currentUser => _client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // ========== Authentication ==========

  /// Sign up a new student
  static Future<AuthResponse> signUpStudent({
    required String email,
    required String password,
    required String studentId,
    required String name,
    required String department,
  }) async {
    // Create auth user
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user != null) {
      // Create student profile
      await _client.from('students').insert({
        'auth_user_id': authResponse.user!.id,
        'student_id': studentId,
        'varsity_email': email.toLowerCase(),
        'name': name,
        'department': department,
        'is_verified': true, // Auto-verify as per user request
      });
    }

    return authResponse;
  }

  /// Sign up a new teacher
  static Future<AuthResponse> signUpTeacher({
    required String email,
    required String password,
    required String teacherId,
    required String name,
    required String department,
    required String initials,
    String designation = 'Lecturer',
    String researchInterest = 'General Research',
    String additionalDesignation = '',
    int experienceYears = 0,
  }) async {
    // Create auth user
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (authResponse.user != null) {
      // Create teacher profile
      await _client.from('teachers').insert({
        'auth_user_id': authResponse.user!.id,
        'teacher_id': teacherId,
        'email': email.toLowerCase(),
        'name': name,
        'department': department,
        'initials': initials.toUpperCase(),
        'designation': designation,
        'research_interest': researchInterest,
        'additional_designation': additionalDesignation,
        'experience_years': experienceYears,
      });
    }

    return authResponse;
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ========== Student Operations ==========

  /// Get student profile by auth user ID
  static Future<Student?> getStudentProfile() async {
    if (currentUser == null) return null;

    final response = await _client
        .from('students')
        .select()
        .eq('auth_user_id', currentUser!.id)
        .maybeSingle();

    if (response == null) return null;
    return Student.fromJson(response);
  }

  /// Get student by email
  static Future<Student?> getStudentByEmail(String email) async {
    final response = await _client
        .from('students')
        .select()
        .eq('varsity_email', email.toLowerCase())
        .maybeSingle();

    if (response == null) return null;
    return Student.fromJson(response);
  }

  /// Check if student email is registered
  static Future<bool> isStudentEmailRegistered(String email) async {
    final response = await _client
        .from('students')
        .select('id')
        .eq('varsity_email', email.toLowerCase())
        .maybeSingle();
    return response != null;
  }

  /// Update student profile
  static Future<bool> updateStudent({
    required String name,
    required String department,
    String extraPhone = '',
    String extraEmail = '',
  }) async {
    if (currentUser == null) return false;

    await _client
        .from('students')
        .update({
          'name': name,
          'department': department,
          'extra_phone': extraPhone,
          'extra_email': extraEmail,
        })
        .eq('auth_user_id', currentUser!.id);

    return true;
  }

  /// Get student by Auth User ID
  static Future<Student?> getStudentByAuthId(String authId) async {
    final response = await _client
        .from('students')
        .select()
        .eq('auth_user_id', authId)
        .maybeSingle();

    if (response == null) return null;
    return Student.fromJson(response);
  }

  /// Get student by ID
  static Future<Student?> getStudentById(String studentId) async {
    final response = await _client
        .from('students')
        .select()
        .eq('student_id', studentId)
        .maybeSingle();

    if (response == null) return null;
    return Student.fromJson(response);
  }

  // ========== Teacher Operations ==========

  /// Get teacher profile by auth user ID
  static Future<Teacher?> getTeacherProfile() async {
    if (currentUser == null) return null;

    final response = await _client
        .from('teachers')
        .select()
        .eq('auth_user_id', currentUser!.id)
        .maybeSingle();

    if (response == null) return null;
    return Teacher.fromJson(response);
  }

  /// Get teacher by Auth User ID
  static Future<Teacher?> getTeacherByAuthId(String authId) async {
    final response = await _client
        .from('teachers')
        .select()
        .eq('auth_user_id', authId)
        .maybeSingle();

    if (response == null) return null;
    return Teacher.fromJson(response);
  }

  /// Get teacher by email
  static Future<Teacher?> getTeacherByEmail(String email) async {
    final response = await _client
        .from('teachers')
        .select()
        .eq('email', email.toLowerCase())
        .maybeSingle();

    if (response == null) return null;
    return Teacher.fromJson(response);
  }

  /// Check if teacher email is registered
  static Future<bool> isTeacherEmailRegistered(String email) async {
    final response = await _client
        .from('teachers')
        .select('id')
        .eq('email', email.toLowerCase())
        .maybeSingle();
    return response != null;
  }

  /// Get teacher by ID
  static Future<Teacher?> getTeacherById(String teacherId) async {
    final response = await _client
        .from('teachers')
        .select()
        .eq('teacher_id', teacherId)
        .maybeSingle();

    if (response == null) return null;
    return Teacher.fromJson(response);
  }

  /// Get teacher by initials
  static Future<Teacher?> getTeacherByInitials(String initials) async {
    final response = await _client
        .from('teachers')
        .select()
        .eq('initials', initials.toUpperCase().trim())
        .maybeSingle();

    if (response == null) return null;
    return Teacher.fromJson(response);
  }

  /// Search teachers by initials or name
  static Future<List<Teacher>> searchTeachers(String query) async {
    final searchQuery = query.toUpperCase().trim();

    final response = await _client
        .from('teachers')
        .select()
        .or('initials.ilike.%$searchQuery%,name.ilike.%$searchQuery%');

    return (response as List).map((json) => Teacher.fromJson(json)).toList();
  }

  /// Get teachers by department
  static Future<List<Teacher>> getTeachersByDepartment(
    String department,
  ) async {
    final response = await _client
        .from('teachers')
        .select()
        .eq('department', department)
        .order('name');

    return (response as List).map((json) => Teacher.fromJson(json)).toList();
  }

  /// Update teacher profile
  static Future<bool> updateTeacher({
    required String name,
    required String initials,
    required String department,
    String? designation,
    String? researchInterest,
    String? additionalDesignation,
    int? experienceYears,
  }) async {
    if (currentUser == null) return false;

    final updates = <String, dynamic>{
      'name': name,
      'initials': initials.toUpperCase(),
      'department': department,
    };

    if (designation != null) updates['designation'] = designation;
    if (researchInterest != null)
      updates['research_interest'] = researchInterest;
    if (additionalDesignation != null) {
      updates['additional_designation'] = additionalDesignation;
    }
    if (experienceYears != null) updates['experience_years'] = experienceYears;

    await _client
        .from('teachers')
        .update(updates)
        .eq('auth_user_id', currentUser!.id);

    return true;
  }

  // ========== Proposal Operations ==========

  /// Create a new proposal
  static Future<bool> createProposal(Proposal proposal) async {
    await _client.from('proposals').insert(proposal.toJson());
    return true;
  }

  /// Update an existing proposal
  static Future<bool> updateProposal(Proposal proposal) async {
    await _client
        .from('proposals')
        .update(proposal.toJsonForUpdate())
        .eq('id', proposal.id);
    return true;
  }

  /// Delete a proposal
  static Future<bool> deleteProposal(String proposalId) async {
    await _client.from('proposals').delete().eq('id', proposalId);
    return true;
  }

  /// Get proposal by ID
  static Future<Proposal?> getProposalById(String proposalId) async {
    final response = await _client
        .from('proposals')
        .select()
        .eq('id', proposalId)
        .maybeSingle();

    if (response == null) return null;
    return Proposal.fromJson(response);
  }

  /// Get all proposals by faculty ID
  static Future<List<Proposal>> getProposalsByFacultyId(
    String facultyId,
  ) async {
    final response = await _client
        .from('proposals')
        .select()
        .eq('faculty_id', facultyId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Proposal.fromJson(json)).toList();
  }

  /// Get proposals by faculty initials
  static Future<List<Proposal>> getProposalsByFacultyInitials(
    String initials,
  ) async {
    final response = await _client
        .from('proposals')
        .select()
        .eq('faculty_initials', initials.toUpperCase().trim())
        .order('created_at', ascending: false);

    return (response as List).map((json) => Proposal.fromJson(json)).toList();
  }

  /// Get all proposals
  static Future<List<Proposal>> getAllProposals() async {
    final response = await _client
        .from('proposals')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => Proposal.fromJson(json)).toList();
  }

  /// Get proposals by department
  static Future<List<Proposal>> getProposalsByDepartment(
    String department,
  ) async {
    final response = await _client
        .from('proposals')
        .select()
        .eq('department', department)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Proposal.fromJson(json)).toList();
  }
  // ========== Request Operations ==========

  /// Create a new request
  static Future<bool> createRequest({
    required String teacherId,
    required String description,
  }) async {
    if (currentUser == null) return false;

    try {
      // Get student info
      final student = await getStudentProfile();
      if (student == null) return false;

      // Get teacher info to get auth user id
      final teacher = await getTeacherById(teacherId);
      if (teacher == null) return false;

      final request = Request(
        id: '', // Generated by DB
        studentId: currentUser!.id,
        teacherId: teacher.authUserId,
        studentName: student.name,
        studentEmail: student.varsityEmail,
        studentDepartment: student.department,
        description: description,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // We exclude 'id' and 'created_at' from toJson if they are auto-generated?
      // Request.toJson() includes them? No, let's check Request.toJson.
      // It includes student_id, teacher_id, student_name...
      // It does NOT include id or created_at. That is correct.

      await _client.from('requests').insert(request.toJson());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get requests for a student
  static Future<List<Request>> getRequestsForStudent() async {
    if (currentUser == null) return [];

    try {
      final response = await _client
          .from('requests')
          .select()
          .eq('student_id', currentUser!.id)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Request.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get requests for a teacher
  static Future<List<Request>> getRequestsForTeacher() async {
    if (currentUser == null) return [];

    try {
      final response = await _client
          .from('requests')
          .select()
          .eq('teacher_id', currentUser!.id)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Request.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Update request status
  static Future<bool> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      await _client
          .from('requests')
          .update({'status': status})
          .eq('id', requestId);
      return true;
    } catch (e) {
      return false;
    }
  }
}

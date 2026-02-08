import '../models/proposal.dart';
import '../models/student.dart';
import '../models/teacher.dart';

/// In-memory data provider for simulating user authentication and data storage.
/// In a real app, this would be replaced with a proper database or API.
class DummyDataProvider {
  static final Map<String, Student> _students = {};
  static final Map<String, Teacher> _teachers = {};
  static final Map<String, Proposal> _proposals = {};

  // Department list
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

  /// Initialize with dummy data
  static void initialize() {
    if (_students.isNotEmpty) return; // Already initialized

    // Pre-register dummy students
    final verifiedStudent = Student(
      studentId: '221-15-5001',
      varsityEmail: 'verified@diu.edu.bd',
      name: 'Verified Student',
      password: 'password123',
      department: 'CSE',
      isVerified: true,
    );
    _students[verifiedStudent.varsityEmail.toLowerCase()] = verifiedStudent;

    final pendingStudent = Student(
      studentId: '221-15-5002',
      varsityEmail: 'pending@diu.edu.bd',
      name: 'Pending Student',
      password: 'password123',
      department: 'SWE',
      isVerified: false,
    );
    _students[pendingStudent.varsityEmail.toLowerCase()] = pendingStudent;

    // Pre-register dummy faculty
    final faculty = Teacher(
      teacherId: 'FAC-001',
      email: 'teacher@diu.edu.bd',
      name: 'Dr. Ahmed Khan',
      password: 'password123',
      department: 'CSE',
      initials: 'AKH',
    );
    _teachers[faculty.email.toLowerCase()] = faculty;

    final faculty2 = Teacher(
      teacherId: 'FAC-002',
      email: 'rahima@diu.edu.bd',
      name: 'Dr. Rahima Begum',
      password: 'password123',
      department: 'SWE',
      initials: 'RB',
    );
    _teachers[faculty2.email.toLowerCase()] = faculty2;

    // Pre-create dummy proposals
    final proposal1 = Proposal(
      facultyId: faculty.teacherId,
      facultyInitials: faculty.initials,
      facultyName: faculty.name,
      title: 'Machine Learning in Healthcare',
      description:
          'Research on applying machine learning algorithms to predict patient outcomes and improve diagnostic accuracy in healthcare settings.',
      department: 'CSE',
      requirements: 'Basic Python knowledge, Interest in ML, 3rd year or above',
    );
    _proposals[proposal1.id] = proposal1;

    final proposal2 = Proposal(
      facultyId: faculty.teacherId,
      facultyInitials: faculty.initials,
      facultyName: faculty.name,
      title: 'IoT-based Smart Agriculture',
      description:
          'Developing IoT solutions for monitoring soil conditions, weather patterns, and automating irrigation systems for sustainable agriculture.',
      department: 'CSE',
      requirements:
          'Arduino/Raspberry Pi experience, Basic electronics, 2nd year or above',
    );
    _proposals[proposal2.id] = proposal2;

    final proposal3 = Proposal(
      facultyId: faculty2.teacherId,
      facultyInitials: faculty2.initials,
      facultyName: faculty2.name,
      title: 'Mobile App Development Best Practices',
      description:
          'Research on modern mobile development architectures, UI/UX patterns, and performance optimization techniques for Android and iOS.',
      department: 'SWE',
      requirements:
          'Android/iOS development experience, Java/Kotlin/Swift knowledge',
    );
    _proposals[proposal3.id] = proposal3;
  }

  // ========== Student Operations ==========

  static bool registerStudent(Student student) {
    final email = student.varsityEmail.toLowerCase();
    if (_students.containsKey(email)) {
      return false;
    }
    _students[email] = student;
    return true;
  }

  static Student? authenticateStudent(String email, String password) {
    final student = _students[email.toLowerCase()];
    if (student != null && student.password == password) {
      return student;
    }
    return null;
  }

  static bool isStudentEmailRegistered(String email) {
    return _students.containsKey(email.toLowerCase());
  }

  static bool updateStudent(
    String email, {
    required String name,
    required String department,
  }) {
    final key = email.toLowerCase();
    final student = _students[key];
    if (student == null) return false;

    _students[key] = Student(
      studentId: student.studentId,
      varsityEmail: student.varsityEmail,
      name: name,
      password: student.password,
      department: department,
      isVerified: student.isVerified,
    );
    return true;
  }

  // ========== Faculty/Teacher Operations ==========

  static bool registerTeacher(Teacher teacher) {
    final email = teacher.email.toLowerCase();
    if (_teachers.containsKey(email)) {
      return false;
    }
    _teachers[email] = teacher;
    return true;
  }

  static Teacher? authenticateTeacher(String email, String password) {
    final teacher = _teachers[email.toLowerCase()];
    if (teacher != null && teacher.password == password) {
      return teacher;
    }
    return null;
  }

  static bool isTeacherEmailRegistered(String email) {
    return _teachers.containsKey(email.toLowerCase());
  }

  static bool updateTeacher(
    String teacherId, {
    required String name,
    required String initials,
    required String department,
    String? designation,
    String? additionalDesignation,
    int? experienceYears,
  }) {
    // Find teacher by ID
    for (final key in _teachers.keys) {
      final teacher = _teachers[key]!;
      if (teacher.teacherId == teacherId) {
        _teachers[key] = Teacher(
          teacherId: teacher.teacherId,
          email: teacher.email,
          name: name,
          password: teacher.password,
          department: department,
          initials: initials,
          designation: designation ?? teacher.designation,
          additionalDesignation:
              additionalDesignation ?? teacher.additionalDesignation,
          experienceYears: experienceYears ?? teacher.experienceYears,
        );
        return true;
      }
    }
    return false;
  }

  static Teacher? getTeacherById(String teacherId) {
    for (final teacher in _teachers.values) {
      if (teacher.teacherId == teacherId) {
        return teacher;
      }
    }
    return null;
  }

  static Teacher? getTeacherByInitials(String initials) {
    final searchInitials = initials.toUpperCase().trim();
    for (final teacher in _teachers.values) {
      if (teacher.initials == searchInitials) {
        return teacher;
      }
    }
    return null;
  }

  static List<Teacher> searchTeachersByInitials(String query) {
    final searchQuery = query.toUpperCase().trim();
    return _teachers.values
        .where(
          (teacher) =>
              teacher.initials.contains(searchQuery) ||
              teacher.name.toUpperCase().contains(searchQuery),
        )
        .toList();
  }

  // ========== Proposal Operations ==========

  static bool createProposal(Proposal proposal) {
    if (_proposals.containsKey(proposal.id)) {
      return false;
    }
    _proposals[proposal.id] = proposal;
    return true;
  }

  static bool updateProposal(Proposal proposal) {
    if (!_proposals.containsKey(proposal.id)) {
      return false;
    }
    _proposals[proposal.id] = proposal;
    return true;
  }

  static bool deleteProposal(String proposalId) {
    return _proposals.remove(proposalId) != null;
  }

  static Proposal? getProposalById(String proposalId) {
    return _proposals[proposalId];
  }

  static List<Proposal> getProposalsByFacultyId(String facultyId) {
    return _proposals.values
        .where((proposal) => proposal.facultyId == facultyId)
        .toList();
  }

  static List<Proposal> getProposalsByFacultyInitials(String initials) {
    final searchInitials = initials.toUpperCase().trim();
    return _proposals.values
        .where((proposal) => proposal.facultyInitials == searchInitials)
        .toList();
  }

  static List<Proposal> getAllProposals() {
    return _proposals.values.toList();
  }

  static List<Proposal> getProposalsByDepartment(String department) {
    return _proposals.values
        .where((proposal) => proposal.department == department)
        .toList();
  }
}

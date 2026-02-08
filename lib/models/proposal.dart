import 'package:uuid/uuid.dart';

/// Research Proposal model created by faculty members.
class Proposal {
  final String id;
  final String facultyId;
  final String facultyInitials;
  String facultyName;
  String title;
  String description;
  String department;
  String requirements;
  final int createdAt;

  /// Constructor for creating a new proposal
  Proposal({
    required this.facultyId,
    required this.facultyInitials,
    required this.facultyName,
    required this.title,
    required this.description,
    required this.department,
    required this.requirements,
  }) : id = const Uuid().v4(),
       createdAt = DateTime.now().millisecondsSinceEpoch;

  /// Constructor for editing an existing proposal
  Proposal.withId({
    required this.id,
    required this.facultyId,
    required this.facultyInitials,
    required this.facultyName,
    required this.title,
    required this.description,
    required this.department,
    required this.requirements,
    required this.createdAt,
  });

  /// Create Proposal from Supabase JSON response
  factory Proposal.fromJson(Map<String, dynamic> json) {
    // Handle createdAt from Supabase (timestamp string) or from local (int)
    int parsedCreatedAt;
    if (json['created_at'] is int) {
      parsedCreatedAt = json['created_at'];
    } else if (json['created_at'] is String) {
      parsedCreatedAt = DateTime.parse(
        json['created_at'],
      ).millisecondsSinceEpoch;
    } else {
      parsedCreatedAt = DateTime.now().millisecondsSinceEpoch;
    }

    return Proposal.withId(
      id: json['id'] ?? const Uuid().v4(),
      facultyId: json['faculty_id'] ?? '',
      facultyInitials: json['faculty_initials'] ?? '',
      facultyName: json['faculty_name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      department: json['department'] ?? '',
      requirements: json['requirements'] ?? '',
      createdAt: parsedCreatedAt,
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'faculty_id': facultyId,
      'faculty_initials': facultyInitials.toUpperCase(),
      'faculty_name': facultyName,
      'title': title,
      'description': description,
      'department': department,
      'requirements': requirements,
    };
  }

  /// Convert to JSON for Supabase update (without id and created_at)
  Map<String, dynamic> toJsonForUpdate() {
    return {
      'faculty_name': facultyName,
      'title': title,
      'description': description,
      'department': department,
      'requirements': requirements,
    };
  }
}

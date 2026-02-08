class Request {
  final String id;
  final String studentId;
  final String teacherId;
  final String studentName;
  final String studentEmail;
  final String studentDepartment;
  final String description;
  final String status;
  final DateTime createdAt;

  Request({
    required this.id,
    required this.studentId,
    required this.teacherId,
    required this.studentName,
    required this.studentEmail,
    required this.studentDepartment,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      teacherId: json['teacher_id'] as String,
      studentName: json['student_name'] as String,
      studentEmail: json['student_email'] as String,
      studentDepartment: json['student_department'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'teacher_id': teacherId,
      'student_name': studentName,
      'student_email': studentEmail,
      'student_department': studentDepartment,
      'description': description,
      // Status and dates are handled by DB defaults usually, but can be passed
    };
  }
}

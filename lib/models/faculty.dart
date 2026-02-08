/// Faculty data model representing a faculty member for display
class Faculty {
  String id;
  String name;
  String designation;
  String department;
  int yearsExperience;
  String researchProject;
  String email;

  Faculty({
    required this.id,
    required this.name,
    required this.designation,
    required this.department,
    required this.yearsExperience,
    required this.researchProject,
    required this.email,
  });
}

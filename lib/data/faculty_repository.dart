import '../models/faculty.dart';

/// Dummy data repository for faculty members
class FacultyRepository {
  static List<Faculty> getCSEFaculty() {
    return [
      Faculty(
        id: 'cse001',
        name: 'Dr. Aminul Islam',
        designation: 'Professor & Head',
        department: 'CSE',
        yearsExperience: 18,
        researchProject:
            'Machine Learning Applications in Healthcare Diagnostics',
        email: 'aminul.islam@university.edu',
      ),
      Faculty(
        id: 'cse002',
        name: 'Dr. Fatema Khatun',
        designation: 'Associate Professor',
        department: 'CSE',
        yearsExperience: 12,
        researchProject:
            'Natural Language Processing for Bengali Text Analysis',
        email: 'fatema.khatun@university.edu',
      ),
      Faculty(
        id: 'cse003',
        name: 'Dr. Shakil Ahmed',
        designation: 'Assistant Professor',
        department: 'CSE',
        yearsExperience: 8,
        researchProject: 'Blockchain-based Supply Chain Management Systems',
        email: 'shakil.ahmed@university.edu',
      ),
      Faculty(
        id: 'cse004',
        name: 'Dr. Nusrat Jahan',
        designation: 'Assistant Professor',
        department: 'CSE',
        yearsExperience: 6,
        researchProject:
            'Computer Vision for Agricultural Crop Disease Detection',
        email: 'nusrat.jahan@university.edu',
      ),
      Faculty(
        id: 'cse005',
        name: 'Dr. Rafiqul Hasan',
        designation: 'Lecturer',
        department: 'CSE',
        yearsExperience: 4,
        researchProject: 'IoT-based Smart Campus Solutions',
        email: 'rafiqul.hasan@university.edu',
      ),
    ];
  }

  static List<Faculty> getBBAFaculty() {
    return [
      Faculty(
        id: 'bba001',
        name: 'Dr. Shahidul Alam',
        designation: 'Professor & Dean',
        department: 'BBA',
        yearsExperience: 22,
        researchProject:
            'Corporate Governance and Ethical Business Practices in Bangladesh',
        email: 'shahidul.alam@university.edu',
      ),
      Faculty(
        id: 'bba002',
        name: 'Dr. Tahmina Rahman',
        designation: 'Associate Professor',
        department: 'BBA',
        yearsExperience: 14,
        researchProject:
            'Digital Marketing Strategies for SMEs in Emerging Markets',
        email: 'tahmina.rahman@university.edu',
      ),
      Faculty(
        id: 'bba003',
        name: 'Dr. Kamal Uddin',
        designation: 'Assistant Professor',
        department: 'BBA',
        yearsExperience: 9,
        researchProject: 'Financial Inclusion and Microfinance Impact Studies',
        email: 'kamal.uddin@university.edu',
      ),
      Faculty(
        id: 'bba004',
        name: 'Dr. Sabina Yasmin',
        designation: 'Lecturer',
        department: 'BBA',
        yearsExperience: 5,
        researchProject: 'Human Resource Management in the Post-Pandemic Era',
        email: 'sabina.yasmin@university.edu',
      ),
    ];
  }

  static List<Faculty> getLawFaculty() {
    return [
      Faculty(
        id: 'law001',
        name: 'Dr. Abdul Matin',
        designation: 'Professor & Chair',
        department: 'Law',
        yearsExperience: 25,
        researchProject: 'Constitutional Law Reform and Democratic Governance',
        email: 'abdul.matin@university.edu',
      ),
      Faculty(
        id: 'law002',
        name: 'Dr. Hasina Begum',
        designation: 'Associate Professor',
        department: 'Law',
        yearsExperience: 16,
        researchProject:
            "Women's Rights and Gender Justice in South Asian Legal Systems",
        email: 'hasina.begum@university.edu',
      ),
      Faculty(
        id: 'law003',
        name: 'Dr. Farhan Ali',
        designation: 'Assistant Professor',
        department: 'Law',
        yearsExperience: 7,
        researchProject: 'Cyber Law and Digital Privacy Regulations',
        email: 'farhan.ali@university.edu',
      ),
      Faculty(
        id: 'law004',
        name: 'Dr. Rubina Khan',
        designation: 'Lecturer',
        department: 'Law',
        yearsExperience: 4,
        researchProject: 'Environmental Law and Climate Change Litigation',
        email: 'rubina.khan@university.edu',
      ),
    ];
  }

  static List<Faculty> getFacultyByDepartment(String department) {
    switch (department.toUpperCase()) {
      case 'CSE':
        return getCSEFaculty();
      case 'BBA':
        return getBBAFaculty();
      case 'LAW':
        return getLawFaculty();
      default:
        return [];
    }
  }
}

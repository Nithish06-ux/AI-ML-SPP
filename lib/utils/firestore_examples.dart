import 'package:cloud_firestore/cloud_firestore.dart';

/// Example Firestore queries used across the project.
class FirestoreExamples {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Example: fetch all students in a department.
  static Future<QuerySnapshot<Map<String, dynamic>>> studentsByDepartment(
    String department,
  ) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('department', isEqualTo: department)
        .get();
  }

  /// Example: fetch upcoming events ordered by date.
  static Stream<QuerySnapshot<Map<String, dynamic>>> upcomingEvents() {
    return _firestore.collection('events').orderBy('date').snapshots();
  }

  /// Example: fetch attendance records for a student.
  static Stream<QuerySnapshot<Map<String, dynamic>>> attendanceForStudent(
    String studentId,
  ) {
    return _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}

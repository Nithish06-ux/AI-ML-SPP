import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String attendanceId;
  final String eventId;
  final String studentId;
  final DateTime timestamp;

  const AttendanceModel({
    required this.attendanceId,
    required this.eventId,
    required this.studentId,
    required this.timestamp,
  });

  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AttendanceModel(
      attendanceId: data['attendanceId'] as String? ?? doc.id,
      eventId: data['eventId'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attendanceId': attendanceId,
      'eventId': eventId,
      'studentId': studentId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

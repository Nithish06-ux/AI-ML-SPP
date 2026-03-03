import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerForEvent({
    required String eventId,
    required String studentId,
  }) async {
    final docId = '${eventId}_$studentId';
    final docRef = _firestore.collection('attendance').doc(docId);

    final existing = await docRef.get();
    if (existing.exists) {
      throw Exception('Already marked attendance for this event.');
    }

    final attendance = AttendanceModel(
      attendanceId: docId,
      eventId: eventId,
      studentId: studentId,
      timestamp: DateTime.now(),
    );

    await docRef.set(attendance.toMap());
  }

  Future<void> markAttendanceByQr({
    required String scannedValue,
    required String expectedEventId,
    required String studentId,
  }) async {
    // QR code validation against event ID / QR value.
    final eventDoc = await _firestore.collection('events').doc(expectedEventId).get();
    if (!eventDoc.exists) {
      throw Exception('Event does not exist.');
    }

    final qrCodeValue = eventDoc.data()?['qrCodeValue'] as String?;
    if (qrCodeValue == null || qrCodeValue != scannedValue) {
      throw Exception('Invalid QR code for this event.');
    }

    await registerForEvent(eventId: expectedEventId, studentId: studentId);
  }

  Stream<List<AttendanceModel>> getAttendanceByEvent(String eventId) {
    return _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<AttendanceModel>> getAttendanceByStudent(String studentId) {
    return _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceModel.fromFirestore(doc))
            .toList());
  }

  Future<double> getAttendancePercentage({
    required String studentId,
    required int totalEvents,
  }) async {
    if (totalEvents <= 0) return 0;

    final attendanceCount = await _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .count()
        .get();

    final present = attendanceCount.count ?? 0;
    return (present / totalEvents) * 100;
  }

  Future<double> getEventAttendancePercentage({
    required String eventId,
    required int totalStudents,
  }) async {
    if (totalStudents <= 0) return 0;

    final attendanceCount = await _firestore
        .collection('attendance')
        .where('eventId', isEqualTo: eventId)
        .count()
        .get();

    final present = attendanceCount.count ?? 0;
    return (present / totalStudents) * 100;
  }
}

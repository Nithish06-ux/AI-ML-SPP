import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<AttendanceModel>> attendanceByEvent(String eventId) {
    return _attendanceService.getAttendanceByEvent(eventId);
  }

  Stream<List<AttendanceModel>> attendanceByStudent(String studentId) {
    return _attendanceService.getAttendanceByStudent(studentId);
  }

  Future<bool> registerForEvent({
    required String eventId,
    required String studentId,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _attendanceService.registerForEvent(
        eventId: eventId,
        studentId: studentId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markAttendanceByQr({
    required String scannedValue,
    required String expectedEventId,
    required String studentId,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      await _attendanceService.markAttendanceByQr(
        scannedValue: scannedValue,
        expectedEventId: expectedEventId,
        studentId: studentId,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<double> getAttendancePercentage({
    required String studentId,
    required int totalEvents,
  }) {
    return _attendanceService.getAttendancePercentage(
      studentId: studentId,
      totalEvents: totalEvents,
    );
  }

  Future<double> getEventAttendancePercentage({
    required String eventId,
    required int totalStudents,
  }) {
    return _attendanceService.getEventAttendancePercentage(
      eventId: eventId,
      totalStudents: totalStudents,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/event_model.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isProcessing = false;

  Future<void> _onDetect(
    BarcodeCapture capture,
    EventModel event,
    String studentId,
  ) async {
    if (_isProcessing) return;

    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    setState(() => _isProcessing = true);

    final success = await context.read<AttendanceProvider>().markAttendanceByQr(
          scannedValue: value,
          expectedEventId: event.eventId,
          studentId: studentId,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Attendance marked successfully'
              : context.read<AttendanceProvider>().error ?? 'Failed to mark',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final event = ModalRoute.of(context)!.settings.arguments as EventModel;
    final studentId = context.read<AuthProvider>().currentUser?.uid;

    if (studentId == null) {
      return const Scaffold(body: Center(child: Text('User session missing.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Scan QR - ${event.title}')),
      body: MobileScanner(
        onDetect: (capture) => _onDetect(capture, event, studentId),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrGeneratorWidget extends StatelessWidget {
  final String qrData;

  const QrGeneratorWidget({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Event Attendance QR Code'),
            const SizedBox(height: 12),
            QrImageView(data: qrData, size: 220),
            const SizedBox(height: 8),
            Text('Code: $qrData'),
          ],
        ),
      ),
    );
  }
}

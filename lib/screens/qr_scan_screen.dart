import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Meja")),
      body: MobileScanner(
        onDetect: (capture) {
          if (!scanned) {
            scanned = true;
            final barcode = capture.barcodes.first;
            final code = barcode.rawValue ?? "";
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}

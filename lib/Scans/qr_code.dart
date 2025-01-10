import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../CustomWidget/background_widget.dart';
import '../CustomWidget/footer_tab.dart';

class QrCodeScreen extends StatefulWidget {
  final String cardNumber;

  const QrCodeScreen({super.key, required this.cardNumber});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'QR Code Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF009A90),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BackgroundWidget(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: widget.cardNumber,
                version: QrVersions.auto,
                size: 300.0,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Scan this QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const FooterTab(),
    );
  }
}

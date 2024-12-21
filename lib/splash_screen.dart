import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bbb_mobile_app/CustomWidget/background_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: BackgroundWidget(
          child: Center(
            child: const Image(
              image: AssetImage('assets/bbb_logo.png'),
              width: 150, // Adjusted width
              height: 150, // Adjusted height
            ),
          ),
        ),
      ),
    );
  }
}
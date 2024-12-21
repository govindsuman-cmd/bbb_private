import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF61CEFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFF009A90),
          ],
          stops: [
            0.0005,
            0.3,
            0.7,
            0.98,
          ],
        ),
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          // (Asume que descargaste una animación de "cargando" de LottieFiles)
          child: Lottie.asset('assets/animations/loading.json'),
        ),
      ),
    );
  }
}

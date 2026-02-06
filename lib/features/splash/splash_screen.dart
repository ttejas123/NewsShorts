import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 160,
          height: 160,
          child: Lottie.asset(
            'assets/animations/splash_icons.json',
            fit: BoxFit.contain,
            repeat: false,
            onLoaded: (composition) {
              // 🔥 REMOVE native splash as soon as Flutter UI is ready
              FlutterNativeSplash.remove();

              Future.delayed(composition.duration, () {
                if (!mounted) return;
                Navigator.pushReplacementNamed(context, '/home');
              });
            },
          ),
        ),
      ),
    );
  }
}

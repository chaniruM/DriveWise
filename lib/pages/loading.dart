import 'package:flutter/material.dart';
import 'splash_screen.dart';


void main() {
  runApp(const DriveWiseApp());
}

class DriveWiseApp extends StatelessWidget {
  const DriveWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF030B23),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 250,
              ),
              const SizedBox(height: 50),
              const Icon(
                Icons.arrow_upward,
                size: 70,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Swipe up to continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

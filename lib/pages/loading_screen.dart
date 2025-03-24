import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:drivewise/pages/welcome_screen.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  double _loadingProgress = 0.0;
  late Timer _progressTimer;

  // Glitch effect variables
  bool _showGlitch = false;
  double _glitchOffsetX = 0.0;
  double _glitchOffsetY = 0.0;
  late Timer _glitchTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..forward();

    // Simulate loading progress
    _progressTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _loadingProgress += 0.033;
        if (_loadingProgress >= 1.0) {
          _loadingProgress = 1.0;
          timer.cancel();
          // Navigate to welcome screen
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => WelcomeScreen(),
              transitionDuration: Duration(milliseconds: 750),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    });

    // Set up glitch animation timer
    _glitchTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        // Randomly decide whether to show glitch effect
        _showGlitch = _random.nextDouble() < 0.1;

        if (_showGlitch) {
          // Random offset for glitch effect
          _glitchOffsetX = (_random.nextDouble() * 10.0) - 5.0; // -5 to 5
          _glitchOffsetY = (_random.nextDouble() * 6.0) - 3.0; // -3 to 3

          // Schedule to turn off glitch after short duration
          Future.delayed(Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() {
                _showGlitch = false;
              });
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressTimer.cancel();
    _glitchTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF030B23),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo with glitch effect
              AnimatedBuilder(
                animation: _logoAnimationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_logoAnimationController.value * 0.2),
                    child: _buildGlitchLogo(),
                  );
                },
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlitchLogo() {
    if (!_showGlitch) {
      // Normal logo without glitch
      return Image.asset(
        'assets/images/logo.png',
        width: 300,
      );
    } else {
      // Glitched logo effect using stacked images with color filters
      return Stack(
        children: [
          // Base image
          Image.asset(
            'assets/images/logo.png',
            width: 300,
          ),

          // Red channel shifted
          Positioned(
            left: _glitchOffsetX,
            top: _glitchOffsetY,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.red.withOpacity(0.4),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
              ),
            ),
          ),

          // Blue channel shifted in opposite direction
          Positioned(
            left: -_glitchOffsetX,
            top: -_glitchOffsetY,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white60.withOpacity(0.4),
                BlendMode.srcIn,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
              ),
            ),
          ),
        ],
      );
    }
  }
}
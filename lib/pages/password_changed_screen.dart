import 'dart:async';
import 'package:drivewise/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drivewise/services/token_service.dart';

class PasswordChangedScreen extends StatefulWidget {
  @override
  _PasswordChangedScreenState createState() => _PasswordChangedScreenState();
}

class _PasswordChangedScreenState extends State<PasswordChangedScreen> {
  int _secondsRemaining = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Clear tokens and user data
    _clearUserData();
    // Start the countdown timer
    _startCountdown();
  }

  Future<void> _clearUserData() async {
    await TokenService.clearToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer.cancel();
          // Navigate to login screen with named route
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
              settings: RouteSettings(name: '/login'),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 32),
              // Success text
              Text(
                'Password Changed',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your password has been changed successfully',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              // Countdown text
              Text(
                'Redirecting to login in $_secondsRemaining ${_secondsRemaining == 1 ? 'second' : 'seconds'}...',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 32),
              // Login now button
              ElevatedButton(
                onPressed: () {
                  _timer.cancel();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                      settings: RouteSettings(name: '/login'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Login Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

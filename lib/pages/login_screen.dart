import 'package:flutter/material.dart';
import 'package:drivewise/MainPage.dart';
import 'package:drivewise/pages/quick_lookup_screen.dart';
import 'package:drivewise/pages/Registration_Page.dart';
import 'package:drivewise/services/api_service.dart';
import 'package:drivewise/services/token_service.dart';
import 'package:flutter/gestures.dart';
import 'package:drivewise/widgets/sessionExpiredScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // 🔹 Loading state

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      var response = await ApiService.login(
          _emailController.text, _passwordController.text);

      setState(() {
        _isLoading = false; // Stop loading
      });

      if (response.containsKey("token")) {
        String token = response["token"];
        await TokenService.saveToken(token);

        bool isExpired = await TokenService.isTokenExpired();
        print("Is token expired after login? $isExpired");

        if (isExpired) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SessionExpiredScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid login credentials"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1128),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo3d.png',
                    height: 150,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Show loading spinner when logging in
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.lightBlueAccent)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: loginUser,
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),

                  SizedBox(height: 15),
                  Text(
                    'Or Login With',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 32,
                    ),
                    label: Text(
                      'Google',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    onPressed: () {
                      // Handle Google login
                    },
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: "Register",
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {},
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuickLookupScreen()),
                      );
                    },
                    child: Text(
                      'Quick LookUp',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuickLookupScreen()),
                      );
                    },
                    child: Text(
                      'Scan for DTC',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:drivewise/MainPage.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveWise App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage()
      // home: HomePage(), // Use the HomePage as the default screen.
    );
  }
}

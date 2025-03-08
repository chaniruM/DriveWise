// import 'package:drivewise/MainPage.dart';
// import 'package:flutter/material.dart';
//
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'DriveWise App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MainPage()
//       // home: HomePage(), // Use the HomePage as the default screen.
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:drivewise/pages/login_screen.dart';
import 'package:drivewise/pages/register_vehicle_page.dart';
import 'package:drivewise/pages/vehicle_datails_page.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Color primaryDarkBlue = Color(0xFF030B23);
  static final Color accentOrange = Color(0xFFE95B15);
  static final Color backgroundGrey = Color(0xFFF5F5F5);
  static final Color lightGrey = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveWise',
      theme: ThemeData(
        primaryColor: primaryDarkBlue,
        colorScheme: ColorScheme.light(
          primary: primaryDarkBlue,
          secondary: accentOrange,
          background: backgroundGrey,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryDarkBlue,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: accentOrange,
          unselectedItemColor: Colors.grey,
          backgroundColor: primaryDarkBlue,
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(color: primaryDarkBlue, fontWeight: FontWeight.bold),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
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


import 'package:drivewise/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivewise/pages/login_screen.dart';
import 'package:drivewise/pages/register_vehicle_page.dart';
import 'package:drivewise/pages/vehicle_datails_page.dart';

import 'package:drivewise/providers/theme_provider.dart';
import 'package:drivewise/pages/settings_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotiService().initNotifications();

  // runApp(MyApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static final Color primaryDarkBlue = Color(0xFF030B23);
  static final Color accentOrange = Color(0xFFE95B15);
  static final Color backgroundGrey = Color(0xFFF5F5F5);


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      title: 'DriveWise',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryDarkBlue,
        scaffoldBackgroundColor: Colors.white,
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
          bodyLarge: TextStyle(color: Colors.black), // Ensures readable text in light mode
          titleLarge: TextStyle(color: primaryDarkBlue, fontWeight: FontWeight.bold),
        ),
      ),


      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryDarkBlue,
        scaffoldBackgroundColor: primaryDarkBlue,
        colorScheme: ColorScheme.dark(
          primary: primaryDarkBlue,
          secondary: accentOrange,
          background: primaryDarkBlue,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryDarkBlue,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Ensures readable text in dark mode
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
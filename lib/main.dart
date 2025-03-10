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
import 'package:provider/provider.dart';
import 'package:drivewise/pages/login_screen.dart';
import 'package:drivewise/providers/theme_provider.dart';
import 'package:drivewise/pages/settings_screen.dart';


void main() {
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
        colorScheme: ColorScheme.light(
          primary: primaryDarkBlue,
          secondary: accentOrange,
          background: backgroundGrey,
          brightness: Brightness.light,
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
          titleLarge: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : primaryDarkBlue,
              fontWeight: FontWeight.bold),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drivewise/MainPage.dart';
import 'package:drivewise/pages/loading_screen.dart';
import 'package:drivewise/providers/theme_provider.dart';
import 'package:drivewise/services/notification_service.dart';
import 'package:drivewise/services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotiService().initNotifications();
  bool isTokenExpired = await TokenService.isTokenExpired();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: MyApp(isLoggedIn: !isTokenExpired),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  static final Color primaryDarkBlue = Color(0xFF030B23);
  static final Color accentOrange = Color(0xFFE95B15);
  static final Color backgroundGrey = Color(0xFFF5F5F5);

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
          bodyLarge: TextStyle(color: Colors.black),
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
          bodyLarge: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      home: isLoggedIn ? MainPage() : LoadingScreen(),
    );
  }
}
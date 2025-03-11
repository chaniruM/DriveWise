import 'package:flutter/material.dart';

void main() {
  runApp(DriveWiseApp());
}

class DriveWiseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: TroubleCodePage(),
    );
  }
}

class TroubleCodePage extends StatefulWidget {
  @override
  _TroubleCodePageState createState() => _TroubleCodePageState();
}

class _TroubleCodePageState extends State<TroubleCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DRIVEWISE"),
      ),
      body: Center(
        child: Text(
          "Welcome to DriveWise Trouble Code Page",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
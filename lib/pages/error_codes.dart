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
  List<Map<String, String>> troubleCodes = [
    {"code": "C2768", "type": "Chassis", "status": "Current fault"},
    {"code": "C07A0", "type": "Chassis", "status": "Pending fault"},
  ];

  void connectScanner() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Connecting to OBD-II scanner...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DRIVEWISE"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Scan for Trouble Codes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: connectScanner,
              child: const Text("Connect Scanner"),
            ),
            const SizedBox(height: 20),
            const Text(
              "Fault Log Manager",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: troubleCodes.length,
                itemBuilder: (context, index) {
                  var trouble = troubleCodes[index];
                  return Card(
                    color: trouble["status"] == "Current fault"
                        ? Colors.red[300]
                        : Colors.amber[300],
                    child: ListTile(
                      title: Text("${trouble["code"]} - ${trouble["type"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(trouble["status"] ?? ""),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
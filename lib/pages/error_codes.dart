import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  void clearFaults() {
    setState(() {
      troubleCodes.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Faults cleared.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DRIVEWISE"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {}, // Placeholder for settings functionality
          ),
        ],
      ),
      drawer: Drawer(), // Placeholder for menu drawer
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
                      leading: const Icon(LucideIcons.alertTriangle, color: Colors.white),
                      title: Text("${trouble["code"]} - ${trouble["type"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(trouble["status"] ?? ""),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: clearFaults,
              child: const Text("Clear faults"),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "${troubleCodes.length} fault code(s) found",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: ""),
        ],
      ),
    );
  }
}
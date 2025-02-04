import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

// void main() {
//   runApp(OBD2App());
// }

class OBD2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OBD-II Connection Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OBD2Screen(),
    );
  }
}

class OBD2Screen extends StatefulWidget {
  @override
  _OBD2ScreenState createState() => _OBD2ScreenState();
}

class _OBD2ScreenState extends State<OBD2Screen> {
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  String _status = "Select a device to connect";

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Request permissions when the app starts
  }

  Future<void> _checkPermissions() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _listDevices() async {
    await FlutterBluetoothSerial.instance.requestEnable(); // Ensure Bluetooth is ON
    List<BluetoothDevice> devices =
    await FlutterBluetoothSerial.instance.getBondedDevices();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select OBD-II Device"),
          content: SingleChildScrollView(
            child: Column(
              children: devices.map((device) {
                return ListTile(
                  title: Text(device.name ?? "Unknown"),
                  subtitle: Text(device.address),
                  onTap: () {
                    setState(() {
                      _selectedDevice = device;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _connectToOBD() async {
    if (_selectedDevice == null) {
      setState(() {
        _status = "No device selected";
      });
      return;
    }

    try {
      BluetoothConnection connection =
      await BluetoothConnection.toAddress(_selectedDevice!.address);

      setState(() {
        _connection = connection;
        _status = "Connected to ${_selectedDevice!.name}";
      });

      print("Connected to OBD-II Scanner");

      // Listen for incoming data (optional)
      _connection!.input!.listen((Uint8List data) {
        print('Received data: ${String.fromCharCodes(data)}');
      });
    } catch (e) {
      setState(() {
        _status = "Failed to connect: $e";
      });
      print("Error: $e");
    }
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OBD-II Connection Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _listDevices,
              child: Text("Select Device"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _connectToOBD,
              child: Text("Connect to OBD-II"),
            ),
          ],
        ),
      ),
    );
  }
}

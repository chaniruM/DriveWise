import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:convert';

class OBD2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OBD2Screen(),
    );
  }
}

class OBD2Screen extends StatefulWidget {
  @override
  _OBD2ScreenState createState() => _OBD2ScreenState();
}

class _OBD2ScreenState extends State<OBD2Screen> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  BluetoothConnection? _connection;
  String _status = "Select a device to connect";
  String _rpm = "RPM: --";

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndListDevices();
  }

  Future<void> _checkPermissionsAndListDevices() async {
    if (await _requestBluetoothPermissions()) {
      _listDevices();
    }
  }

  Future<bool> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothConnect.request().isGranted &&
        await Permission.bluetoothScan.request().isGranted &&
        await Permission.location.request().isGranted) {
      return true;
    } else {
      print("Bluetooth permissions denied.");
      return false;
    }
  }

  Future<void> _listDevices() async {
    try {
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {
        _devices = devices;
      });
    } catch (e) {
      print("Error listing Bluetooth devices: $e");
    }
  }

  Future<void> _connectToOBD() async {
    if (_selectedDevice == null) {
      setState(() {
        _status = "No device selected";
      });
      return;
    }

    try {
      BluetoothConnection connection = await BluetoothConnection.toAddress(_selectedDevice!.address);
      setState(() {
        _connection = connection;
        _status = "Connected to ${_selectedDevice!.name}";
      });

      print("Connected to OBD-II Scanner");
    } catch (e) {
      setState(() {
        _status = "Failed to connect: $e";
      });
      print("Error: $e");
    }
  }

  Future<void> _readRPM() async {
    if (_connection == null || !_connection!.isConnected) {
      setState(() {
        _rpm = "Not connected to OBD-II";
      });
      return;
    }

    try {
      String command = "010C\r";
      _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
      await _connection!.output.allSent;

      _connection!.input!.listen((Uint8List data) {
        String response = utf8.decode(data);
        print("Raw OBD Response: $response");

        List<String> values = response.split(" ");
        if (values.length >= 3) {
          int A = int.parse(values[2], radix: 16);
          int B = int.parse(values[3], radix: 16);
          int rpmValue = ((A * 256) + B) ~/ 4;
          setState(() {
            _rpm = "RPM: $rpmValue";
          });
        }
      });
    } catch (e) {
      print("Error reading RPM: $e");
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
          crossAxisAlignment: CrossAxisAlignment.center, // Ensures horizontal centering
          mainAxisSize: MainAxisSize.min, // Adjusts the column to content size
          children: [
            Text(_status, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            DropdownButton<BluetoothDevice>(
              hint: Text("Select Device"),
              value: _selectedDevice,
              onChanged: (BluetoothDevice? newValue) {
                setState(() {
                  _selectedDevice = newValue;
                });
              },
              items: _devices.map((device) {
                return DropdownMenuItem<BluetoothDevice>(
                  value: device,
                  child: Text(device.name ?? "Unknown"),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _connectToOBD,
              child: Text("Connect to OBD-II"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _readRPM,
              child: Text("Read RPM"),
            ),
            SizedBox(height: 10),
            Text(_rpm, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
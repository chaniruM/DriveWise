import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';

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
  List<BluetoothDevice> _devices = [];

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
      setState(() {
        _status = "Bluetooth permissions denied.";
      });
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
            DropdownButton<BluetoothDevice>(
              hint: Text("Select a Device"),
              value: _selectedDevice,
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? "Unknown"),
                );
              }).toList(),
              onChanged: (device) {
                setState(() {
                  _selectedDevice = device;
                });
              },
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
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:typed_data';
// import 'dart:convert';
//
// class OBD2App extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: OBD2Screen(),
//     );
//   }
// }
//
// class OBD2Screen extends StatefulWidget {
//   @override
//   _OBD2ScreenState createState() => _OBD2ScreenState();
// }
//
// class _OBD2ScreenState extends State<OBD2Screen> {
//   List<BluetoothDevice> _devices = [];
//   BluetoothDevice? _selectedDevice;
//   BluetoothConnection? _connection;
//   String _status = "Select a device to connect";
//   // String _rpm = "RPM: --";
//   String _speed = "Speed: --";
//   String _distance = "Distance: 0.0m";
//   bool _isMeasuring = false;
//   List<Map<String, dynamic>> _speedData = []; // Stores {timestamp, speed}
//   double _totalDistance = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionsAndListDevices();
//   }
//
//   Future<void> _checkPermissionsAndListDevices() async {
//     if (await _requestBluetoothPermissions()) {
//       _listDevices();
//     }
//   }
//
//   Future<bool> _requestBluetoothPermissions() async {
//     if (await Permission.bluetoothConnect.request().isGranted &&
//         await Permission.bluetoothScan.request().isGranted &&
//         await Permission.location.request().isGranted) {
//       return true;
//     } else {
//       print("Bluetooth permissions denied.");
//       return false;
//     }
//   }
//
//   Future<void> _listDevices() async {
//     try {
//       List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
//       setState(() {
//         _devices = devices;
//       });
//     } catch (e) {
//       print("Error listing Bluetooth devices: $e");
//     }
//   }
//
//   Future<void> _connectToOBD() async {
//     if (_selectedDevice == null) {
//       setState(() {
//         _status = "No device selected";
//       });
//       return;
//     }
//
//     try {
//       BluetoothConnection connection = await BluetoothConnection.toAddress(_selectedDevice!.address);
//       setState(() {
//         _connection = connection;
//         _status = "Connected to ${_selectedDevice!.name}";
//       });
//
//       print("Connected to OBD-II Scanner");
//     } catch (e) {
//       setState(() {
//         _status = "Failed to connect: $e";
//       });
//       print("Error: $e");
//     }
//   }
//
//   // Future<void> _readRPM() async {
//   //   if (_connection == null || !_connection!.isConnected) {
//   //     setState(() {
//   //       _rpm = "Not connected to OBD-II";
//   //     });
//   //     return;
//   //   }
//   //
//   //   try {
//   //     String command = "010C\r";
//   //     _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
//   //     await _connection!.output.allSent;
//   //
//   //     _connection!.input!.listen((Uint8List data) {
//   //       String response = utf8.decode(data);
//   //       print("Raw OBD Response: $response");
//   //
//   //       List<String> values = response.split(" ");
//   //       if (values.length >= 3) {
//   //         int A = int.parse(values[2], radix: 16);
//   //         int B = int.parse(values[3], radix: 16);
//   //         int rpmValue = ((A * 256) + B) ~/ 4;
//   //         setState(() {
//   //           _rpm = "RPM: $rpmValue";
//   //         });
//   //       }
//   //     });
//   //   } catch (e) {
//   //     print("Error reading RPM: $e");
//   //   }
//   // }
//
//   Future<void> _readSpeed() async {
//     if (_connection == null || !_connection!.isConnected) {
//       setState(() {
//         _speed = "Not connected to OBD-II";
//       });
//       return;
//     }
//
//     try {
//       String command = "010D\r"; // OBD-II command for speed
//       _connection!.output.add(Uint8List.fromList(utf8.encode(command)));
//       await _connection!.output.allSent;
//
//       _connection!.input!.listen((Uint8List data) {
//         String response = utf8.decode(data).trim();
//         print("Raw OBD Response (Speed): $response");
//
//         // Use regex to extract valid response
//         RegExp regExp = RegExp(r"41 0D ([0-9A-F]{2})");
//         Match? match = regExp.firstMatch(response);
//
//         if (match != null) {
//           int speedValue = int.parse(match.group(1)!, radix: 16);
//
//           double currentTime = DateTime
//               .now()
//               .millisecondsSinceEpoch / 1000;
//           _speedData.add({"time": currentTime, "speed": speedValue});
//           // Calculate distance
//           _calcDistance();
//
//           setState(() {
//             _speed = "Speed: $speedValue km/h";
//           });
//         } else {
//           print("Invalid speed response: $response");
//         }
//       });
//     } catch (e) {
//       print("Error reading speed: $e");
//     }
//   }
//
//   void _calcDistance(){
//     if(_speedData.length < 2) return;
//     int last = _speedData.length-1;
//
//     double v1 = _speedData[last - 1]["speed"] / 3.6; // Convert km/h to m/s
//     double v2 = _speedData[last]["speed"] / 3.6;
//     double t1 = _speedData[last - 1]["time"];
//     double t2 = _speedData[last]["time"];
//
//     double timeDiff = t2 - t1;
//
//     if (timeDiff > 0) {
//       double distanceSegment = ((v1 + v2) / 2) * timeDiff; // Trapezoidal rule
//       _totalDistance += distanceSegment;
//
//       setState(() {
//         _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} meters";
//       });
//
//       print("Calculated Distance: $_totalDistance meters");
//     }
//   }
//
//   void _toggleMeasurement() {
//     if (_isMeasuring) {
//       setState(() {
//         _isMeasuring = false;
//         _status = "Measurement stopped";
//       });
//     } else {
//       setState(() {
//         _isMeasuring = true;
//         _status = "Measuring...";
//       });
//
//       // Continuously read the Speed
//       _startContinuousReading();
//     }
//   }
//
//   Future<void> _startContinuousReading() async {
//     while (_isMeasuring) {
//       await _readSpeed();
//       await Future.delayed(Duration(milliseconds: 500)); // delay between measurements
//     }
//   }
//
//   @override
//   void dispose() {
//     _connection?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'OBD-II Connection Test',
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white
//           ),
//         )
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center, // Ensures horizontal centering
//           mainAxisSize: MainAxisSize.min, // Adjusts the column to content size
//           children: [
//             Text(_status, style: TextStyle(fontSize: 18)),
//             SizedBox(height: 10),
//             DropdownButton<BluetoothDevice>(
//               hint: Text("Select Device"),
//               value: _selectedDevice,
//               onChanged: (BluetoothDevice? newValue) {
//                 setState(() {
//                   _selectedDevice = newValue;
//                 });
//               },
//               items: _devices.map((device) {
//                 return DropdownMenuItem<BluetoothDevice>(
//                   value: device,
//                   child: Text(device.name ?? "Unknown"),
//                 );
//               }).toList(),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _connectToOBD,
//               child: Text("Connect to OBD-II"),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: _toggleMeasurement,
//               child: Text(_isMeasuring ? "Stop Measuring" : "Start Measuring"),
//             ),
//             SizedBox(height: 10),
//             Text(_speed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text(_distance, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'dart:typed_data';

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: BluetoothScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
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
  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  String _status = "Select a device to connect";
  String _speed = "Speed: --";
  String _distance = "Distance: 0.00 m";
  bool _isMeasuring = false;
  List<Map<String, dynamic>> _speedData = [];
  double _totalDistance = 0.0;
  List<String> _dtcCodes = [];

  @override
  void initState() {
    super.initState();
    _listDevices();
  }

  Future<void> _listDevices() async {
    _devices.clear();
    // flutterBlue.startScan(timeout: Duration(seconds: 5));
    FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    // flutterBlue.scanResults.listen((results) {
    FlutterBluePlus.scanResults.listen((results){
      for (ScanResult result in results) {
        if (!_devices.contains(result.device)) {
          setState(() {
            _devices.add(result.device);
          });
        }
      }
    });

    await Future.delayed(Duration(seconds: 5));
    FlutterBluePlus.stopScan();
  }

  Future<void> _connectToOBD() async {
    if (_selectedDevice == null) {
      setState(() => _status = "No device selected");
      return;
    }

    try {
      await _selectedDevice!.connect();
      List<BluetoothService> services = await _selectedDevice!.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
          }
          if (characteristic.properties.notify || characteristic.properties.read) {
            _readCharacteristic = characteristic;
            await _readCharacteristic!.setNotifyValue(true);
            _readCharacteristic!.value.listen(_onDataReceived);
          }
        }
      }

      setState(() => _status = "Connected to ${_selectedDevice!.name}");
    } catch (e) {
      setState(() => _status = "Connection failed: $e");
    }
  }

  void _onDataReceived(List<int> data) {
    final response = utf8.decode(data).trim();
    final match = RegExp(r"41 0D ([0-9A-F]{2})").firstMatch(response);

    if (match != null) {
      final speedValue = int.parse(match.group(1)!, radix: 16);
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

      setState(() {
        _speedData.add({"time": currentTime, "speed": speedValue});
        _speed = "Speed: $speedValue km/h";
      });

      _calculateDistance();
    }
  }

  Future<void> _sendOBDCommand(String command) async {
    if (_writeCharacteristic == null) return;
    await _writeCharacteristic!.write(utf8.encode(command));
  }

  void _calculateDistance() {
    if (_speedData.length < 2) return;

    final last = _speedData.length - 1;
    final v1 = _speedData[last - 1]["speed"] / 3.6;
    final v2 = _speedData[last]["speed"] / 3.6;
    final t1 = _speedData[last - 1]["time"];
    final t2 = _speedData[last]["time"];
    final timeDiff = t2 - t1;

    if (timeDiff > 0) {
      final distanceSegment = ((v1 + v2) / 2) * timeDiff;
      _totalDistance += distanceSegment;

      setState(() => _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} m");
    }
  }

  void _toggleMeasurement() {
    setState(() {
      _isMeasuring = !_isMeasuring;
      _status = _isMeasuring ? "Measuring..." : "Measurement stopped";
    });

    if (_isMeasuring) _startContinuousReading();
  }

  Future<void> _startContinuousReading() async {
    while (_isMeasuring) {
      await _sendOBDCommand("010D\r");
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future<void> _readDTCs() async {
    if (_writeCharacteristic == null) {
      setState(() => _status = "Not connected to OBD-II");
      return;
    }

    await _sendOBDCommand("03\r");
  }

  @override
  void dispose() {
    _selectedDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OBD-II Diagnostics"), backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_status, style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            DropdownButton<BluetoothDevice>(
              hint: Text("Select Device"),
              value: _selectedDevice,
              onChanged: (device) => setState(() => _selectedDevice = device),
              items: _devices
                  .map((device) => DropdownMenuItem(value: device, child: Text(device.name ?? "Unknown")))
                  .toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _connectToOBD, child: Text("Connect")),
            ElevatedButton(onPressed: _toggleMeasurement, child: Text(_isMeasuring ? "Stop Measuring" : "Start Measuring")),
            ElevatedButton(onPressed: _readDTCs, child: Text("Read Trouble Codes")),
            SizedBox(height: 20),
            Text(_speed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_distance, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (_dtcCodes.isNotEmpty) ...[
              SizedBox(height: 10),
              Text("Trouble Codes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ..._dtcCodes.map((code) => Text(code, style: TextStyle(fontSize: 16)))
            ]
          ],
        ),
      ),
    );
  }
}
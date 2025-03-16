import 'package:drivewise/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

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
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  double targetDistance = 1.0;
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  String _status = "Press Start to read distance";
  String _speed = "Speed: -- km/h";
  String _distance = "Distance: 0.00 km";
  bool _isMeasuring = false;
  List<Map<String, dynamic>> _speedData = [];
  double _totalDistance = 0.0;
  List<String> _dtcCodes = [];
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    // _checkPermissionsAndListDevices();
    _monitorBluetoothState();
    // _listDevices();
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.notification,
    ].request();

    statuses.forEach((permission, status) {
      print("Permission $permission: $status");
    });

    return statuses.values.every((status) => status.isGranted);
  }


  void _monitorBluetoothState() {
    FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _bluetoothState = state;
      });
      if (state == BluetoothAdapterState.on) {
        _listDevices(); // Start scanning when Bluetooth is enabled
      } else {
        print("Bluetooth is off");
        setState(() {
          _status = "Bluetooth is off. Please enable Bluetooth.";
        });
      }
    });
  }

  // Future<void> _checkPermissionsAndListDevices() async {
  //   if (await _requestBluetoothPermissions()) {
  //     _listDevices();
  //   } else {
  //     print("Bluetooth permissions denied");
  //   }
  // }
  //
  // Future<bool> _requestBluetoothPermissions() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.bluetooth,
  //     Permission.bluetoothConnect,
  //     Permission.bluetoothScan,
  //     Permission.location,
  //   ].request();
  //
  //   statuses.forEach((permission, status) {
  //     print("Permission $permission: $status");
  //   });
  //
  //   return statuses.values.every((status) => status.isGranted);
  // }

  Future<void> _listDevices() async {

    FlutterBluePlus.startScan(
      withServices: [],
      withNames: [],
      withKeywords: [],
      timeout: Duration(seconds: 10),
    );

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == "OBDII") {
          setState(() {
            _selectedDevice = result.device;
          });
          FlutterBluePlus.stopScan();
          break;
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
      await _selectedDevice!.connect(autoConnect: false);
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
    final speedMatch = RegExp(r"41 0D ([0-9A-F]{2})").firstMatch(response);
    final dtcMatch = RegExp(r"43 ([0-9A-F ]+)").firstMatch(response);

    if (speedMatch != null) {
      final speedValue = int.parse(speedMatch.group(1)!, radix: 16);
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

      setState(() {
        _speedData.add({"time": currentTime, "speed": speedValue});
        _speed = "Speed: $speedValue km/h";
      });

      _calculateDistance();
    } else if (dtcMatch != null) {
      final dtcResponse = dtcMatch.group(1)!;
      if (dtcResponse.trim().isEmpty || dtcResponse == "00" || dtcResponse == "NO DATA") {
        setState(() {
          _dtcCodes = ["No error codes found"];
        });
      } else {
        _parseDTCs(dtcResponse);
      }
    }
  }

  Future<void> _sendOBDCommand(String command) async {
    if (_writeCharacteristic == null) return;
    await _writeCharacteristic!.write(utf8.encode(command), withoutResponse: false);
    await Future.delayed(Duration(milliseconds: 200));
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

      final distanceInKilometers = _totalDistance / 1000;
      setState(() => _distance = "Distance: ${distanceInKilometers.toStringAsFixed(2)} km");
      // setState(() => _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} m");
      // Check if target distance is reached
      if (distanceInKilometers >= targetDistance) {
        NotiService().showNotification(
          title: 'Service due!',
          body: 'You have reached your target distance of $targetDistance km',
        );
      }
    }
  }

  // void testNotification(){
  //   _totalDistance += 50;
  //
  //   final distanceInKilometers = _totalDistance / 1000;
  //   setState(() => _distance = "Distance: ${distanceInKilometers.toStringAsFixed(2)} km");
  //   // setState(() => _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} m");
  //   // Check if target distance is reached
  //   if (distanceInKilometers >= targetDistance) {
  //     NotiService().showNotification(
  //       title: 'Service due!',
  //       body: 'You have reached your target distance of $targetDistance km',
  //     );
  //   }
  // }

  void _toggleMeasurement() {
    setState(() {
      _isMeasuring = !_isMeasuring;
      _status = _isMeasuring ? "Measuring..." : "Measurement stopped";
    });

    if (_isMeasuring) {
      _connectToOBD(); // Automatically connect to the device when measuring starts
      _startContinuousReading();
    }
  }

  Future<void> _startContinuousReading() async {
    while (_isMeasuring) {
      await _sendOBDCommand("010D\r");
      // testNotification();
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future<void> _readDTCs() async {
    if (_selectedDevice == null) {
      setState(() => _status = "Not connected to OBD-II");
      return;
    }

    await _connectToOBD();
    await _sendOBDCommand("03\r");
  }

  void _parseDTCs(String response) {
    List<String> dtcList = [];
    response = response.replaceAll(" ", "");

    if (response.isEmpty || response == "00" || response == "NODATA") {
      setState(() {
        _dtcCodes = ["No error codes found"];
      });
      return;
    }

    for (int i = 0; i < response.length; i += 4) {
      if (i + 4 <= response.length) {
        dtcList.add(_formatDTC(response.substring(i, i + 4)));
      }
    }

    setState(() {
      _dtcCodes = dtcList;
    });
  }

  String _formatDTC(String code) {
    String type = code[0];
    String formattedType = {
      '0': 'P0', '1': 'P1', '2': 'P2', '3': 'P3',
      '4': 'C0', '5': 'C1', '6': 'C2', '7': 'C3',
      '8': 'B0', '9': 'B1', 'A': 'B2', 'B': 'B3',
      'C': 'U0', 'D': 'U1', 'E': 'U2', 'F': 'U3'
    }[type]!;
    return "$formattedType${code.substring(1)}";
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
            // Text("Bluetooth State: $_bluetoothState", style: TextStyle(fontSize: 16)),
            ElevatedButton(
                onPressed: _toggleMeasurement,
                child: Text(_isMeasuring ? "Stop Measuring" : "Start Measuring")
            ),
            SizedBox(height: 20),
            Text(_speed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(_distance, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ElevatedButton(
                onPressed: _readDTCs,
                child: Text("Read Trouble Codes")
            ),
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




// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:convert';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:typed_data';
//
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
//   // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
//   final FlutterBluePlus flutterBlue = FlutterBluePlus();
//   List<BluetoothDevice> _devices = [];
//   BluetoothDevice? _selectedDevice;
//   BluetoothCharacteristic? _writeCharacteristic;
//   BluetoothCharacteristic? _readCharacteristic;
//   String _status = "Select a device to connect";
//   String _speed = "Speed: --";
//   String _distance = "Distance: 0.00 m";
//   bool _isMeasuring = false;
//   List<Map<String, dynamic>> _speedData = [];
//   double _totalDistance = 0.0;
//   List<String> _dtcCodes = [];
//   BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionsAndListDevices();
//     _monitorBluetoothState();
//   }
//
//   // Monitor Bluetooth adapter state
//   void _monitorBluetoothState() {
//     FlutterBluePlus.adapterState.listen((state) {
//       setState(() {
//         _bluetoothState = state;
//       });
//       if (state == BluetoothAdapterState.on) {
//         print("Bluetooth is on");
//         _listDevices(); // Start scanning when Bluetooth is enabled
//       } else {
//         print("Bluetooth is off");
//         setState(() {
//           _status = "Bluetooth is off. Please enable Bluetooth.";
//         });
//       }
//     });
//   }
//
//   Future<void> _checkPermissionsAndListDevices() async {
//     if (await _requestBluetoothPermissions()) {
//       _listDevices();
//     } else {
//       print("Bluetooth permissions denied");
//     }
//   }
//
//   Future<bool> _requestBluetoothPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//       Permission.location,
//     ].request();
//
//     statuses.forEach((permission, status) {
//       print("Permission $permission: $status");
//     });
//
//     return statuses.values.every((status) => status.isGranted);
//   }
//
//   Future<void> _listDevices() async {
//     if (_bluetoothState != BluetoothAdapterState.on) {
//       setState(() {
//         _status = "Bluetooth is off. Please enable Bluetooth.";
//       });
//       return;
//     }
//
//     _devices.clear();
//     FlutterBluePlus.startScan(
//       withServices: [],
//       withNames: [],
//       withKeywords: [],
//       timeout: Duration(seconds: 10),
//     );
//
//     FlutterBluePlus.scanResults.listen((results) {
//       for (ScanResult result in results) {
//         if (!_devices.contains(result.device)) {
//           setState(() {
//             _devices.add(result.device);
//           });
//         }
//       }
//     });
//
//     await Future.delayed(Duration(seconds: 5));
//     FlutterBluePlus.stopScan();
//   }
//
//   Future<void> _connectToOBD() async {
//     if (_selectedDevice == null) {
//       setState(() => _status = "No device selected");
//       return;
//     }
//
//     try {
//       await _selectedDevice!.connect(autoConnect: false);
//       List<BluetoothService> services = await _selectedDevice!.discoverServices();
//
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _writeCharacteristic = characteristic;
//           }
//           if (characteristic.properties.notify || characteristic.properties.read) {
//             _readCharacteristic = characteristic;
//             await _readCharacteristic!.setNotifyValue(true);
//             _readCharacteristic!.value.listen(_onDataReceived);
//           }
//         }
//       }
//
//       await Future.delayed(Duration(milliseconds: 500));
//       setState(() => _status = "Connected to ${_selectedDevice!.name}");
//     } catch (e) {
//       setState(() => _status = "Connection failed: $e");
//     }
//   }
//
//   void _onDataReceived(List<int> data) {
//     final response = utf8.decode(data).trim();
//     final speedMatch = RegExp(r"41 0D ([0-9A-F]{2})").firstMatch(response);
//     final dtcMatch = RegExp(r"43 ([0-9A-F ]+)").firstMatch(response);
//
//     if (speedMatch != null) {
//       final speedValue = int.parse(speedMatch.group(1)!, radix: 16);
//       final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
//
//       setState(() {
//         _speedData.add({"time": currentTime, "speed": speedValue});
//         _speed = "Speed: $speedValue km/h";
//       });
//
//       _calculateDistance();
//     } else if (dtcMatch != null) {
//       final dtcResponse = dtcMatch.group(1)!;
//       if (dtcResponse.trim().isEmpty || dtcResponse == "00" || dtcResponse == "NO DATA") {
//         setState(() {
//           _dtcCodes = ["No error codes found"];
//         });
//       } else {
//         _parseDTCs(dtcResponse);
//       }
//     }
//   }
//
//   Future<void> _sendOBDCommand(String command) async {
//     if (_writeCharacteristic == null) return;
//     await _writeCharacteristic!.write(utf8.encode(command), withoutResponse: false);
//     await Future.delayed(Duration(milliseconds: 200));
//   }
//
//   void _calculateDistance() {
//     if (_speedData.length < 2) return;
//
//     final last = _speedData.length - 1;
//     final v1 = _speedData[last - 1]["speed"] / 3.6;
//     final v2 = _speedData[last]["speed"] / 3.6;
//     final t1 = _speedData[last - 1]["time"];
//     final t2 = _speedData[last]["time"];
//     final timeDiff = t2 - t1;
//
//     if (timeDiff > 0) {
//       final distanceSegment = ((v1 + v2) / 2) * timeDiff;
//       _totalDistance += distanceSegment;
//
//       setState(() => _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} m");
//     }
//   }
//
//   void _toggleMeasurement() {
//     setState(() {
//       _isMeasuring = !_isMeasuring;
//       _status = _isMeasuring ? "Measuring..." : "Measurement stopped";
//     });
//
//     if (_isMeasuring) _startContinuousReading();
//   }
//
//   Future<void> _startContinuousReading() async {
//     while (_isMeasuring) {
//       await _sendOBDCommand("010D\r");
//       await Future.delayed(Duration(milliseconds: 500));
//     }
//   }
//
//   Future<void> _readDTCs() async {
//     if (_writeCharacteristic == null) {
//       setState(() => _status = "Not connected to OBD-II");
//       return;
//     }
//
//     await _sendOBDCommand("03\r");
//   }
//
//   void _parseDTCs(String response) {
//     List<String> dtcList = [];
//     response = response.replaceAll(" ", "");
//
//     if (response.isEmpty || response == "00" || response == "NODATA") {
//       setState(() {
//         _dtcCodes = ["No error codes found"];
//       });
//       return;
//     }
//
//     for (int i = 0; i < response.length; i += 4) {
//       if (i + 4 <= response.length) {
//         dtcList.add(_formatDTC(response.substring(i, i + 4)));
//       }
//     }
//
//     setState(() {
//       _dtcCodes = dtcList;
//     });
//   }
//
//   String _formatDTC(String code) {
//     String type = code[0];
//     String formattedType = {
//       '0': 'P0', '1': 'P1', '2': 'P2', '3': 'P3',
//       '4': 'C0', '5': 'C1', '6': 'C2', '7': 'C3',
//       '8': 'B0', '9': 'B1', 'A': 'B2', 'B': 'B3',
//       'C': 'U0', 'D': 'U1', 'E': 'U2', 'F': 'U3'
//     }[type]!;
//     return "$formattedType${code.substring(1)}";
//   }
//
//   @override
//   void dispose() {
//     _selectedDevice?.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("OBD-II Diagnostics"), backgroundColor: Colors.blueAccent),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(_status, style: TextStyle(fontSize: 18)),
//             SizedBox(height: 10),
//             Text("Bluetooth State: $_bluetoothState", style: TextStyle(fontSize: 16)),
//             SizedBox(height: 10),
//             DropdownButton<BluetoothDevice>(
//               hint: Text("Select Device"),
//               value: _selectedDevice,
//               onChanged: (device) => setState(() => _selectedDevice = device),
//               items: _devices
//                   .map((device) => DropdownMenuItem(value: device, child: Text(device.name ?? "Unknown")))
//                   .toList(),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(onPressed: _connectToOBD, child: Text("Connect")),
//             ElevatedButton(onPressed: _toggleMeasurement, child: Text(_isMeasuring ? "Stop Measuring" : "Start Measuring")),
//             ElevatedButton(onPressed: _readDTCs, child: Text("Read Trouble Codes")),
//             SizedBox(height: 20),
//             Text(_speed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(_distance, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             if (_dtcCodes.isNotEmpty) ...[
//               SizedBox(height: 10),
//               Text("Trouble Codes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ..._dtcCodes.map((code) => Text(code, style: TextStyle(fontSize: 16)))
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:convert';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:typed_data';
//
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
//   // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
//   final FlutterBluePlus flutterBlue = FlutterBluePlus();
//   List<BluetoothDevice> _devices = [];
//   BluetoothDevice? _selectedDevice;
//   BluetoothCharacteristic? _writeCharacteristic;
//   BluetoothCharacteristic? _readCharacteristic;
//   String _status = "Select a device to connect";
//   String _speed = "Speed: --";
//   String _distance = "Distance: 0.00 m";
//   bool _isMeasuring = false;
//   List<Map<String, dynamic>> _speedData = [];
//   double _totalDistance = 0.0;
//   List<String> _dtcCodes = [];
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
//     } else {
//       print("Bluetooth permissions denied");
//     }
//   }
//
//   Future<bool> _requestBluetoothPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//       Permission.location,
//     ].request();
//
//     return statuses.values.every((status) => status.isGranted);
//   }
//
//   Future<void> _listDevices() async {
//     _devices.clear();
//     // flutterBlue.startScan(timeout: Duration(seconds: 5));
//     // FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//     FlutterBluePlus.startScan(
//       withServices: [],
//       withNames: [],
//       withKeywords: [],
//       timeout: Duration(seconds: 10),
//     );
//
//
//     // flutterBlue.scanResults.listen((results) {
//     FlutterBluePlus.scanResults.listen((results){
//       for (ScanResult result in results) {
//         if (!_devices.contains(result.device)) {
//           setState(() {
//             _devices.add(result.device);
//           });
//         }
//       }
//     });
//
//     await Future.delayed(Duration(seconds: 5));
//     FlutterBluePlus.stopScan();
//   }
//
//   Future<void> _connectToOBD() async {
//     if (_selectedDevice == null) {
//       setState(() => _status = "No device selected");
//       return;
//     }
//
//     try {
//       await _selectedDevice!.connect(autoConnect: false);
//       List<BluetoothService> services = await _selectedDevice!.discoverServices();
//
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _writeCharacteristic = characteristic;
//           }
//           if (characteristic.properties.notify || characteristic.properties.read) {
//             _readCharacteristic = characteristic;
//             await _readCharacteristic!.setNotifyValue(true);
//             _readCharacteristic!.value.listen(_onDataReceived);
//           }
//         }
//       }
//
//       await Future.delayed(Duration(milliseconds: 500));
//       setState(() => _status = "Connected to ${_selectedDevice!.name}");
//     } catch (e) {
//       setState(() => _status = "Connection failed: $e");
//     }
//   }
//
//   void _onDataReceived(List<int> data) {
//     final response = utf8.decode(data).trim();
//     final speedMatch = RegExp(r"41 0D ([0-9A-F]{2})").firstMatch(response);
//     final dtcMatch = RegExp(r"43 ([0-9A-F ]+)").firstMatch(response);
//
//     if (speedMatch != null) {
//       final speedValue = int.parse(speedMatch.group(1)!, radix: 16);
//       final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
//
//       setState(() {
//         _speedData.add({"time": currentTime, "speed": speedValue});
//         _speed = "Speed: $speedValue km/h";
//       });
//
//       _calculateDistance();
//     } else if (dtcMatch != null){
//       final dtcResponse = dtcMatch.group(1)!;
//       if (dtcResponse.trim().isEmpty || dtcResponse == "00" || dtcResponse == "NO DATA") {
//         setState(() {
//           _dtcCodes = ["No error codes found"];
//         });
//       } else {
//         _parseDTCs(dtcResponse);
//       }
//       // _parseDTCs(dtcMatch.group(1)!);
//     }
//   }
//
//   Future<void> _sendOBDCommand(String command) async {
//     if (_writeCharacteristic == null) return;
//     await _writeCharacteristic!.write(utf8.encode(command), withoutResponse: false);
//     await Future.delayed(Duration(milliseconds: 200));
//   }
//
//   void _calculateDistance() {
//     if (_speedData.length < 2) return;
//
//     final last = _speedData.length - 1;
//     final v1 = _speedData[last - 1]["speed"] / 3.6;
//     final v2 = _speedData[last]["speed"] / 3.6;
//     final t1 = _speedData[last - 1]["time"];
//     final t2 = _speedData[last]["time"];
//     final timeDiff = t2 - t1;
//
//     if (timeDiff > 0) {
//       final distanceSegment = ((v1 + v2) / 2) * timeDiff;
//       _totalDistance += distanceSegment;
//
//       setState(() => _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} m");
//     }
//   }
//
//   void _toggleMeasurement() {
//     setState(() {
//       _isMeasuring = !_isMeasuring;
//       _status = _isMeasuring ? "Measuring..." : "Measurement stopped";
//     });
//
//     if (_isMeasuring) _startContinuousReading();
//   }
//
//   Future<void> _startContinuousReading() async {
//     while (_isMeasuring) {
//       await _sendOBDCommand("010D\r");
//       await Future.delayed(Duration(milliseconds: 500));
//     }
//   }
//
//   Future<void> _readDTCs() async {
//     if (_writeCharacteristic == null) {
//       setState(() => _status = "Not connected to OBD-II");
//       return;
//     }
//
//     await _sendOBDCommand("03\r");
//   }
//
//   void _parseDTCs(String response) {
//     List<String> dtcList = [];
//     response = response.replaceAll(" ", "");
//
//     // Check if the response contains valid DTCs
//     if (response.isEmpty || response == "00" || response == "NODATA") {
//       setState(() {
//         _dtcCodes = ["No error codes found"];
//       });
//       return;
//     }
//
//     // Parse DTCs
//     for (int i = 0; i < response.length; i += 4) {
//       if (i + 4 <= response.length) {
//         dtcList.add(_formatDTC(response.substring(i, i + 4)));
//       }
//     }
//
//     setState(() {
//       _dtcCodes = dtcList;
//     });
//   }
//
//   String _formatDTC(String code) {
//     String type = code[0];
//     String formattedType = {
//       '0': 'P0', '1': 'P1', '2': 'P2', '3': 'P3',
//       '4': 'C0', '5': 'C1', '6': 'C2', '7': 'C3',
//       '8': 'B0', '9': 'B1', 'A': 'B2', 'B': 'B3',
//       'C': 'U0', 'D': 'U1', 'E': 'U2', 'F': 'U3'
//     }[type]!;
//     return "$formattedType${code.substring(1)}";
//   }
//
//   @override
//   void dispose() {
//     _selectedDevice?.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("OBD-II Diagnostics"), backgroundColor: Colors.blueAccent),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(_status, style: TextStyle(fontSize: 18)),
//             SizedBox(height: 10),
//             DropdownButton<BluetoothDevice>(
//               hint: Text("Select Device"),
//               value: _selectedDevice,
//               onChanged: (device) => setState(() => _selectedDevice = device),
//               items: _devices
//                   .map((device) => DropdownMenuItem(value: device, child: Text(device.name ?? "Unknown")))
//                   .toList(),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(onPressed: _connectToOBD, child: Text("Connect")),
//             ElevatedButton(onPressed: _toggleMeasurement, child: Text(_isMeasuring ? "Stop Measuring" : "Start Measuring")),
//             ElevatedButton(onPressed: _readDTCs, child: Text("Read Trouble Codes")),
//             SizedBox(height: 20),
//             Text(_speed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(_distance, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             if (_dtcCodes.isNotEmpty) ...[
//               SizedBox(height: 10),
//               Text("Trouble Codes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ..._dtcCodes.map((code) => Text(code, style: TextStyle(fontSize: 16)))
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'dart:convert';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:typed_data';
//
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
//   // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
//   final FlutterBluePlus flutterBlue = FlutterBluePlus();
//   List<BluetoothDevice> _devices = [];
//   BluetoothDevice? _selectedDevice;
//   BluetoothCharacteristic? _writeCharacteristic;
//   BluetoothCharacteristic? _readCharacteristic;
//   String _status = "Select a device to connect";
//   String _speed = "Speed: --";
//   String _distance = "Distance: 0.00 m";
//   bool _isMeasuring = false;
//   List<Map<String, dynamic>> _speedData = [];
//   double _totalDistance = 0.0;
//   List<String> _dtcCodes = [];
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
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//       Permission.location,
//     ].request();
//
//     return statuses.values.every((status) => status.isGranted);
//   }
//
//   Future<void> _listDevices() async {
//     _devices.clear();
//     // flutterBlue.startScan(timeout: Duration(seconds: 5));
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
//
//     // flutterBlue.scanResults.listen((results) {
//     FlutterBluePlus.scanResults.listen((results){
//       for (ScanResult result in results) {
//         if (!_devices.contains(result.device)) {
//           setState(() {
//             _devices.add(result.device);
//           });
//         }
//       }
//     });
//
//     await Future.delayed(Duration(seconds: 5));
//     FlutterBluePlus.stopScan();
//   }
//
//   Future<void> _connectToOBD() async {
//     if (_selectedDevice == null) {
//       setState(() => _status = "No device selected");
//       return;
//     }
//
//     try {
//       await _selectedDevice!.connect();
//       List<BluetoothService> services = await _selectedDevice!.discoverServices();
//
//       for (var service in services) {
//         for (var characteristic in service.characteristics) {
//           if (characteristic.properties.write) {
//             _writeCharacteristic = characteristic;
//           }
//           if (characteristic.properties.notify || characteristic.properties.read) {
//             _readCharacteristic = characteristic;
//             await _readCharacteristic!.setNotifyValue(true);
//             _readCharacteristic!.value.listen(_onDataReceived);
//           }
//         }
//       }
//
//       setState(() => _status = "Connected to ${_selectedDevice!.name}");
//     } catch (e) {
//       setState(() => _status = "Connection failed: $e");
//     }
//   }
//
//   void _onDataReceived(List<int> data) {
//     final response = utf8.decode(data).trim();
//     final speedMatch = RegExp(r"41 0D ([0-9A-F]{2})").firstMatch(response);
//     final dtcMatch = RegExp(r"43 ([0-9A-F ]+)").firstMatch(response);
//
//     if (speedMatch != null) {
//       final speedValue = int.parse(speedMatch.group(1)!, radix: 16);
//       final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
//
//       setState(() {
//         _speedData.add({"time": currentTime, "speed": speedValue});
//         _speed = "Speed: $speedValue km/h";
//       });
//
//       _calculateDistance();
//     } else if (dtcMatch != null){
//       final dtcResponse = dtcMatch.group(1)!;
//       if (dtcResponse.trim().isEmpty || dtcResponse == "00" || dtcResponse == "NO DATA") {
//         setState(() {
//           _dtcCodes = ["No error codes found"];
//         });
//       } else {
//         _parseDTCs(dtcResponse);
//       }
//       // _parseDTCs(dtcMatch.group(1)!);
//     }
//   }
//
//   Future<void> _sendOBDCommand(String command) async {
//     if (_writeCharacteristic == null) return;
//     await _writeCharacteristic!.write(utf8.encode(command));
//   }
//
//   void _calculateDistance() {
//     if (_speedData.length < 2) return;
//
//     final last = _speedData.length - 1;
//     final v1 = _speedData[last - 1]["speed"] / 3.6;
//     final v2 = _speedData[last]["speed"] / 3.6;
//     final t1 = _speedData[last - 1]["time"];
//     final t2 = _speedData[last]["time"];
//     final timeDiff = t2 - t1;
//
//     if (timeDiff > 0) {
//       final distanceSegment = ((v1 + v2) / 2) * timeDiff;
//       _totalDistance += distanceSegment;
//
//       setState(() => _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} m");
//     }
//   }
//
//   void _toggleMeasurement() {
//     setState(() {
//       _isMeasuring = !_isMeasuring;
//       _status = _isMeasuring ? "Measuring..." : "Measurement stopped";
//     });
//
//     if (_isMeasuring) _startContinuousReading();
//   }
//
//   Future<void> _startContinuousReading() async {
//     while (_isMeasuring) {
//       await _sendOBDCommand("010D\r");
//       await Future.delayed(Duration(milliseconds: 500));
//     }
//   }
//
//   Future<void> _readDTCs() async {
//     if (_writeCharacteristic == null) {
//       setState(() => _status = "Not connected to OBD-II");
//       return;
//     }
//
//     await _sendOBDCommand("03\r");
//   }
//
//   // void _parseDTCs(String response) {
//   //   List<String> dtcList = [];
//   //   if (response.startsWith("43")) {
//   //     response = response.substring(3).replaceAll(" ", "");
//   //     for (int i = 0; i < response.length; i += 4) {
//   //       if (i + 4 <= response.length) {
//   //         dtcList.add(_formatDTC(response.substring(i, i + 4)));
//   //       }
//   //     }
//   //   }
//   //
//   //   setState(() {
//   //     _dtcCodes = dtcList;
//   //   });
//   // }
//
//   void _parseDTCs(String response) {
//     List<String> dtcList = [];
//     response = response.replaceAll(" ", "");
//
//     // Check if the response contains valid DTCs
//     if (response.isEmpty || response == "00" || response == "NODATA") {
//       setState(() {
//         _dtcCodes = ["No error codes found"];
//       });
//       return;
//     }
//
//     // Parse DTCs
//     for (int i = 0; i < response.length; i += 4) {
//       if (i + 4 <= response.length) {
//         dtcList.add(_formatDTC(response.substring(i, i + 4)));
//       }
//     }
//
//     setState(() {
//       _dtcCodes = dtcList;
//     });
//   }
//
//   String _formatDTC(String code) {
//     String type = code[0];
//     String formattedType = {
//       '0': 'P0', '1': 'P1', '2': 'P2', '3': 'P3',
//       '4': 'C0', '5': 'C1', '6': 'C2', '7': 'C3',
//       '8': 'B0', '9': 'B1', 'A': 'B2', 'B': 'B3',
//       'C': 'U0', 'D': 'U1', 'E': 'U2', 'F': 'U3'
//     }[type]!;
//     return "$formattedType${code.substring(1)}";
//   }
//
//   @override
//   void dispose() {
//     _selectedDevice?.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("OBD-II Diagnostics"), backgroundColor: Colors.blueAccent),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Text(_status, style: TextStyle(fontSize: 18)),
//             SizedBox(height: 10),
//             DropdownButton<BluetoothDevice>(
//               hint: Text("Select Device"),
//               value: _selectedDevice,
//               onChanged: (device) => setState(() => _selectedDevice = device),
//               items: _devices
//                   .map((device) => DropdownMenuItem(value: device, child: Text(device.name ?? "Unknown")))
//                   .toList(),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(onPressed: _connectToOBD, child: Text("Connect")),
//             ElevatedButton(onPressed: _toggleMeasurement, child: Text(_isMeasuring ? "Stop Measuring" : "Start Measuring")),
//             ElevatedButton(onPressed: _readDTCs, child: Text("Read Trouble Codes")),
//             SizedBox(height: 20),
//             Text(_speed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(_distance, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             if (_dtcCodes.isNotEmpty) ...[
//               SizedBox(height: 10),
//               Text("Trouble Codes:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               ..._dtcCodes.map((code) => Text(code, style: TextStyle(fontSize: 16)))
//             ]
//           ],
//         ),
//       ),
//     );
//   }
// }
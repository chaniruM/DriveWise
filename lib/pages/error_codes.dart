import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class TroubleCodePage extends StatefulWidget {
  @override
  _TroubleCodePageState createState() => _TroubleCodePageState();
}

class _TroubleCodePageState extends State<TroubleCodePage> {
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  List<Map<String, String>> troubleCodes = [];
  bool _isConnecting = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _monitorBluetoothState();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _selectedDevice?.disconnect();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.bluetooth.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.bluetoothScan.isGranted &&
        await Permission.location.isGranted) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  void _monitorBluetoothState() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _listDevices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bluetooth is off. Please enable Bluetooth.")),
        );
      }
    });
  }

  Future<void> _listDevices() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
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

    await Future.delayed(Duration(seconds: 10));
    FlutterBluePlus.stopScan();
    setState(() => _isScanning = false);
  }

  Future<void> _connectToOBD() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No OBD-II device found.")),
      );
      return;
    }

    setState(() => _isConnecting = true);

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
            // We'll set up listeners specifically when needed, not here
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connected to ${_selectedDevice!.name}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection failed: $e")),
      );
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  Future<void> _readDTCs() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not connected to OBD-II")),
      );
      return;
    }

    setState(() {
      troubleCodes.clear(); // Clear existing codes before new scan
    });

    await _connectToOBD();

    if (_readCharacteristic == null || _writeCharacteristic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to find required BLE characteristics")),
      );
      return;
    }

    // Create a single subscription to process all responses
    final subscription = _readCharacteristic!.value.listen(null);
    subscription.onData((data) {
      final response = utf8.decode(data).trim();
      final dtcMatch = RegExp(r"43 ([0-9A-F ]+)").firstMatch(response);

      if (dtcMatch != null) {
        final dtcResponse = dtcMatch.group(1)!;
        if (dtcResponse.trim().isEmpty || dtcResponse == "00" || dtcResponse == "NO DATA") {
          setState(() {
            troubleCodes.add({"code": "No error codes found", "type": "Current scan", "status": "N/A"});
          });
        } else {
          _parseDTCs(dtcResponse, "Current scan");
        }
      } else if (response.contains("47")) {
        // For pending codes (mode 07)
        final pendingMatch = RegExp(r"47 ([0-9A-F ]+)").firstMatch(response);
        if (pendingMatch != null) {
          final dtcResponse = pendingMatch.group(1)!;
          if (dtcResponse.trim().isEmpty || dtcResponse == "00" || dtcResponse == "NO DATA") {
            setState(() {
              troubleCodes.add({"code": "No pending codes found", "type": "Pending", "status": "N/A"});
            });
          } else {
            _parseDTCs(dtcResponse, "Pending");
          }
        }
      } else if (response.contains("4A")) {
        // For permanent codes (mode 0A)
        final permMatch = RegExp(r"4A ([0-9A-F ]+)").firstMatch(response);
        if (permMatch != null) {
          final dtcResponse = permMatch.group(1)!;
          if (dtcResponse.trim().isEmpty || dtcResponse == "00" || dtcResponse == "NO DATA") {
            setState(() {
              troubleCodes.add({"code": "No permanent codes found", "type": "Permanent", "status": "N/A"});
            });
          } else {
            _parseDTCs(dtcResponse, "Permanent");
          }
        }
      }
    });

    try {
      // Request current DTCs (Mode 03)
      await _writeCharacteristic!.write(utf8.encode("03\r"), withoutResponse: false);
      await Future.delayed(Duration(milliseconds: 1000));

      // Request pending DTCs (Mode 07)
      await _writeCharacteristic!.write(utf8.encode("07\r"), withoutResponse: false);
      await Future.delayed(Duration(milliseconds: 1000));

      // Request permanent DTCs (Mode 0A)
      await _writeCharacteristic!.write(utf8.encode("0A\r"), withoutResponse: false);
      await Future.delayed(Duration(milliseconds: 1000));
    } finally {
      // Clean up subscription after all commands have been processed
      await subscription.cancel();
    }

    if (troubleCodes.isEmpty) {
      setState(() {
        troubleCodes.add({"code": "No diagnostic trouble codes found", "type": "All", "status": "Vehicle OK"});
      });
    }
  }

  void _parseDTCs(String response, String dtcType) {
    List<Map<String, String>> dtcList = [];
    response = response.replaceAll(" ", "");

    if (response.isEmpty || response == "00" || response == "NODATA") {
      setState(() {
        troubleCodes.add({"code": "No error codes found", "type": dtcType, "status": "N/A"});
      });
      return;
    }

    for (int i = 0; i < response.length; i += 4) {
      if (i + 4 <= response.length) {
        final code = _formatDTC(response.substring(i, i + 4));
        final description = _getDTCDescription(code);
        dtcList.add({"code": code, "type": dtcType, "status": description});
      }
    }

    setState(() {
      troubleCodes.addAll(dtcList);
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

  String _getDTCDescription(String code) {
    Map<String, String> dtcMeanings = {
      // Powertrain (P0XXX) - Engine & Transmission Related
      "P0100": "Mass Airflow (MAF) Sensor Circuit Malfunction",
      "P0101": "MAF Sensor Performance Problem",
      "P0102": "MAF Sensor Low Input",
      "P0103": "MAF Sensor High Input",
      "P0110": "Intake Air Temperature Sensor Circuit Malfunction",
      "P0115": "Engine Coolant Temperature Sensor Malfunction",
      "P0119": "Engine Coolant Temperature Sensor 1 Circuit Intermittent/Erratic",
      "P0120": "Throttle Position Sensor (TPS) Malfunction",
      "P0130": "Oxygen Sensor (O2 Sensor) Circuit Malfunction (Bank 1 Sensor 1)",
      "P0133": "O2 Sensor Slow Response (Bank 1 Sensor 1)",
      "P0171": "System Too Lean (Bank 1)",
      "P0172": "System Too Rich (Bank 1)",
      "P0201": "Injector Circuit Malfunction (Cylinder 1)",
      "P0218": "Transmission Over Temperature Condition",
      "P0220": "Throttle/Pedal Position Sensor/Switch 'B' Circuit Malfunction",
      "P0230": "Fuel Pump Primary Circuit Malfunction",
      "P0300": "Random/Multiple Cylinder Misfire Detected",
      "P0301": "Cylinder 1 Misfire Detected",
      "P0302": "Cylinder 2 Misfire Detected",
      "P0303": "Cylinder 3 Misfire Detected",
      "P0304": "Cylinder 4 Misfire Detected",
      "P0325": "Knock Sensor Circuit Malfunction",
      "P0335": "Crankshaft Position Sensor Malfunction",
      "P0340": "Camshaft Position Sensor Malfunction",
      "P0400": "Exhaust Gas Recirculation (EGR) Flow Malfunction",
      "P0401": "Exhaust Gas Recirculation (EGR) Flow Insufficient",
      "P0420": "Catalyst System Efficiency Below Threshold (Bank 1)",
      "P0440": "EVAP System Malfunction",
      "P0442": "EVAP System Small Leak Detected",
      "P0455": "EVAP System Large Leak Detected",
      "P0500": "Vehicle Speed Sensor Malfunction",
      "P0505": "Idle Control System Malfunction",
      "P0506": "Idle Control System RPM Lower Than Expected",
      "P0507": "Idle Control System RPM Higher Than Expected",
      "P0601": "ECU Memory Checksum Error",
      "P0700": "Transmission Control System Malfunction",
      "P0740": "Torque Converter Clutch Circuit Malfunction",

      // Chassis (C0XXX) - Brakes, ABS, Steering
      "C0035": "Wheel Speed Sensor Malfunction (Front Left)",
      "C0040": "Wheel Speed Sensor Malfunction (Front Right)",
      "C0050": "Wheel Speed Sensor Malfunction (Rear Right)",
      "C0110": "ABS Pump Motor Circuit Malfunction",
      "C0121": "ABS Hydraulic Pump Motor Circuit Open",
      "C0245": "Wheel Speed Sensor Frequency Error",

      // Body (B0XXX) - Airbags, Climate Control, Power Windows
      "B0020": "Airbag Deployment Circuit Fault",
      "B0051": "Passenger Airbag Disable Indicator Malfunction",
      "B0100": "Airbag Deployment Commanded",
      "B0140": "Air Conditioning Sensor Circuit Malfunction",
      "B1000": "ECU Malfunction",

      // Network (U0XXX) - CAN Bus, Communication Issues
      "U0100": "Lost Communication with ECM/PCM",
      "U0121": "Lost Communication with ABS Control Module",
      "U0140": "Lost Communication with Body Control Module",
      "U0401": "Invalid Data Received from ECM/PCM",
    };

    return dtcMeanings[code] ?? "Unknown Trouble Code";
  }

  void connectScanner() {
    _readDTCs();
  }

  void clearFaults() {
    if (_writeCharacteristic != null) {
      // Send the OBD-II clear fault code command (Mode 04)
      _writeCharacteristic!.write(utf8.encode("04\r"), withoutResponse: false);
    }

    setState(() {
      troubleCodes.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Clearing fault codes...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trouble Codes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.white,
          ),),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () {},
          ),
        ],
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
              onPressed: _isConnecting ? null : connectScanner,
              child: _isConnecting
                  ? const CircularProgressIndicator()
                  : const Text("Connect Scanner"),
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
                  bool isError = trouble["code"] != "No error codes found" &&
                      trouble["code"] != "No diagnostic trouble codes found" &&
                      trouble["code"] != "No pending codes found" &&
                      trouble["code"] != "No permanent codes found";

                  Color cardColor = Colors.green[300]!;
                  if (isError) {
                    cardColor = trouble["type"] == "Current scan"
                        ? Colors.red[300]!
                        : Colors.amber[300]!;
                  }

                  return Card(
                    color: cardColor,
                    child: ListTile(
                      leading: Icon(
                          isError ? LucideIcons.alertTriangle : LucideIcons.check,
                          color: Colors.white
                      ),
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
              onPressed: _selectedDevice != null ? clearFaults : null,
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
    );
  }
}
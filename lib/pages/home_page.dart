import 'dart:convert';
import 'package:drivewise/pages/MaintenanceOverview.dart';
import 'package:drivewise/services/vehicle_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  bool _isMeasuring = false;
  List<Map<String, dynamic>> _speedData = [];
  double _totalDistance = 0.0;
  double _distanceInKM = 0.0;
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  int _currentSlideIndex = 0;
  final PageController _pageController = PageController();
  String _selectedVehicle = 'Please Add a Vehicle';
  double _mileage = 0; // Starting mileage
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  bool _notificationSent = false;

  @override
  void initState() {
    super.initState();
    _requestLocPermissions();
    _requestPermissions();
    _monitorBluetoothState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _loadVehicles();
      await _loadUpcomingEvents();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.notification,
    ].request();

    statuses.forEach((permission, status) {
      print("Permission $permission: $status");
    });

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> _requestLocPermissions() async {
    await Permission.location.request();
    await Permission.locationAlways.request();
    await Permission.locationWhenInUse.request();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth is off. Please enable Bluetooth.')),
        );
      }
    });
  }

  Future<void> _listDevices() async {

    if (_bluetoothState != BluetoothAdapterState.on) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth is off. Please enable Bluetooth.')),
      );
      return;
    }

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

    await Future.delayed(Duration(seconds: 10));
    FlutterBluePlus.stopScan();
  }

  Future<void> _connectToOBD() async {
    if (_selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No device selected.')),
      );
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

      ScaffoldMessenger.of(context).showSnackBar( // Show success SnackBar
        SnackBar(content: Text("Connected to ${_selectedDevice!.name}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar( // Show error SnackBar
        SnackBar(content: Text("Connection failed: $e")),
      );
    }
  }

  void _onDataReceived(List<int> data) {
    final response = utf8.decode(data).trim();
    final speedMatch = RegExp(r"41 0D ([0-9A-F]{2})").firstMatch(response);

    if (speedMatch != null) {
      final speedValue = int.parse(speedMatch.group(1)!, radix: 16);
      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

      setState(() {
        _speedData.add({"time": currentTime, "speed": speedValue});
      });

      _calculateDistance();
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
      _distanceInKM = _totalDistance / 1000;
      setState(() {
        _mileage = _vehicles.firstWhere((vehicle) => vehicle['name'] == _selectedVehicle)['mileage'] + _distanceInKM;
      });

      // Check if target distance is reached
      if ((_mileage+150) >= _vehicles.firstWhere((vehicle) => vehicle['name'] == _selectedVehicle)['next_service'] && !_notificationSent) {
        NotiService().showNotification(
          title: 'Service due!',
          body: 'Your regular vehicle maintenance for $_selectedVehicle is due. Please book an appointment asap.',
        );
        _notificationSent = true;
      }
    }
  }

  Future<void> _startContinuousReading() async {
    while (_isMeasuring) {
      await _sendOBDCommand("010D\r");
      // testNotification();
      await Future.delayed(Duration(milliseconds: 500));
    }
  }

  Future<void> _loadVehicles() async {
    try {
      final data = await VehicleService().fetchUserVehicles();
      if (mounted) {
        setState(() {
          _vehicles = VehicleService().extractVehicles(data);
          if (_vehicles.isNotEmpty) {
            _selectedVehicle = _vehicles[0]['name'];
            _mileage = _vehicles[0]['mileage'];
          }
        });
      }
    } catch (e) {
      debugPrint('Error in _loadVehicles: $e');
      rethrow;
    }
  }

  Future<void> _loadUpcomingEvents() async {
    try {
      final data = await VehicleService().fetchUserVehicles();
      if (mounted) {
        setState(() {
          _upcomingEvents = VehicleService().extractUpcomingEvents(data);
        });
        debugPrint('Parsed _upcomingEvents: $_upcomingEvents');
      }
    } catch (e) {
      debugPrint('Error loading upcoming events: $e');
    }
  }

  void _startTracking() {
    if (!_isMeasuring) {
      // Reset distance tracking
      _totalDistance = 0.0;
      _distanceInKM = 0.0;
      _speedData = [];
      _notificationSent = false;

      // Reset to base mileage before tracking
      final baseVehicleMileage = _vehicles.firstWhere(
              (vehicle) => vehicle['name'] == _selectedVehicle
      )['mileage'];

      setState(() {
        _isMeasuring = true;
        _mileage = baseVehicleMileage;
      });
      _connectToOBD(); // Automatically connect to the device when measuring starts
      _startContinuousReading();
    }
  }

  Future<void> _stopTracking() async {
    if (_isMeasuring) {
      setState(() {
        _isMeasuring = false;
      });

      final selectedVehicle = _vehicles.firstWhere(
            (vehicle) => vehicle['name'] == _selectedVehicle,
      );

      // Debug prints
      print("Selected vehicle: $_selectedVehicle");
      print("Found vehicle: $selectedVehicle");
      print("Vehicle ID: ${selectedVehicle['id']}");
      print("New mileage: ${_mileage}");

      try {
        await VehicleService().updateMileage(
          // userId: userId,
          vehicleId: selectedVehicle['id'],
          mileage: _mileage,
        );

        setState(() {
          selectedVehicle['mileage'] += _distanceInKM;
        });
        ScaffoldMessenger.of(context).showSnackBar( // Show error SnackBar
          const SnackBar(content: Text("Updating mileage...")),
        );
      } catch (e) {
        debugPrint('Error updating mileage: $e');
        ScaffoldMessenger.of(context).showSnackBar( // Show error SnackBar
          SnackBar(content: Text("Updating Mileage Failed: $e")),
        );
      }
    }
  }

  void _onVehicleChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedVehicle = newValue;
        _mileage = _vehicles.firstWhere((vehicle) => vehicle['name'] == newValue)['mileage'];
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _selectedDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Convert mileage to display format (91366 -> 9 1 3 6 6)
    // String mileageStr = _mileage.toString().padLeft(5, '0');
    String mileageStr = _mileage.toStringAsFixed(1).padLeft(5, '0');
    List<String> mileageDigits = mileageStr.split('');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Promotional Gallery
            _buildPromotionalGallery(),

            // Mileage Display and Tracking
            _buildMileageTracker(mileageDigits),

            // Vehicle Selector
            _buildVehicleSelector(),

            // Upcoming Events
            _buildUpcomingEvents(),

            const SizedBox(height: 80), // Space for bottom nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionalGallery() {
    List<Widget> promotionalSlides = [
      _buildPromotionalSlide(
        'A FAMILY OWNED BUSINESS\nWITH A LARGE, CLEAN WORKSHOP',
        '30 YEARS OF\nEXPERIENCE',
        'WITH ALL WORK BACKED BY A PARTS\nAND LABOUR GUARANTEE.',
        'https://www.bmfi.com.au/thumbnaillarge/Pic1.jpg',
      ),
      _buildPromotionalSlide(
        'EXPERT TECHNICIANS',
        'CERTIFIED\nSERVICE',
        'GUARANTEED QUALITY REPAIRS\nAND MAINTENANCE.',
        'https://www.toyota.lk/wp-content/uploads/2024/10/Untitled-design.jpg',
      ),
      _buildPromotionalSlide(
        'GENUINE PARTS ONLY',
        'QUALITY\nASSURED',
        'WE NEVER COMPROMISE ON\nTHE PARTS WE USE.',
        'https://totachi.lk/wp-content/uploads/2023/09/Mixed-Products_for-Facebook-Banner_1640x586.jpg',
      ),
    ];

    return Container(
      color: const Color(0xFF0A1128),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentSlideIndex = index;
                });
              },
              children: promotionalSlides,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              promotionalSlides.length,
                  (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentSlideIndex == index
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPromotionalSlide(String topText, String middleText, String bottomText, String imagePath) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          color: const Color(0xFF1A2238),
          child: Align(
            alignment: Alignment.centerRight,
            child: ClipRRect( // Clip the image to prevent overflow
              child: Image.network(
                imagePath,
                fit: BoxFit.fill, // Use BoxFit.cover to fill the space
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  // Handle image loading errors
                  return const Center(
                    child: Icon(Icons.error_outline,
                        size: 100, color: Colors.white54),
                  );
                },
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        Positioned(
          left: 20,
          top: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(
                  middleText,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                bottomText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMileageTracker(List<String> mileageDigits) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          // Mileage Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...mileageDigits.asMap().map((index, digit) {
                // Check if the digit is a decimal point
                if (digit == '.') {
                  return MapEntry(
                    index,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        '.',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                } else {
                  return MapEntry(index, _buildMileageDigit(digit));
                }
              }).values.toList(),
              const SizedBox(width: 10),
              const Text(
                  'km',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Start/Stop Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _startTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Start', style: TextStyle(fontSize: 18)),
              ),
              ElevatedButton(
                onPressed: _stopTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Stop', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMileageDigit(String digit) {
    return Container(
      width: 32,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownButton<String>(
          value: _selectedVehicle,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          underline: Container(),
          onChanged: _onVehicleChanged,
          items: _vehicles.map<DropdownMenuItem<String>>((vehicle) {
            return DropdownMenuItem<String>(
              value: vehicle['name'],
              child: Text(vehicle['name']),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Upcoming events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ),
          ...(_upcomingEvents.map((event) => _buildEventCard(event)).toList()),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final DateTime? eventDate = event['date'];
    final String year = eventDate != null ? DateFormat('yyyy').format(eventDate) : '';
    final String month = eventDate != null ? DateFormat('MMM').format(eventDate) : '';
    final String day = eventDate != null ? eventDate.day.toString() : '';
    final double? mileageDifference = event['mileageDifference'];
    final String formattedMileageDifference = mileageDifference?.toStringAsFixed(1) ?? '0.0';
    final String eventType = event['event'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (eventDate != null) Text(
                  year,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (eventDate != null) Text(
                  month,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (eventDate != null) Text(
                  day,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (mileageDifference != null && eventDate == null) Text(
                  '$formattedMileageDifference km',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    event['event'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['vehicle'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green[500],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(100),
                topLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
                bottomLeft: Radius.circular(100),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.check, color: Colors.black),
              onPressed: () => _handleEventAction(event),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEventAction(Map<String, dynamic> event) async {
    final String eventType = event['event'];
    final String vehicleName = event['vehicle'];

    // Find the corresponding vehicle object
    final vehicle = _vehicles.firstWhere(
          (v) => v['name'] == vehicleName || "${v['make']} ${v['model']}" == vehicleName,
      orElse: () => <String, dynamic>{},
    );

    if (vehicle.isEmpty) {
      debugPrint('Vehicle not found for event: $eventType');
      return;
    }

    // Handle based on event type
    if (eventType.contains('Expiry')) {
      try {
        // Determine which expiry date to update
        String expiryType;
        if (eventType.contains('License')) {
          expiryType = 'license_expiry_date';
        } else if (eventType.contains('Insurance')) {
          expiryType = 'insurance_expiry_date';
        } else if (eventType.contains('Emissions') || eventType.contains('Emmissions')) {
          expiryType = 'emmissions_expiry_date';
        } else {
          debugPrint('Unknown expiry type: $eventType');
          return;
        }

        // Get current date from event
        final DateTime? currentDate = event['date'];
        if (currentDate == null) {
          debugPrint('No date found for event: $eventType');
          return;
        }

        // Calculate new expiry date (1 year later)
        final DateTime newExpiryDate = DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );

        // update expiry date
        await VehicleService().updateVehicleExpiry(
          vehicleId: vehicle['id'],
          expiryType: expiryType,
          newDate: newExpiryDate,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$eventType extended by 1 year')),
        );

        // Refresh data
        await _loadUpcomingEvents();

      } catch (e) {
        debugPrint('Error updating expiry date: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update expiry date: $e')),
        );
      }
    } else if (eventType.contains('Service')) {
      // Navigate to maintenance page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaintenanceOverview(),
        ),
      );
    }
  }
}
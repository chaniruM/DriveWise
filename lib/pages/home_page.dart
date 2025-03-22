import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  double targetDistance = 0.5;
  BluetoothDevice? _selectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  // String _distance = "Distance: 0.00 km";
  bool _isMeasuring = false;
  List<Map<String, dynamic>> _speedData = [];
  double _totalDistance = 0.0;
  double _distanceInKM = 0.0;
  BluetoothAdapterState _bluetoothState = BluetoothAdapterState.unknown;
  String _status = "Press Start to read distance";

  int _currentSlideIndex = 0;
  final PageController _pageController = PageController();
  String _selectedVehicle = 'Jimny';
  double _mileage = 91366; // Starting mileage shown in the image
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  List<Map<String, dynamic>> _recentSearches = [];
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
      // Mock data for demonstration, replace with actual DB connection
      await _loadVehicles();
      await _loadUpcomingEvents();
      await _loadRecentSearches();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      // Permission.location,
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
        setState(() {
          _status = "Bluetooth is off. Please enable Bluetooth.";
        });
      }
    });
  }

  Future<void> _listDevices() async {

    if (_bluetoothState != BluetoothAdapterState.on) {
      setState(() {
        _status = "Bluetooth is off. Please enable Bluetooth.";
      });
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
    // final dtcMatch = RegExp(r"43 ([0-9A-F ]+)").firstMatch(response);

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

      // final distanceInKilometers = _totalDistance / 1000;
      _distanceInKM = _totalDistance / 1000;
      // setState(() => _distance = "Distance: ${distanceInKilometers.toStringAsFixed(2)} km");
      // setState(() => _distance = "Distance: ${_distanceInKM.toStringAsFixed(2)} km");
      setState(() {
        // _distance = "Distance: ${_distanceInKM.toStringAsFixed(2)} km";
        _mileage = _vehicles.firstWhere((vehicle) => vehicle['name'] == _selectedVehicle)['mileage'] + _distanceInKM;
      });
      // setState(() => _distance = "Distance: ${_totalDistance.toStringAsFixed(2)} m");
      // Check if target distance is reached
      // if (distanceInKilometers >= targetDistance) {
      // if (_distanceInKM >= targetDistance){
      if (_mileage >= _vehicles.firstWhere((vehicle) => vehicle['name'] == _selectedVehicle)['next_service'] && !_notificationSent) {
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
    const userId = '67cea5d3ef36ebb22c2d7bdb';
    final response = await http.get(Uri.parse('http://192.168.154.131:5000/api/vehicles/$userId'));
    if (response.statusCode == 200) {
      // final List<dynamic> data = jsonDecode(response.body);
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> vehicles = data['vehicles'];

      // Debug: Print the fetched data
      debugPrint('Fetched vehicles: $vehicles');

      setState(() {
        _vehicles = vehicles.map((vehicle) => {
          'name': vehicle['nickname'],
          // 'name': '${vehicle['make']} ${vehicle['model']}',
          'year': vehicle['year'],
          'mileage': vehicle['currentMileage'],
          'id': vehicle['id'],
          'next_service': vehicle['nextService']
        }).toList();
        if (_vehicles.isNotEmpty) {
          _selectedVehicle = _vehicles[0]['name'];
          _mileage = _vehicles[0]['mileage'];
        }
      });

      // Debug: Print the parsed _vehicles
      debugPrint('Parsed _vehicles: $_vehicles');

    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  Future<void> _loadUpcomingEvents() async {

    const userId = '67cea5d3ef36ebb22c2d7bdb';
    try {
      final response = await http.get(Uri.parse('http://192.168.154.131:5000/api/vehicles/$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> upcomingEvents = data['upcomingEvents'];

        setState(() {
          _upcomingEvents = upcomingEvents.map((event) => {
            'date': event['date'] != null ? DateTime.parse(event['date']) : null,
            'event': event['type'],
            'vehicle': event['vehicle'],
            'mileageDifference': event['mileageDifference'],
          }).toList();
        });

        // Debug: Print the parsed _upcomingEvents
        debugPrint('Parsed _upcomingEvents: $_upcomingEvents');

      } else {
        throw Exception('Failed to load upcoming events');
      }
    } catch (e) {
      debugPrint('Error loading upcoming events: $e');
    }
  }

  Future<void> _loadRecentSearches() async {
    // mock data
    setState(() {
      _recentSearches = [
        {'name': 'Engine Oil 5W-30', 'imageUrl': 'assets/engine_oil.png'},
        {'name': 'Air Filter', 'imageUrl': 'assets/air_filter.png'},
      ];
    });
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
        // _distance = "Distance: 0.00 km";
      });
      _connectToOBD(); // Automatically connect to the device when measuring starts
      _startContinuousReading();
    }
  }

  Future<void> _stopTracking() async {
    if (_isMeasuring) {
      // _mileageTimer?.cancel();

      setState(() {
        _isMeasuring = false;
      });

      final selectedVehicle = _vehicles.firstWhere(
            (vehicle) => vehicle['name'] == _selectedVehicle,
        // orElse: () => null,
      );

      // Debug prints
      print("Selected vehicle: $_selectedVehicle");
      print("Found vehicle: $selectedVehicle");
      print("Vehicle ID: ${selectedVehicle['id']}");
      print("New mileage: ${_mileage}");
      // print("New mileage: ${_mileage + _distanceInKM}");

      final response = await http.put(
        Uri.parse('http://192.168.154.131:5000/api/updateMileage'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': "67cea5d3ef36ebb22c2d7bdb",
          'vehicleId': selectedVehicle['id'],
          'mileage': _mileage,
          // 'mileage': _mileage + _distanceInKM,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update mileage: ${response.body}');
      } else {
        setState(() {
          selectedVehicle['mileage'] += _distanceInKM;
        });
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
    // _mileageTimer?.cancel();
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

            // Recently Searched
            _buildRecentlySearched(),

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
        'assets/workshop_image.jpg',
      ),
      _buildPromotionalSlide(
        'EXPERT TECHNICIANS',
        'CERTIFIED\nSERVICE',
        'GUARANTEED QUALITY REPAIRS\nAND MAINTENANCE.',
        'assets/technician_image.jpg',
      ),
      _buildPromotionalSlide(
        'GENUINE PARTS ONLY',
        'QUALITY\nASSURED',
        'WE NEVER COMPROMISE ON\nTHE PARTS WE USE.',
        'assets/parts_image.jpg',
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
          color: const Color(0xFF1A2238), // Darkened placeholder for image
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 250,
              height: 250,
              color: const Color(0xFF2A324B), // Placeholder for car image
              child: const Center(
                child: Icon(Icons.car_repair, size: 100, color: Colors.white54),
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
                  border: Border.all(color: Colors.white),
                ),
                child: Text(
                  middleText,
                  style: const TextStyle(
                    color: Colors.white,
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
              // ...mileageDigits.map((digit) => _buildMileageDigit(digit)).toList(),
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

          // Text(_distance, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    final String month = eventDate != null ? DateFormat('MMM').format(eventDate) : '';
    final String day = eventDate != null ? eventDate.day.toString() : '';
    final double? mileageDifference = event['mileageDifference'];
    final String formattedMileageDifference = mileageDifference?.toStringAsFixed(1) ?? '0.0';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 85,
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
                if (mileageDifference != null) Text(
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
        ],
      ),
    );
  }

  Widget _buildRecentlySearched() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Recently searched',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          ),
          // If we have recent searches, display them in a row
          if (_recentSearches.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentSearches.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder for image
                        Container(
                          height: 50,
                          width: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.search),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _recentSearches[index]['name'],
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 100,
              alignment: Alignment.center,
              child: const Text('No recent searches yet'),
            ),
        ],
      ),
    );
  }
}
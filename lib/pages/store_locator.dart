import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class StoreLocator extends StatefulWidget {
  @override
  _StoreLocatorState createState() => _StoreLocatorState();
}

class _StoreLocatorState extends State<StoreLocator> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  LatLng? _currentPosition;
  List<Map<String, dynamic>> _storesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permission still denied - show message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle permanently denied permissions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied, please enable in settings'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _storesList = await getNearbyStores(position.latitude, position.longitude);

      setState(() {
        _markers = _storesList.map((store) {
          return Marker(
            markerId: MarkerId(store["place_id"]),
            position: LatLng(store["lat"], store["lng"]),
            infoWindow: InfoWindow(
              title: store["name"],
              snippet: _buildSnippet(store),
              onTap: () {
                _showStoreDetails(store);
              },
            ),
          );
        }).toSet();
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildSnippet(Map<String, dynamic> store) {
    String snippet = store["address"];
    if (store["open_now"] != null) {
      snippet += " • ${store["open_now"] ? "Open" : "Closed"}";
    }
    return snippet;
  }

  Future<List<Map<String, dynamic>>> getNearbyStores(double lat, double lng) async {
    const apiKey = "AIzaSyAl-IPnR4NKg16QodNw_KVlvXpmF6HZOm4";
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
            "?location=$lat,$lng"
            "&radius=10000"
            "&type=store"
            "&keyword=engine+oil|lubricants|transmission+oil"
            "&key=$apiKey"
            "&fields=name,vicinity,geometry,place_id,opening_hours,formatted_phone_number"
    );

    final response = await http.get(url);
    print("Google API Response: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List stores = data["results"];

      List<Map<String, dynamic>> storesList = [];

      // get basic info and sort by distance
      for (var store in stores) {
        storesList.add({
          "name": store["name"],
          "address": store["vicinity"],
          "lat": store["geometry"]["location"]["lat"],
          "lng": store["geometry"]["location"]["lng"],
          "place_id": store["place_id"],
          "open_now": store["opening_hours"] != null ? store["opening_hours"]["open_now"] : null,
        });
      }

      // Sort by distance
      storesList.sort((a, b) {
        double distA = Geolocator.distanceBetween(
            lat, lng, a["lat"], a["lng"]);
        double distB = Geolocator.distanceBetween(
            lat, lng, b["lat"], b["lng"]);
        return distA.compareTo(distB);
      });

      // Get detailed info for top 10 closest stores
      List<Map<String, dynamic>> detailedStores = [];
      for (int i = 0; i < storesList.length && i < 10; i++) {
        var storeDetails = await getStoreDetails(storesList[i]["place_id"], apiKey);
        detailedStores.add({
          ...storesList[i],
          "phone": storeDetails["phone"],
          "website": storeDetails["website"],
          "opening_hours": storeDetails["opening_hours"],
          "rating": storeDetails["rating"],
        });
      }

      return detailedStores;
    } else {
      throw Exception("Failed to load nearby stores");
    }
  }

  Future<Map<String, dynamic>> getStoreDetails(String placeId, String apiKey) async {
    final detailsUrl = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json"
            "?place_id=$placeId"
            "&fields=name,formatted_phone_number,website,opening_hours,rating"
            "&key=$apiKey"
    );

    final response = await http.get(detailsUrl);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data["result"];

      Map<String, dynamic> details = {
        "phone": result["formatted_phone_number"] ?? "Not available",
        "website": result["website"] ?? "Not available",
        "rating": result["rating"] ?? 0.0,
      };

      if (result["opening_hours"] != null) {
        details["opening_hours"] = result["opening_hours"]["weekday_text"] ?? [];
      } else {
        details["opening_hours"] = [];
      }

      return details;
    } else {
      return {
        "phone": "Not available",
        "website": "Not available",
        "opening_hours": [],
        "rating": 0.0,
      };
    }
  }

  void _showStoreDetails(Map<String, dynamic> store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    store["name"],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 4),
                      Expanded(child: Text(store["address"])),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (store["open_now"] != null)
                    Row(
                      children: [
                        Icon(
                            Icons.access_time,
                            size: 18,
                            color: store["open_now"] ? Colors.green : Colors.red
                        ),
                        SizedBox(width: 4),
                        Text(
                          store["open_now"] ? "Open Now" : "Closed",
                          style: TextStyle(
                            color: store["open_now"] ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  if (store["phone"] != null && store["phone"] != "Not available")
                    Row(
                      children: [
                        Icon(Icons.phone, size: 18, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(store["phone"]),
                      ],
                    ),
                  SizedBox(height: 8),
                  if (store["website"] != null && store["website"] != "Not available")
                    Row(
                      children: [
                        Icon(Icons.language, size: 18, color: Colors.blue),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            store["website"],
                            style: TextStyle(color: Colors.blue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  if (store["opening_hours"] != null && store["opening_hours"].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hours",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        ...store["opening_hours"].map<Widget>((hours) => Text(hours)).toList(),
                      ],
                    ),
                  SizedBox(height: 16),
                  if (store["rating"] != null && store["rating"] > 0)
                    Row(
                      children: [
                        Icon(Icons.star, size: 18, color: Colors.amber),
                        SizedBox(width: 4),
                        Text("${store["rating"]}"),
                      ],
                    ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(store["lat"], store["lng"]),
                          16,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 45),
                    ),
                    child: Text("Navigate to Store"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nearby Stores")),
      body: Stack(
        children: [
          _isLoading || _currentPosition == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 14,
            ),
            onMapCreated: (controller) => mapController = controller,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapToolbarEnabled: true,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 150,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _storesList.length,
                itemBuilder: (context, index) {
                  final store = _storesList[index];
                  return Container(
                    width: 200,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(store["lat"], store["lng"]),
                              16,
                            ),
                          );
                          _showStoreDetails(store);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                store["name"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 12, color: Colors.grey),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      store["address"],
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              if (store["open_now"] != null)
                                Text(
                                  store["open_now"] ? "Open Now" : "Closed",
                                  style: TextStyle(
                                    color: store["open_now"] ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "View Details",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Stores',
      ),
    );
  }
}
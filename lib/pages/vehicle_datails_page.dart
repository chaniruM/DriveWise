import 'package:drivewise/services/vehicle_service.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
// import 'package:drivewise/pages/maintenance_overview.dart';
import 'package:drivewise/pages/MaintenanceOverview.dart';
import 'package:drivewise/pages/product_reco.dart';


class VehicleDetailsPage extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsPage({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.nickname),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                vehicle.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  Text(
                    // '${vehicle.make} ${vehicle.model} (${vehicle.year})',
                    vehicle.nickname,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _buildInfoCard('Vehicle Information', [
                    _buildInfoRow('Make', vehicle.make),
                    _buildInfoRow('Model', vehicle.model),
                    _buildInfoRow('Engine', vehicle.engine),
                    _buildInfoRow('Year of Manufacture', '${vehicle.year}'),
                    _buildInfoRow('Registration Number', vehicle.registrationNumber),
                    _buildInfoRow('Current Mileage', '${vehicle.currentMileage} km'),
                    _buildInfoRow('Next Service Mileage', '${vehicle.nextServiceMileage} km'),
                  ]),
                  SizedBox(height: 16),

                  // License and Insurance Information
                  _buildInfoCard('Expiry Information', [
                    _buildExpiryRow(
                      'Revenue License',
                      vehicle.licenseDateExpiry,
                      context,
                    ),
                    _buildExpiryRow(
                      'Emissions Test',
                      vehicle.emmissionsExpiry,
                      context,
                    ),
                    _buildExpiryRow(
                      'Insurance',
                      vehicle.insuranceDateExpiry,
                      context,
                    ),
                  ]),
                  SizedBox(height: 16),

                  // Specifications
                  _buildSpecificationsCard(),
                  SizedBox(height: 24),


                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductRec(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Add Service Details', style: TextStyle(color: Colors.white)),
                  ),


                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductRec(), // No parameters needed
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('View Products', style: TextStyle(color: Colors.white)),
                  ),

                  SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Remove Vehicle'),
                          content: Text('Are you sure you want to remove ${vehicle.nickname}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          // final vehicleService = VehicleService();
                          await VehicleService().removeVehicle(vehicleId: vehicle.id);

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vehicle removed successfully')),
                          );

                          // Navigate back to the vehicle list screen
                          Navigator.pop(context);
                        } catch (e) {
                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to remove vehicle: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Remove Vehicle', style: TextStyle(color: Colors.white)),
                  ),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(
                  //     //     builder: (context) => const ProductRec(), // No parameters needed
                  //     //   ),
                  //     // );
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.red,
                  //     minimumSize: const Size(double.infinity, 50),
                  //   ),
                  //   child: const Text('Remove Vehicle', style: TextStyle(color: Colors.white)),
                  // ),


                  SizedBox(height: 24),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildExpiryRow(String label, DateTime expiryDate, BuildContext context) {
    final bool isValid = expiryDate.isAfter(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}',
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isValid ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isValid ? 'Valid' : 'Expired',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...vehicle.specifications.entries.map((entry) {
              return _buildInfoRow(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }
}
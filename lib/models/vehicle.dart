//vehicle.dart

class Vehicle {
  final String id;
  final String nickname;
  final String imageUrl;
  final String registrationNumber;
  final String make;
  final String model;
  final String engine;
  final int year;
  final num currentMileage;
  final num nextServiceMileage;
  final DateTime licenseDateExpiry;
  final DateTime insuranceDateExpiry;
  final DateTime emmissionsExpiry;
  final Map<String, String> specifications;

  Vehicle({
    required this.id,
    required this.nickname,
    required this.imageUrl,
    required this.registrationNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.currentMileage,
    required this.nextServiceMileage,
    required this.licenseDateExpiry,
    required this.insuranceDateExpiry,
    required this.specifications,
    required this.engine,
    required this.emmissionsExpiry,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      nickname: json['nickname'],
      imageUrl: json['imageUrl'],
      registrationNumber: json['registrationNumber'],
      make: json['make'],
      model: json['model'],
      engine: json['engine'],
      year: json['year'],
      currentMileage: json['currentMileage'],
      nextServiceMileage: json['nextService'],
      licenseDateExpiry: DateTime.parse(json['licenseDateExpiry']),
      insuranceDateExpiry: DateTime.parse(json['insuranceDateExpiry']),
      emmissionsExpiry: DateTime.parse(json['emmissionsDateExpiry']),
      specifications: Map<String, String>.from(json['specifications']),
    );
  }
}
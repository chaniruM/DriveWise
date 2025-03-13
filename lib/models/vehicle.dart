class Vehicle {
  final String id;
  final String nickname;
  final String imageUrl;
  final String registrationNumber;
  final String make;
  final String model;
  final int year;
  final int currentMileage;
  final DateTime licenseDateExpiry;
  final DateTime insuranceDateExpiry;
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
    required this.licenseDateExpiry,
    required this.insuranceDateExpiry,
    required this.specifications,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      nickname: json['nickname'],
      imageUrl: json['imageUrl'],
      registrationNumber: json['registrationNumber'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      currentMileage: json['currentMileage'],
      licenseDateExpiry: DateTime.parse(json['licenseDateExpiry']),
      insuranceDateExpiry: DateTime.parse(json['insuranceDateExpiry']),
      specifications: Map<String, String>.from(json['specifications']),
    );
  }
}
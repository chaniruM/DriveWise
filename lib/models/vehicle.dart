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
}
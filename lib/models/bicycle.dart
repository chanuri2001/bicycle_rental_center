import 'dart:io';
import 'bike_type.dart';

class Bicycle {
  final String id;
  final String name;
  final String brand;
  final BikeType type;
  final String location;
  final double pricePerHour;
  final String description;
  final String? imageUrl;
  final File? imageFile;
  final int count;
  final String condition;
  final int totalCount;
  final int availableCount;
  final int rentedCount;
  final bool isAvailable;

  Bicycle({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.location,
    required this.pricePerHour,
    this.description = '',
    this.imageUrl,
    this.imageFile,
    this.count = 1,
    this.condition = 'Good',
    required this.totalCount,
    required this.availableCount,
    required this.rentedCount,
  }) : isAvailable = availableCount > 0;

  String get fullName => '$brand $name';

  factory Bicycle.fromJson(Map<String, dynamic> json) {
    return Bicycle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      type: BikeType.values.firstWhere(
        (e) => e.name == (json['type'] is String ? json['type'].toLowerCase() : ''),
        orElse: () => BikeType.mountain,
      ),
      location: json['location'] ?? '',
      pricePerHour: (json['price_per_hour'] ?? json['pricePerHour'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      count: json['count'] ?? 1,
      condition: json['condition'] ?? 'Good',
      totalCount: json['totalCount'] ?? (json['count'] ?? 1),
      availableCount: json['availableCount'] ?? (json['is_available'] == true ? 1 : 0),
      rentedCount: json['rentedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'type': type.name,
      'location': location,
      'price_per_hour': pricePerHour,
      'description': description,
      'image_url': imageUrl,
      'count': count,
      'condition': condition,
      'totalCount': totalCount,
      'availableCount': availableCount,
      'rentedCount': rentedCount,
      'is_available': isAvailable,
    };
  }
}
import 'dart:io';

class Bicycle {
  final String id;
  final String name;
  final String type;
  final bool isAvailable;
  final double pricePerHour;
  final String description;
  final String? imageUrl;
  final File? imageFile; // New field for local images
  final int count;
  final String condition;

  Bicycle({
    required this.id,
    required this.name,
    required this.type,
    required this.isAvailable,
    required this.pricePerHour,
    required this.description,
    this.imageUrl,
    this.imageFile, // Added this parameter
    this.count = 1,
    this.condition = 'Good',
  });

  factory Bicycle.fromJson(Map<String, dynamic> json) {
    return Bicycle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      isAvailable: json['is_available'] ?? false,
      pricePerHour: (json['price_per_hour'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      count: json['count'] ?? 1,
      condition: json['condition'] ?? 'Good',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'is_available': isAvailable,
      'price_per_hour': pricePerHour,
      'description': description,
      'image_url': imageUrl,
      'count': count,
      'condition': condition,
    };
  }
}

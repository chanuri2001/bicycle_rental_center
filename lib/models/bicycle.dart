import 'dart:core';
import 'dart:io';
import 'package:bicycle_rental_center/models/center_bicycle_response.dart';


class Bicycle {
  final String id;
  final String qrCode;
  final String makeName;
  final String modelName;
  final String types;
  final String name;
  final String brand;

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
  final String centerName;
  final String centerUuid;
  final int makeYear;

  Bicycle({
    required this.id,
    required this.qrCode,
    required this.makeName,
    required this.modelName,
    required this.types,
    required this.name,
    required this.brand,

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
    required this.centerName,
    required this.centerUuid,
    required this.makeYear,
  }) : isAvailable = availableCount > 0;

  String get fullName => '$brand $name';

  // Factory method to create from CenterBicycle
  factory Bicycle.fromCenterBicycle(CenterBicycle cb) {
    return Bicycle(
      id: cb.centerBicycleId.toString(),
      qrCode: cb.qrCode,
      makeName: cb.bicycleMake,
      modelName: cb.bicycleModel,
      name: cb.bicycleName,
      brand: cb.bicycleMake,
      types: cb.bicycleType, // Changed from types to bicycleType
      location: cb.centerName,
      pricePerHour: 0.0, // Adjust based on your business logic
      description:
          '${cb.bicycleMake} ${cb.bicycleModel} (${cb.bicycleMakeYear})',
      condition: cb.bicycleCondition,
      totalCount: 1,
      availableCount: 1, // Assuming all are available unless specified
      rentedCount: 0,
      centerName: cb.centerName,
      centerUuid: cb.centerUuid,
      makeYear: cb.bicycleMakeYear,
    );
  }
  // Existing fromJson method
  factory Bicycle.fromJson(Map<String, dynamic> json) {
    return Bicycle(
      id: json['id']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
      makeName: json['make']?['name']?.toString() ?? '',
      modelName: json['model']?['name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      types: json['types']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',

      location: json['location']?.toString() ?? '',
      pricePerHour:
          (json['price_per_hour'] ?? json['pricePerHour'] ?? 0).toDouble(),
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      count: json['count'] ?? 1,
      condition: json['condition']?.toString() ?? 'Good',
      totalCount: json['totalCount'] ?? (json['count'] ?? 1),
      availableCount:
          json['availableCount'] ?? (json['is_available'] == true ? 1 : 0),
      rentedCount: json['rentedCount'] ?? 0,
      centerName: json['centerName']?.toString() ?? '',
      centerUuid: json['centerUuid']?.toString() ?? '',
      makeYear:
          json['makeYear'] ?? json['bicycleMakeYear'] ?? DateTime.now().year,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrCode': qrCode,
      'makeName': makeName,
      'modelName': modelName,
      'name': name,
      'brand': brand,

      'location': location,
      'pricePerHour': pricePerHour,
      'description': description,
      'imageUrl': imageUrl,
      'imageFile': imageFile?.path,
      'count': count,
      'condition': condition,
      'totalCount': totalCount,
      'availableCount': availableCount,
      'rentedCount': rentedCount,
      'isAvailable': isAvailable,
      'centerName': centerName,
      'centerUuid': centerUuid,
      'makeYear': makeYear,
    };
  }

  // Helper method to create a copy with updated values
  Bicycle copyWith({
    String? id,
    String? qrCode,
    String? makeName,
    String? modelName,
    String? Type,
    String? name,
    String? brand,
    String? types,
    String? location,
    double? pricePerHour,
    String? description,
    String? imageUrl,
    File? imageFile,
    int? count,
    String? condition,
    int? totalCount,
    int? availableCount,
    int? rentedCount,
    String? centerName,
    String? centerUuid,
    int? makeYear,
  }) {
    return Bicycle(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      makeName: makeName ?? this.makeName,
      modelName: modelName ?? this.modelName,
      types: Type ?? this.types,
      name: name ?? this.name,
      brand: brand ?? this.brand,

      location: location ?? this.location,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      count: count ?? this.count,
      condition: condition ?? this.condition,
      totalCount: totalCount ?? this.totalCount,
      availableCount: availableCount ?? this.availableCount,
      rentedCount: rentedCount ?? this.rentedCount,
      centerName: centerName ?? this.centerName,
      centerUuid: centerUuid ?? this.centerUuid,
      makeYear: makeYear ?? this.makeYear,
    );
  }

  @override
  String toString() {
    return 'Bicycle{id: $id, name: $name, brand: $brand, location: $location, '
        'pricePerHour: $pricePerHour, available: $isAvailable, center: $centerName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bicycle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          qrCode == other.qrCode &&
          centerUuid == other.centerUuid;

  @override
  int get hashCode => id.hashCode ^ qrCode.hashCode ^ centerUuid.hashCode;
}

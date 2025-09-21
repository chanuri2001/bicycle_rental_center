// models/bike_group.dart

import 'bicycle.dart';

class BikeGroup {
  final String typeName;
  final String typeCode;
  final List<Bicycle> availableBikes;
  final List<Bicycle> rentedBikes;

  BikeGroup({
    required this.typeName,
    required this.typeCode,
    required this.availableBikes,
    required this.rentedBikes,
  });
  List<Bicycle> get totalBikes => [...availableBikes, ...rentedBikes];

  factory BikeGroup.fromJson(Map<String, dynamic> json) {
    return BikeGroup(
      typeName: json['type']['name'],
      typeCode: json['type']['code'],
      availableBikes:
          (json['availableBikes'] as List)
              .map((bike) => Bicycle.fromJson(bike))
              .toList(),
      rentedBikes:
          (json['rentedBikes'] as List)
              .map((bike) => Bicycle.fromJson(bike))
              .toList(),
    );
  }
}

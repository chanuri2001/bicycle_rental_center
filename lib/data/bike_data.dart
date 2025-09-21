import 'dart:io';

import '../../models/bicycle.dart';


class BikeData {
  static List<Bicycle> getAllBikes() {
    return [
      Bicycle(
        id: '1',
        qrCode: 'QR001',
        makeName: 'Trek Inc.',
        modelName: '520 Model',
        name: 'Trek 520',
        brand: 'Trek',
        types: 'hybrid',
        location: 'Downtown Center',
        pricePerHour: 15.99,
        description: 'Durable mountain bike for all terrains',
        imageUrl: 'assets/images/mountain_bike.png',
        imageFile: null,
        count: 1,
        condition: 'Excellent',
        totalCount: 5,
        availableCount: 3,
        rentedCount: 2,
        centerName: 'Downtown Hub',
        centerUuid: 'CEN_DTHUB001',
        makeYear: 2023,
      ),
      Bicycle(
        id: '2',
        qrCode: 'QR002',
        makeName: 'Specialized Inc.',
        modelName: 'Allez Model',
        name: 'Allez',
        brand: 'Specialized',
        types: 'hybrid',
        location: 'Park Center',
        pricePerHour: 18.99,
        description: 'Lightweight road bike for speed',
        imageUrl: 'assets/images/road_bike.png',
        imageFile: null,
        count: 1,
        condition: 'Good',
        totalCount: 4,
        availableCount: 2,
        rentedCount: 2,
        centerName: 'Park Station',
        centerUuid: 'CEN_PARK001',
        makeYear: 2022,
      ),
      Bicycle(
        id: '3',
        qrCode: 'QR003',
        makeName: 'Specialized Inc.',
        modelName: 'Allez Pro',
        name: 'Allez',
        brand: 'Specialized',
        types: 'hybrid',
        location: 'Park Center',
        pricePerHour: 18.99,
        description: 'High-performance road bike',
        imageUrl: 'assets/images/road_bike.png',
        imageFile: null,
        count: 1,
        condition: 'Fair',
        totalCount: 3,
        availableCount: 0,
        rentedCount: 3,
        centerName: 'Park Station',
        centerUuid: 'CEN_PARK001',
        makeYear: 2021,
      ),
      Bicycle(
        id: '4',
        qrCode: 'QR004',
        makeName: 'Kiross Ltd.',
        modelName: 'Roadster',
        name: 'Kiross',
        brand: 'Kiross',
        types: 'hybrid',
        location: 'City Center',
        pricePerHour: 25.99,
        description: 'City performance bike',
        imageUrl: 'assets/images/road_bike_kiross.png',
        imageFile: null,
        count: 1,
        condition: 'Very Good',
        totalCount: 6,
        availableCount: 4,
        rentedCount: 2,
        centerName: 'City Main',
        centerUuid: 'CEN_CITY001',
        makeYear: 2023,
      ),
      Bicycle(
        id: '5',
        qrCode: 'QR005',
        makeName: 'GT Bicycles',
        modelName: 'GTX',
        name: 'GT Bike',
        brand: 'GT',
        types: 'hybrid',
        location: 'Sports Complex',
        pricePerHour: 35.99,
        description: 'High-end road bike for athletes',
        imageUrl: 'assets/images/gt_bike.png',
        imageFile: null,
        count: 1,
        condition: 'Excellent',
        totalCount: 4,
        availableCount: 2,
        rentedCount: 2,
        centerName: 'Sports Hub',
        centerUuid: 'CEN_SPORT001',
        makeYear: 2024,
      ),
      Bicycle(
        id: '6',
        qrCode: 'QR006',
        makeName: 'Thunder Corp',
        modelName: 'X1',
        name: 'Thunder X1',
        brand: 'Thunder',
        types: 'hybrid',
        location: 'Tech Hub',
        pricePerHour: 45.99,
        description: 'Electric bike with long battery life',
        imageUrl: 'assets/images/electric_bike.png',
        imageFile: null,
        count: 1,
        condition: 'Good',
        totalCount: 3,
        availableCount: 1,
        rentedCount: 2,
        centerName: 'Tech Center',
        centerUuid: 'CEN_TECH001',
        makeYear: 2023,
      ),
      Bicycle(
        id: '7',
        qrCode: 'QR007',
        makeName: 'Urban Bikes',
        modelName: 'Cruiser 2024',
        name: 'Urban Cruiser',
        brand: 'Urban',
        types: 'hybrid',
        location: 'Downtown Center',
        pricePerHour: 20.99,
        description: 'Comfortable hybrid for city riding',
        imageUrl: 'assets/images/hybrid_bike.png',
        imageFile: null,
        count: 1,
        condition: 'Good',
        totalCount: 5,
        availableCount: 3,
        rentedCount: 2,
        centerName: 'Downtown Hub',
        centerUuid: 'CEN_DTHUB001',
        makeYear: 2024,
      ),
    ];
  }

  static List<Bicycle> getAvailableBikes() {
    return getAllBikes().where((bike) => bike.isAvailable).toList();
  }

  static List<Bicycle> getBikesByLocation(String location) {
    return getAllBikes().where((bike) => bike.location == location).toList();
  }

  static List<Bicycle> getBikesByCenter(String centerUuid) {
    return getAllBikes()
        .where((bike) => bike.centerUuid == centerUuid)
        .toList();
  }

  static List<String> getAllLocations() {
    return getAllBikes().map((bike) => bike.location).toSet().toList();
  }

  static List<String> getAllCenters() {
    return getAllBikes().map((bike) => bike.centerName).toSet().toList();
  }

  static List<String> getAllCenterUuids() {
    return getAllBikes().map((bike) => bike.centerUuid).toSet().toList();
  }

  
}

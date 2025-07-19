import '../../models/bicycle.dart';
import '../../models/bike_type.dart';

class BikeData {
  static List<Bicycle> getAllBikes() {
    return [
      Bicycle(
        id: '1',
        name: 'Trek 520',
        brand: 'Trek',
        type: BikeType.mountain,
        location: 'Downtown Center',
        pricePerHour: 15.99,
        totalCount: 5,
        availableCount: 3,
        rentedCount: 2,
        imageUrl: 'assets/images/mountain_bike.png',
      ),
      Bicycle(
        id: '2',
        name: 'Allez',
        brand: 'Specialized',
        type: BikeType.road,
        location: 'Park Center',
        pricePerHour: 18.99,
        totalCount: 4,
        availableCount: 2,
        rentedCount: 2,
        imageUrl: 'assets/images/road_bike.png',
      ),
      Bicycle(
        id: '3',
        name: 'Allez',
        brand: 'Specialized',
        type: BikeType.road,
        location: 'Park Center',
        pricePerHour: 18.99,
        totalCount: 3,
        availableCount: 0,
        rentedCount: 3,
        imageUrl: 'assets/images/road_bike.png',
      ),
      Bicycle(
        id: '4',
        name: 'Kiross',
        brand: 'Kiross',
        type: BikeType.road,
        location: 'City Center',
        pricePerHour: 25.99,
        totalCount: 6,
        availableCount: 4,
        rentedCount: 2,
        imageUrl: 'assets/images/road_bike_kiross.png',
      ),
      Bicycle(
        id: '5',
        name: 'GT Bike',
        brand: 'GT',
        type: BikeType.road,
        location: 'Sports Complex',
        pricePerHour: 35.99,
        totalCount: 4,
        availableCount: 2,
        rentedCount: 2,
        imageUrl: 'assets/images/gt_bike.png',
      ),
      Bicycle(
        id: '6',
        name: 'Thunder X1',
        brand: 'Thunder',
        type: BikeType.electric,
        location: 'Tech Hub',
        pricePerHour: 45.99,
        totalCount: 3,
        availableCount: 1,
        rentedCount: 2,
        imageUrl: 'assets/images/electric_bike.png',
      ),
      Bicycle(
        id: '7',
        name: 'Urban Cruiser',
        brand: 'Urban',
        type: BikeType.hybrid,
        location: 'Downtown Center',
        pricePerHour: 20.99,
        totalCount: 5,
        availableCount: 3,
        rentedCount: 2,
        imageUrl: 'assets/images/hybrid_bike.png',
      ),
    ];
  }

  static List<Bicycle> getAvailableBikes() {
    return getAllBikes().where((bike) => bike.isAvailable).toList();
  }

  static List<Bicycle> getBikesByLocation(String location) {
    return getAllBikes().where((bike) => bike.location == location).toList();
  }

  static List<String> getAllLocations() {
    return getAllBikes().map((bike) => bike.location).toSet().toList();
  }
}

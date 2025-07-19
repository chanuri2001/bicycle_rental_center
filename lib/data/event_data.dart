import '../models/event.dart';

class CyclingActivitiesData {
  static List<Event> getAllActivities() {
    return [
      Event(
        id: '1',
        name: 'Morning City Tour',
        title: 'Morning City Tour',
        description: '2-hour guided tour through downtown',
        date: DateTime.now().add(Duration(days: 1)),
        eventTime: DateTime.now().add(Duration(days: 1)),
        
        difficulty: 'Easy',
        price: 25.99,
        imageUrl:
            'https://images.unsplash.com/photo-1519501025264-65ba15a82390',
        availableDates: ['daily'],
        location: 'Downtown Center',
        maxParticipants: 15,
        maxHeadCount: 15,
        eligibilityCriteria: 'Ages 12+, helmet required',
        durationHours: 2,
        features: [
          'Historic landmarks',
          'Local cafes',
          'City parks',
          'Photo stops',
        ],
      ),
      Event(
        id: '2',
        name: 'Park Trail Ride',
        title: 'Park Trail Ride',
        description: 'Scenic 1-hour ride through Central Park',
        date: DateTime.now().add(Duration(days: 2)),
        eventTime: DateTime.now().add(Duration(days: 2)),
       
        difficulty: 'Easy',
        price: 18.99,
        imageUrl:
            'https://images.unsplash.com/photo-1483721310020-03333e577078',
        availableDates: ['daily'],
        location: 'Central Park',
        maxParticipants: 12,
        maxHeadCount: 12,
        eligibilityCriteria: 'Ages 10+, comfortable with basic cycling',
        durationHours: 1,
        features: [
          'Nature trails',
          'Wildlife spotting',
          'Peaceful scenery',
          'Fresh air',
        ],
      ),
      Event(
        id: '3',
        name: 'Beach Coastal Ride',
        title: 'Beach Coastal Ride',
        description: '3-hour coastal adventure',
        date: DateTime.now().add(Duration(days: 3)),
        eventTime: DateTime.now().add(Duration(days: 3)),
        
        difficulty: 'Moderate',
        price: 35.99,
        imageUrl:
            'https://images.unsplash.com/photo-1505228395891-9a51e7e86bf6',
        availableDates: ['daily'],
        location: 'Coastal Highway',
        maxParticipants: 10,
        maxHeadCount: 10,
        eligibilityCriteria: 'Ages 16+, some cycling experience recommended',
        durationHours: 3,
        features: [
          'Ocean views',
          'Beach stops',
          'Lighthouse visit',
          'Seafood lunch',
        ],
      ),
      Event(
        id: '4',
        name: 'Mountain Adventure',
        title: 'Mountain Adventure',
        description: '4-hour challenging mountain trail',
        date: DateTime.now().add(Duration(days: 4)),
        eventTime: DateTime.now().add(Duration(days: 4)),
        
        difficulty: 'Hard',
        price: 45.99,
        imageUrl:
            'https://images.unsplash.com/photo-1511994298241-608e28f14fde',
        availableDates: [
          DateTime.now().add(Duration(days: 4)).toString().split(' ')[0],
          DateTime.now().add(Duration(days: 5)).toString().split(' ')[0],
          DateTime.now().add(Duration(days: 6)).toString().split(' ')[0],
        ],
        location: 'Mountain Ridge',
        maxParticipants: 8,
        maxHeadCount: 8,
        eligibilityCriteria: 'Ages 18+, advanced cycling skills required',
        durationHours: 4,
        features: [
          'Mountain peaks',
          'Challenging terrain',
          'Panoramic views',
          'Adventure',
        ],
      ),
      Event(
        id: '5',
        name: 'Sunset Evening Ride',
        title: 'Sunset Evening Ride',
        description: '2-hour romantic evening cycling',
        date: DateTime.now().add(Duration(days: 5)),
        eventTime: DateTime.now().add(Duration(days: 5)),
        
        difficulty: 'Easy',
        price: 28.99,
        imageUrl:
            'https://images.unsplash.com/photo-1509316785289-025f5b846b35',
        availableDates: ['daily'],
        location: 'Riverside Path',
        maxParticipants: 20,
        maxHeadCount: 20,
        eligibilityCriteria: 'All ages welcome, night lights provided',
        durationHours: 2,
        features: [
          'Golden hour',
          'Romantic atmosphere',
          'River views',
          'Photography',
        ],
      ),
      Event(
        id: '6',
        name: 'Historic Heritage Tour',
        title: 'Historic Heritage Tour',
        description: '3-hour cultural and historic exploration',
        date: DateTime.now().add(Duration(days: 6)),
        eventTime: DateTime.now().add(Duration(days: 6)),
        
        difficulty: 'Easy',
        price: 32.99,
        imageUrl:
            'https://images.unsplash.com/photo-1470004914212-05527e49370b',
        availableDates: [
          DateTime.now().add(Duration(days: 6)).toString().split(' ')[0],
          DateTime.now().add(Duration(days: 7)).toString().split(' ')[0],
          DateTime.now().add(Duration(days: 8)).toString().split(' ')[0],
        ],
        location: 'Old Town',
        maxParticipants: 15,
        maxHeadCount: 15,
        eligibilityCriteria: 'Ages 10+, interest in history recommended',
        durationHours: 3,
        features: [
          'Historic sites',
          'Cultural stories',
          'Architecture',
          'Local guides',
        ],
      ),
    ];
  }

  static List<Event> getActivitiesForDate(DateTime date) {
    return getAllActivities()
        .where((activity) => activity.isAvailableOnDate(date))
        .toList();
  }

  static List<String> getDifficultyLevels() {
    return ['All', 'Easy', 'Moderate', 'Hard'];
  }
}

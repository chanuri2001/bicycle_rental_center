class Event {
  final String id;
  final String name;
  final String title;
  final String description;
  final DateTime date;
  final DateTime eventTime;
  final String location;
  final int maxParticipants;
  final int maxHeadCount;
  final String eligibilityCriteria;
  final int durationHours;
  final List<String> features;

  final String difficulty;
  final double price;
  final String imageUrl;
  final List<String> availableDates;

  // New fields from API integration
  final String activityCode;
  final String activityUuid;
  final String activityTypeName;
  final String activityStatusName;
  final String centerUuid;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime registrationStartAt;
  final DateTime registrationEndAt;
  final bool isActive;

  var activityStatus;

  var activityType;

  Event({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.date,
    required this.eventTime,
    required this.location,
    required this.maxParticipants,
    required this.maxHeadCount,
    required this.eligibilityCriteria,
    required this.durationHours,
    required this.features,

    required this.difficulty,
    required this.price,
    required this.imageUrl,
    required this.availableDates,

    // New fields initialization with defaults
    this.activityCode = '',
    this.activityUuid = '',
    this.activityTypeName = '',
    this.activityStatusName = '',
    this.centerUuid = '',
    DateTime? startTime,
    DateTime? endTime,
    DateTime? registrationStartAt,
    DateTime? registrationEndAt,
    this.isActive = true,
  }) : startTime = startTime ?? eventTime,
       endTime = endTime ?? eventTime.add(Duration(hours: durationHours)),
       registrationStartAt = registrationStartAt ?? eventTime,
       registrationEndAt = registrationEndAt ?? eventTime;

  bool isAvailableOnDate(DateTime date) {
    String dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // Check if it's available on the specific date
    if (availableDates.contains(dateString) ||
        availableDates.contains('daily')) {
      return true;
    }

    // For API activities, check if the activity date matches the selected date
    if (availableDates.isEmpty) {
      // Use startTime for API activities, eventTime for local activities
      DateTime activityDate = startTime;
      return activityDate.year == date.year &&
          activityDate.month == date.month &&
          activityDate.day == date.day;
    }

    return false;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['title'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(
        json['date'] ?? json['event_time'] ?? DateTime.now().toIso8601String(),
      ),
      eventTime: DateTime.parse(
        json['event_time'] ?? json['date'] ?? DateTime.now().toIso8601String(),
      ),
      location: json['location'] ?? '',
      maxParticipants: json['max_participants'] ?? json['max_head_count'] ?? 0,
      maxHeadCount: json['max_head_count'] ?? json['max_participants'] ?? 0,
      eligibilityCriteria: json['eligibility_criteria'] ?? '',
      durationHours: json['duration_hours'] ?? 1,
      features: List<String>.from(json['features'] ?? []),

      difficulty: json['difficulty'] ?? 'Easy',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? '',
      availableDates: List<String>.from(json['availableDates'] ?? []),

      // New fields from API
      activityCode: json['activityCode'] ?? '',
      activityUuid: json['activityUuid'] ?? '',
      activityTypeName: json['activityTypeName'] ?? '',
      activityStatusName: json['activityStatusName'] ?? '',
      centerUuid: json['centerUuid'] ?? '',
      startTime:
          json['startAt'] != null
              ? DateTime.parse(json['startAt'].replaceAll(' ', 'T'))
              : null,
      endTime:
          json['endAt'] != null
              ? DateTime.parse(json['endAt'].replaceAll(' ', 'T'))
              : null,
      registrationStartAt:
          json['registrationStartAt'] != null
              ? DateTime.parse(json['registrationStartAt'].replaceAll(' ', 'T'))
              : null,
      registrationEndAt:
          json['registrationEndAt'] != null
              ? DateTime.parse(json['registrationEndAt'].replaceAll(' ', 'T'))
              : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'event_time': eventTime.toIso8601String(),
      'location': location,
      'max_participants': maxParticipants,
      'max_head_count': maxHeadCount,
      'eligibility_criteria': eligibilityCriteria,
      'duration_hours': durationHours,
      'features': features,

      'difficulty': difficulty,
      'price': price,
      'imageUrl': imageUrl,
      'availableDates': availableDates,

      // New fields
      'activityCode': activityCode,
      'activityUuid': activityUuid,
      'activityTypeName': activityTypeName,
      'activityStatusName': activityStatusName,
      'centerUuid': centerUuid,
      'startAt': startTime.toIso8601String(),
      'endAt': endTime.toIso8601String(),
      'registrationStartAt': registrationStartAt.toIso8601String(),
      'registrationEndAt': registrationEndAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Event copyWith({
    String? id,
    String? name,
    String? title,
    String? description,
    DateTime? date,
    DateTime? eventTime,
    String? location,
    int? maxParticipants,
    int? maxHeadCount,
    String? eligibilityCriteria,
    int? durationHours,
    List<String>? features,

    String? difficulty,
    double? price,
    String? imageUrl,
    List<String>? availableDates,
    String? activityCode,
    String? activityUuid,
    String? activityTypeName,
    String? activityStatusName,
    String? centerUuid,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? registrationStartAt,
    DateTime? registrationEndAt,
    bool? isActive,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      eventTime: eventTime ?? this.eventTime,
      location: location ?? this.location,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      maxHeadCount: maxHeadCount ?? this.maxHeadCount,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      durationHours: durationHours ?? this.durationHours,
      features: features ?? this.features,

      difficulty: difficulty ?? this.difficulty,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      availableDates: availableDates ?? this.availableDates,
      activityCode: activityCode ?? this.activityCode,
      activityUuid: activityUuid ?? this.activityUuid,
      activityTypeName: activityTypeName ?? this.activityTypeName,
      activityStatusName: activityStatusName ?? this.activityStatusName,
      centerUuid: centerUuid ?? this.centerUuid,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      registrationStartAt: registrationStartAt ?? this.registrationStartAt,
      registrationEndAt: registrationEndAt ?? this.registrationEndAt,
      isActive: isActive ?? this.isActive,
    );
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedTime {
    // Use startTime for API activities, eventTime for local activities
    DateTime timeToFormat = startTime;
    final hour = timeToFormat.hour.toString().padLeft(2, '0');
    final minute = timeToFormat.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Additional getter for formatted time range
  String get formattedTimeRange {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }
}

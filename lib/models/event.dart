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
  
  final String? imageUrl;
  final String eligibilityCriteria;
  final int durationHours;
  final List<String> features;

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
   
    this.imageUrl,
    required this.eligibilityCriteria,
    required this.durationHours,
    required this.features,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
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
      
      imageUrl: json['image_url'],
      eligibilityCriteria: json['eligibility_criteria'] ?? '',
      durationHours: json['duration_hours'] ?? 1,
      features: List<String>.from(json['features'] ?? []),
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
      'image_url': imageUrl,
      'eligibility_criteria': eligibilityCriteria,
      'duration_hours': durationHours,
      'features': features,
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
    String? imageUrl,
    String? eligibilityCriteria,
    int? durationHours,
    List<String>? features,
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
      imageUrl: imageUrl ?? this.imageUrl,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      durationHours: durationHours ?? this.durationHours,
      features: features ?? this.features,
    );
  }

  // Helper method to format date
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedTime {
    final hour = eventTime.hour.toString().padLeft(2, '0');
    final minute = eventTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

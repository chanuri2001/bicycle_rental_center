// event.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Event {
  final String id;
  final String activityName;
  final DateTime date;
  final DateTime eventTime;
  final int? maxParticipants;
  final String eligibilityCriteria;
  final int durationHours;
  final List<String> features;
  final String imageUrl;
  final String activityCode;
  final String activityUuid;
  final String activityTypeName;
  final String activityStatusName;
  final String centerActivityUuid;
  final String centerUuid;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? registrationStartAt;
  final DateTime? registrationEndAt;
  final bool isActive;
  final String centerName;
  final String activityShortDescription;
  final String activityDescription;
  final List<String> tags;
  final String registrationMode;
  final bool isSessionsAvailable;

  Event({
    required this.id,
    required this.activityName,
    required this.date,
    required this.eventTime,
    this.maxParticipants,
    required this.eligibilityCriteria,
    required this.durationHours,
    required this.centerActivityUuid,
    required this.features,
    required this.imageUrl,
    this.activityCode = '',
    this.activityUuid = '',
    this.activityTypeName = '',
    this.activityStatusName = '',
    this.centerUuid = '',
    this.startTime,
    this.endTime,
    this.registrationStartAt,
    this.registrationEndAt,
    this.isActive = true,
    this.centerName = '',
    this.activityShortDescription = '',
    this.activityDescription = '',
    this.tags = const [],
    this.registrationMode = '',
    this.isSessionsAvailable = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Parse images
    String imageUrl = '';
    try {
      dynamic imagesJson = json['images'];
      if (imagesJson is String) {
        imagesJson = jsonDecode(imagesJson);
      }
      if (imagesJson is List && imagesJson.isNotEmpty) {
        imageUrl = imagesJson[0]['path'] ?? '';
      }
    } catch (e) {
      print('Error parsing images: $e');
    }

    // Parse features
    List<String> features = [];
    try {
      dynamic featuresJson = json['features'];
      if (featuresJson is String) {
        featuresJson = jsonDecode(featuresJson.replaceAll(r'\"', '"'));
      }
      if (featuresJson is List) {
        features = featuresJson.map((f) => f.toString()).toList();
      }
    } catch (e) {
      print('Error parsing features: $e');
    }

    // Parse dates
    DateTime? parseDateTime(dynamic dateString) {
      if (dateString == null || dateString == '0000-00-00 00:00:00') {
        return null;
      }
      try {
        return DateTime.parse(dateString.toString().replaceAll(' ', 'T'));
      } catch (e) {
        print('Error parsing date: $e');
        return null;
      }
    }

    final startAt = parseDateTime(json['startAt']);
    final date = startAt ?? DateTime.now();

    return Event(
      id: json['id']?.toString() ?? '',
      activityName: json['activityName'] ?? '',
      date: date,
      eventTime: date,
      maxParticipants: json['maxParticipants'],
      eligibilityCriteria: json['eligibilityCriteria'] ?? '',
      durationHours: 1,
      features: features,
      imageUrl: imageUrl,
      activityCode: json['activityCode'] ?? '',
      activityUuid: json['activityUuid'] ?? '',
      activityTypeName: json['activityTypeName'] ?? 'Event',
      activityStatusName: json['activityStatusName'] ?? '',
      centerUuid: json['centerUuid'] ?? '',
      centerActivityUuid: json['centerActivityUuid'] ?? '',
      startTime: startAt,
      endTime: parseDateTime(json['endAt']),
      registrationStartAt: parseDateTime(json['registrationStartAt']),
      registrationEndAt: parseDateTime(json['registrationEndAt']),
      isActive: json['isActive'] ?? true,
      centerName: json['centerName'] ?? '',
      activityShortDescription: json['activityShortDescription'] ?? '',
      activityDescription: json['activityDescription'] ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      registrationMode: json['registrationMode'] ?? '',
      isSessionsAvailable: json['isSessionsAvailable'] ?? false,
    );
  }

 factory Event.fromDetailJson(Map<String, dynamic> json) {
  final activity = json['activity'];
  final startAt = json['startAt'] != null && json['startAt'] != "-0001-11-30 00:00:00" 
    ? DateTime.parse(json['startAt'].toString().replaceAll(' ', 'T'))
    : null;
  final date = startAt ?? DateTime.now();

  // Handle tags conversion safely
  List<String> tags = [];
  if (activity['tags'] != null) {
    try {
      tags = List<String>.from(activity['tags'].map((tag) => tag.toString()));
    } catch (e) {
      print('Error parsing tags: $e');
      tags = [];
    }
  }

  return Event(
    id: json['id']?.toString() ?? '',
    activityName: activity['name'] ?? '',
    date: date,
    eventTime: date,
    maxParticipants: json['maxAllocations'],
    eligibilityCriteria: activity['eligibilityCriteria'] ?? '',
    durationHours: 1,
    features: tags, // Using tags as features
    imageUrl: activity['images']?.isNotEmpty == true 
        ? activity['images'][0]['cloudPath'] ?? ''
        : '',
    activityCode: activity['code'] ?? '',
    activityUuid: activity['code'] ?? '',
    activityTypeName: activity['activityType']['name'] ?? 'Event',
    activityStatusName: json['activityStatus']['name'] ?? '',
    centerUuid: '',
    centerActivityUuid: json['uuid'] ?? '',
    startTime: startAt,
    endTime: json['endAt'] != null 
        ? DateTime.parse(json['endAt'].toString().replaceAll(' ', 'T'))
        : null,
    registrationStartAt: json['registrationStartAt'] != null 
        ? DateTime.parse(json['registrationStartAt'].toString().replaceAll(' ', 'T'))
        : null,
    registrationEndAt: json['registrationEndAt'] != null 
        ? DateTime.parse(json['registrationEndAt'].toString().replaceAll(' ', 'T'))
        : null,
    isActive: true,
    centerName: '',
    activityShortDescription: activity['shortDescription'] ?? '',
    activityDescription: activity['description'] ?? '',
    tags: tags,
    registrationMode: json['registrationMode'] != null 
        ? json['registrationMode']['name'] ?? ''
        : '',
    isSessionsAvailable: json['isSessionsAvailable'] ?? false,
  );
}
  bool isOnDate(DateTime date) {
    return this.date.year == date.year &&
        this.date.month == date.month &&
        this.date.day == date.day;
  }

  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String get formattedDate => formatDate(date);
  String get formattedTime => formatTime(startTime ?? date);
  String get formattedDateTime => '$formattedDate $formattedTime';

  String get formattedEventPeriod {
    final start = startTime ?? date;
    final end = endTime ?? start.add(Duration(hours: durationHours));
    return '${formatDate(start)} • ${formatTime(start)} - ${formatTime(end)}';
  }

  String get formattedRegistrationPeriod {
    if (registrationStartAt == null || registrationEndAt == null) {
      return 'Not specified';
    }
    return '${formatDate(registrationStartAt!)} - ${formatDate(registrationEndAt!)}';
  }

  bool isToday() {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  bool hasStarted() {
    return DateTime.now().isAfter(startTime ?? date);
  }

  bool hasEnded() {
    return DateTime.now().isAfter(
      endTime ?? (startTime ?? date).add(Duration(hours: durationHours)),
    );
  }

  bool isHappening() {
    final now = DateTime.now();
    final start = startTime ?? date;
    final end = endTime ?? start.add(Duration(hours: durationHours));
    return now.isAfter(start) && now.isBefore(end);
  }

  String get currentStatus {
    if (hasEnded()) return 'Completed';
    if (isHappening()) return 'In Progress';
    if (hasStarted()) return 'Started';
    return 'Upcoming';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityName': activityName,
      'date': date.toIso8601String(),
      'eventTime': eventTime.toIso8601String(),
      'maxParticipants': maxParticipants,
      'eligibilityCriteria': eligibilityCriteria,
      'durationHours': durationHours,
      'features': features,
      'imageUrl': imageUrl,
      'activityCode': activityCode,
      'activityUuid': activityUuid,
      'activityTypeName': activityTypeName,
      'activityStatusName': activityStatusName,
      'centerUuid': centerUuid,
      'startAt': startTime?.toIso8601String(),
      'endAt': endTime?.toIso8601String(),
      'registrationStartAt': registrationStartAt?.toIso8601String(),
      'registrationEndAt': registrationEndAt?.toIso8601String(),
      'isActive': isActive,
      'centerName': centerName,
      'activityShortDescription': activityShortDescription,
      'activityDescription': activityDescription,
      'tags': tags,
      'registrationMode': registrationMode,
      'isSessionsAvailable': isSessionsAvailable,
    };
  }

  Event copyWith({
    String? id,
    String? activityName,
    DateTime? date,
    DateTime? eventTime,
    int? maxParticipants,
    String? eligibilityCriteria,
    int? durationHours,
    List<String>? features,
    String? imageUrl,
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
    String? centerName,
    String? activityShortDescription,
    String? activityDescription,
    List<String>? tags,
    String? registrationMode,
    bool? isSessionsAvailable,
  }) {
    return Event(
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      date: date ?? this.date,
      eventTime: eventTime ?? this.eventTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      durationHours: durationHours ?? this.durationHours,
      features: features ?? this.features,
      imageUrl: imageUrl ?? this.imageUrl,
      centerActivityUuid: centerActivityUuid ?? this.centerActivityUuid,
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
      centerName: centerName ?? this.centerName,
      activityShortDescription: activityShortDescription ?? this.activityShortDescription,
      activityDescription: activityDescription ?? this.activityDescription,
      tags: tags ?? this.tags,
      registrationMode: registrationMode ?? this.registrationMode,
      isSessionsAvailable: isSessionsAvailable ?? this.isSessionsAvailable,
    );
  }
}
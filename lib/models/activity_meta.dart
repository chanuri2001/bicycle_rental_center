// activity_meta.dart
class ActivityMeta {
  final List<ActivityType> activityTypes;
  final List<ActivityStatus> activityStatus;
  final List<ActivityTrackType> activityTrackTypes;
  final List<ActivityDateType> activityDateTypes;

  ActivityMeta({
    required this.activityTypes,
    required this.activityStatus,
    required this.activityTrackTypes,
    required this.activityDateTypes,
  });

  factory ActivityMeta.fromJson(Map<String, dynamic> json) {
    return ActivityMeta(
      activityTypes: (json['activityTypes'] as List)
          .map((e) => ActivityType.fromJson(e))
          .toList(),
      activityStatus: (json['activityStatus'] as List)
          .map((e) => ActivityStatus.fromJson(e))
          .toList(),
      activityTrackTypes: (json['activityTrackTypes'] as List)
          .map((e) => ActivityTrackType.fromJson(e))
          .toList(),
      activityDateTypes: (json['activityDateTypes'] as List)
          .map((e) => ActivityDateType.fromJson(e))
          .toList(),
    );
  }
}

class ActivityType {
  final int id;
  final String name;
  final String code;

  ActivityType({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ActivityType.fromJson(Map<String, dynamic> json) {
    return ActivityType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class ActivityStatus {
  final int id;
  final String name;
  final String code;

  ActivityStatus({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ActivityStatus.fromJson(Map<String, dynamic> json) {
    return ActivityStatus(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class ActivityTrackType {
  final int id;
  final String name;
  final String code;

  ActivityTrackType({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ActivityTrackType.fromJson(Map<String, dynamic> json) {
    return ActivityTrackType(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class ActivityDateType {
  final String name;
  final String code;

  ActivityDateType({
    required this.name,
    required this.code,
  });

  factory ActivityDateType.fromJson(Map<String, dynamic> json) {
    return ActivityDateType(
      name: json['name'],
      code: json['code'],
    );
  }
}
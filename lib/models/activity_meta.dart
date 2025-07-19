// models/activity_meta.dart
class ActivityMeta {
  final bool status;
  final ActivityMetaResult? result;
  final int statusCode;

  ActivityMeta({
    required this.status,
    this.result,
    required this.statusCode,
  });

  factory ActivityMeta.fromJson(Map<String, dynamic> json) {
    return ActivityMeta(
      status: json['status'] ?? false,
      result: json['result'] != null ? ActivityMetaResult.fromJson(json['result']) : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'result': result?.toJson(),
      'statusCode': statusCode,
    };
  }
}

class ActivityMetaResult {
  final List<ActivityType> activityTypes;
  final List<ActivityStatus> activityStatus;
  final List<ActivityTrackType> activityTrackTypes;

  ActivityMetaResult({
    required this.activityTypes,
    required this.activityStatus,
    required this.activityTrackTypes,
  });

  factory ActivityMetaResult.fromJson(Map<String, dynamic> json) {
    return ActivityMetaResult(
      activityTypes: (json['activityTypes'] as List<dynamic>?)
          ?.map((item) => ActivityType.fromJson(item))
          .toList() ?? [],
      activityStatus: (json['activityStatus'] as List<dynamic>?)
          ?.map((item) => ActivityStatus.fromJson(item))
          .toList() ?? [],
      activityTrackTypes: (json['activityTrackTypes'] as List<dynamic>?)
          ?.map((item) => ActivityTrackType.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityTypes': activityTypes.map((item) => item.toJson()).toList(),
      'activityStatus': activityStatus.map((item) => item.toJson()).toList(),
      'activityTrackTypes': activityTrackTypes.map((item) => item.toJson()).toList(),
    };
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}

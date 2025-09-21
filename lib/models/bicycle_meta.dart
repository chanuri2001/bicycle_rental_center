// models/bicycle_meta.dart
class BicycleMeta {
  final List<BicycleMake> makes;
  final List<BicycleType> types;
  final List<BicycleModel> models;
  final List<ConditionStatus> conditionStatus;
  final List<RunningStatus> runningStatus;

  BicycleMeta({
    required this.makes,
    required this.types,
    required this.models,
    required this.conditionStatus,
    required this.runningStatus,
  });

  factory BicycleMeta.fromJson(Map<String, dynamic> json) {
    return BicycleMeta(
      makes:
          (json['makes'] as List).map((e) => BicycleMake.fromJson(e)).toList(),
      types:
          (json['types'] as List).map((e) => BicycleType.fromJson(e)).toList(),
      models:
          (json['models'] as List)
              .map((e) => BicycleModel.fromJson(e))
              .toList(),
      conditionStatus:
          (json['conditionStatus'] as List)
              .map((e) => ConditionStatus.fromJson(e))
              .toList(),
      runningStatus:
          (json['runningStatus'] as List)
              .map((e) => RunningStatus.fromJson(e))
              .toList(),
    );
  }
}

class BicycleMake {
  final int id;
  final String name;
  final String code;

  BicycleMake({required this.id, required this.name, required this.code});

  factory BicycleMake.fromJson(Map<String, dynamic> json) {
    return BicycleMake(id: json['id'], name: json['name'], code: json['code']);
  }
}

class BicycleType {
  final int id;
  final String name;
  final String code;

  BicycleType({required this.id, required this.name, required this.code});

  factory BicycleType.fromJson(Map<String, dynamic> json) {
    return BicycleType(id: json['id'], name: json['name'], code: json['code']);
  }
}

class BicycleModel {
  final int id;
  final String name;
  final String code;
  final String uuid;

  BicycleModel({
    required this.id,
    required this.name,
    required this.code,
    required this.uuid,
  });

  factory BicycleModel.fromJson(Map<String, dynamic> json) {
    return BicycleModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      uuid: json['uuid'],
    );
  }
}

class ConditionStatus {
  final int id;
  final String name;
  final String code;

  ConditionStatus({required this.id, required this.name, required this.code});

  factory ConditionStatus.fromJson(Map<String, dynamic> json) {
    return ConditionStatus(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class RunningStatus {
  final int id;
  final String name;
  final String code;

  RunningStatus({required this.id, required this.name, required this.code});

  factory RunningStatus.fromJson(Map<String, dynamic> json) {
    return RunningStatus(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

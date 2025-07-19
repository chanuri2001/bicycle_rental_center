// models/filter_meta.dart
class FilterMeta {
  final bool status;
  final FilterMetaResult? result;
  final int statusCode;

  FilterMeta({
    required this.status,
    this.result,
    required this.statusCode,
  });

  factory FilterMeta.fromJson(Map<String, dynamic> json) {
    return FilterMeta(
      status: json['status'] ?? false,
      result: json['result'] != null ? FilterMetaResult.fromJson(json['result']) : null,
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

class FilterMetaResult {
  final List<Make> makes;
  final List<BicycleType> types;
  final List<BicycleModel> models;
  final List<ConditionStatus> conditionStatus;
  final List<RunningStatus> runningStatus;

  FilterMetaResult({
    required this.makes,
    required this.types,
    required this.models,
    required this.conditionStatus,
    required this.runningStatus,
  });

  factory FilterMetaResult.fromJson(Map<String, dynamic> json) {
    return FilterMetaResult(
      makes: (json['makes'] as List<dynamic>?)
          ?.map((item) => Make.fromJson(item))
          .toList() ?? [],
      types: (json['types'] as List<dynamic>?)
          ?.map((item) => BicycleType.fromJson(item))
          .toList() ?? [],
      models: (json['models'] as List<dynamic>?)
          ?.map((item) => BicycleModel.fromJson(item))
          .toList() ?? [],
      conditionStatus: (json['conditionStatus'] as List<dynamic>?)
          ?.map((item) => ConditionStatus.fromJson(item))
          .toList() ?? [],
      runningStatus: (json['runningStatus'] as List<dynamic>?)
          ?.map((item) => RunningStatus.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'makes': makes.map((item) => item.toJson()).toList(),
      'types': types.map((item) => item.toJson()).toList(),
      'models': models.map((item) => item.toJson()).toList(),
      'conditionStatus': conditionStatus.map((item) => item.toJson()).toList(),
      'runningStatus': runningStatus.map((item) => item.toJson()).toList(),
    };
  }
}

class Make {
  final int id;
  final String name;
  final String code;

  Make({
    required this.id,
    required this.name,
    required this.code,
  });

  factory Make.fromJson(Map<String, dynamic> json) {
    return Make(
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

class BicycleType {
  final int id;
  final String name;
  final String code;

  BicycleType({
    required this.id,
    required this.name,
    required this.code,
  });

  factory BicycleType.fromJson(Map<String, dynamic> json) {
    return BicycleType(
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
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      uuid: json['uuid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'uuid': uuid,
    };
  }
}

class ConditionStatus {
  final int id;
  final String name;
  final String code;

  ConditionStatus({
    required this.id,
    required this.name,
    required this.code,
  });

  factory ConditionStatus.fromJson(Map<String, dynamic> json) {
    return ConditionStatus(
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

class RunningStatus {
  final int id;
  final String name;
  final String code;

  RunningStatus({
    required this.id,
    required this.name,
    required this.code,
  });

  factory RunningStatus.fromJson(Map<String, dynamic> json) {
    return RunningStatus(
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

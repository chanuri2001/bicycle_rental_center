// models/user_data.dart
class UserData {
  final bool status;
  final UserResult? result;
  final int statusCode;

  UserData({
    required this.status,
    this.result,
    required this.statusCode,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      status: json['status'] ?? false,
      result: json['result'] != null ? UserResult.fromJson(json['result']) : null,
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

class UserResult {
  final int id;
  final String userName;
  final String uuid;
  final String email;
  final List<CenterUserAccess> centerUserAccess;

  UserResult({
    required this.id,
    required this.userName,
    required this.uuid,
    required this.email,
    required this.centerUserAccess,
  });

  factory UserResult.fromJson(Map<String, dynamic> json) {
    return UserResult(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      uuid: json['uuid'] ?? '',
      email: json['email'] ?? '',
      centerUserAccess: (json['centerUserAccess'] as List<dynamic>?)
          ?.map((item) => CenterUserAccess.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'uuid': uuid,
      'email': email,
      'centerUserAccess': centerUserAccess.map((item) => item.toJson()).toList(),
    };
  }
}

class CenterUserAccess {
  final int id;
  final int centerId;
  final String allowedAt;
  final Center center;

  CenterUserAccess({
    required this.id,
    required this.centerId,
    required this.allowedAt,
    required this.center,
  });

  factory CenterUserAccess.fromJson(Map<String, dynamic> json) {
    return CenterUserAccess(
      id: json['id'] ?? 0,
      centerId: json['centerId'] ?? 0,
      allowedAt: json['allowedAt'] ?? '',
      center: Center.fromJson(json['center'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'centerId': centerId,
      'allowedAt': allowedAt,
      'center': center.toJson(),
    };
  }
}

class Center {
  final int id;
  final String name;
  final String uuid;
  final String centerIdentification;

  Center({
    required this.id,
    required this.name,
    required this.uuid,
    required this.centerIdentification,
  });

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      uuid: json['uuid'] ?? '',
      centerIdentification: json['centerIdentification'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'uuid': uuid,
      'centerIdentification': centerIdentification,
    };
  }
}

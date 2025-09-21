class CenterModel {
  final int id;
  final String name;
  final String uuid;
  final String centerIdentification;

  CenterModel({
    required this.id,
    required this.name,
    required this.uuid,
    required this.centerIdentification,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      id: json['id'],
      name: json['name'],
      uuid: json['uuid'],
      centerIdentification: json['centerIdentification'],
    );
  }
}

class CenterUserAccess {
  final int id;
  final int centerId;
  final String allowedAt;
  final CenterModel center;

  CenterUserAccess({
    required this.id,
    required this.centerId,
    required this.allowedAt,
    required this.center,
  });

  factory CenterUserAccess.fromJson(Map<String, dynamic> json) {
    return CenterUserAccess(
      id: json['id'],
      centerId: json['centerId'],
      allowedAt: json['allowedAt'],
      center: CenterModel.fromJson(json['center']),
    );
  }
}

class User {
  final int id;
  final String userName;
  final String uuid;
  final String email;
  final List<CenterUserAccess> centerUserAccess;

  User({
    required this.id,
    required this.userName,
    required this.uuid,
    required this.email,
    required this.centerUserAccess,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var accessList =
        (json['centerUserAccess'] as List)
            .map((e) => CenterUserAccess.fromJson(e))
            .toList();

    return User(
      id: json['id'],
      userName: json['userName'],
      uuid: json['uuid'],
      email: json['email'],
      centerUserAccess: accessList,
    );
  }
}

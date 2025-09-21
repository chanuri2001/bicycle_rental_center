// models/api_bike.dart

class ApiBike {
  final String uuid;
  final String qrCode;
  final String makeName;
  final String modelName;

  ApiBike({
    required this.uuid,
    required this.qrCode,
    required this.makeName,
    required this.modelName,
  });

  factory ApiBike.fromJson(Map<String, dynamic> json) {
    return ApiBike(
      uuid: json['uuid'],
      qrCode: json['qrCode'],
      makeName: json['make']['name'],
      modelName: json['model']['name'],
    );
  }
}

class CenterBicycleResponse {
  final bool status;
  final int statusCode;
  final CenterBicycleResult result;

  CenterBicycleResponse({
    required this.status,
    required this.statusCode,
    required this.result,
  });

  factory CenterBicycleResponse.fromJson(Map<String, dynamic> json) {
    return CenterBicycleResponse(
      status: json['status'],
      statusCode: json['statusCode'],
      result: CenterBicycleResult.fromJson(json['result']),
    );
  }
}

class CenterBicycleResult {
  final List<CenterBicycle> centerBicycles;

  CenterBicycleResult({
    required this.centerBicycles,
  });

  factory CenterBicycleResult.fromJson(Map<String, dynamic> json) {
    final bicycles = (json['centerBicycles'] as List)
        .map((e) => CenterBicycle.fromJson(e))
        .toList();

    return CenterBicycleResult(
      centerBicycles: bicycles,
    );
  }

 
}

class CenterBicycle {
  final int centerBicycleId;
  final String qrCode;
  final String centerBicycleUuid;
  final String centerCommissionedAt;
  final String centerName;
  final String centerUuid;
  final String centerIdentification;
  final String bicycleUuid;
  final String bicycleName;
  final String bicycleType;
  final int bicycleMakeYear;
  final String bicycleTypeCode;
  final String bicycleModel;
  final String bicycleModelCode;
  final String bicycleMake;
  final String bicycleMakeCode;
  final String bicycleCondition;
  final String bicycleConditionCode;

  CenterBicycle({
    required this.centerBicycleId,
    required this.qrCode,
    required this.centerBicycleUuid,
    required this.centerCommissionedAt,
    required this.centerName,
    required this.centerUuid,
    required this.centerIdentification,
    required this.bicycleUuid,
    required this.bicycleName,
    required this.bicycleType,
    required this.bicycleMakeYear,
    required this.bicycleTypeCode,
    required this.bicycleModel,
    required this.bicycleModelCode,
    required this.bicycleMake,
    required this.bicycleMakeCode,
    required this.bicycleCondition,
    required this.bicycleConditionCode,
  });

  factory CenterBicycle.fromJson(Map<String, dynamic> json) {
    return CenterBicycle(
      centerBicycleId: json['centerBicycleId'],
      qrCode: json['qrCode'],
      centerBicycleUuid: json['centerBicycleUuid'],
      centerCommissionedAt: json['centerCommissionedAt'],
      centerName: json['centerName'],
      centerUuid: json['centerUuid'],
      centerIdentification: json['centerIdentification'],
      bicycleUuid: json['bicycleUuid'],
      bicycleName: json['bicycleName'],
      bicycleType: json['bicycleType'],
      bicycleMakeYear: json['bicycleMakeYear'],
      bicycleTypeCode: json['bicycleTypeCode'],
      bicycleModel: json['bicycleModel'],
      bicycleModelCode: json['bicycleModelCode'],
      bicycleMake: json['bicycleMake'],
      bicycleMakeCode: json['bicycleMakeCode'],
      bicycleCondition: json['bicycleCondition'],
      bicycleConditionCode: json['bicycleConditionCode'],
    );
  }
}
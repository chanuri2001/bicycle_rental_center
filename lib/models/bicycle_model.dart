class Bicycle {
  final int id;
  final String qrCode;
  final String uuid;
  final String make;
  final String model;

  Bicycle({
    required this.id,
    required this.qrCode,
    required this.uuid,
    required this.make,
    required this.model,
  });

  factory Bicycle.fromJson(Map<String, dynamic> json) {
    // If this is a wrapper with "bicycle" key
    final data = json['bicycle'] ?? json;
    return Bicycle(
      id: data['id'],
      qrCode: data['qrCode'] ?? 'N/A',
      uuid: data['uuid'] ?? 'N/A',
      make: data['make'] ?? 'Unknown',
      model: data['model'] ?? 'Unknown',
    );
  }
}

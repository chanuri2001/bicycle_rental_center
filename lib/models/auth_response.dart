// models/auth_response.dart
class AuthResponse {
  final bool status;
  final Map<String, dynamic> result;
  final int statusCode;

  AuthResponse({
    required this.status,
    required this.result,
    required this.statusCode,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'],
      result: json['result'],
      statusCode: json['statusCode'],
    );
  }
}

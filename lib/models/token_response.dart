// models/token_response.dart
class TokenResponse {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final String? error;
  final String? errorDescription;

  TokenResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.error,
    this.errorDescription,
  });

  /// Create a successful token response
  factory TokenResponse.success({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
  }) {
    return TokenResponse(
      success: true,
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
  }

  /// Create an error token response
  factory TokenResponse.error({
    required String error,
    String? errorDescription,
  }) {
    return TokenResponse(
      success: false,
      error: error,
      errorDescription: errorDescription,
    );
  }

  /// Create from OAuth2 API JSON response
  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    // Check if this is an error response
    if (json.containsKey('error')) {
      return TokenResponse.error(
        error: json['error'],
        errorDescription: json['error_description'],
      );
    }

    // Success response
    return TokenResponse.success(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'error': error,
      'error_description': errorDescription,
    };
  }

  /// Check if the token is valid (not null and success is true)
  bool get isValid => success && accessToken != null && accessToken!.isNotEmpty;

  /// Get the authorization header value
  String get authorizationHeader => '$tokenType $accessToken';

  @override
  String toString() {
    if (success) {
      return 'TokenResponse(success: $success, tokenType: $tokenType, expiresIn: $expiresIn)';
    } else {
      return 'TokenResponse(success: $success, error: $error, errorDescription: $errorDescription)';
    }
  }
}

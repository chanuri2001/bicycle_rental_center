// services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token_response.dart';

class AuthService {
  static const String _baseUrl =
      'http://spinisland.devtester.xyz';
  static const String _clientId = 'give your client id';
  static const String _clientSecret =
      'give your client secret';

  /// Login using OAuth2 password grant
  Future<TokenResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      // OAuth2 token endpoint for password grant
      final response = await http.post(
        Uri.parse('$_baseUrl/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'password',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'scope': 'centermobileadmin',
          'username': username,
          'password': password,
        },
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(responseData);
        
        // Store tokens securely if login was successful
        if (tokenResponse.isValid) {
          await _storeTokens(
            accessToken: tokenResponse.accessToken!,
            refreshToken: tokenResponse.refreshToken!,
            expiresIn: tokenResponse.expiresIn!,
          );
        }
        
        return tokenResponse;
      } else {
        // Return error response
        return TokenResponse.fromJson(responseData);
      }
    } catch (e) {
      return TokenResponse.error(
        error: 'network_error',
        errorDescription: 'Login error: $e',
      );
    }
  }

  /// Store tokens securely using SharedPreferences
  Future<void> _storeTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);
    
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setInt('token_expiry', expiryTime);
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final expiry = prefs.getInt('token_expiry');
    
    if (token != null && expiry != null && DateTime.now().millisecondsSinceEpoch < expiry) {
      return token;
    }
    return null;
  }


  /// Logout and clear stored tokens
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token_expiry');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}

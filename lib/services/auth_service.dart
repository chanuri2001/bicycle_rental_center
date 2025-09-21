import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/token_response.dart';

class AuthService {
  static const String _baseUrl = 'http://spinisland.devtester.xyz';
  static const String _clientId = '25daa3075c07bb54f3389affd617ee53';
  static const String _clientSecret =
      '928b6288407daabee694d59ba36f9fb6102076810cf0ec4392bda168baf4887de76d338f1d5f6f908927ea2228a5fd65284899385593528b733354c54e0c60c8';

  /// Login using OAuth2 password grant
  Future<TokenResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/token');

      final body = {
        'grant_type': 'password',
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'scope': 'centermobileadmin',
        'username': username, // ✅ using "username" not "email"
        'password': password,
      };

      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };

      final response = await http.post(uri, headers: headers, body: body);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final tokenResponse = TokenResponse.fromJson(responseData);

        if (tokenResponse.isValid) {
          await _storeTokens(
            accessToken: tokenResponse.accessToken!,
            refreshToken: tokenResponse.refreshToken!,
            expiresIn: tokenResponse.expiresIn!,
          );
        }

        return tokenResponse;
      } else {
        print(
          "Login failed with status ${response.statusCode}: ${response.body}",
        );
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
    final expiryTime =
        DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);

    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setInt('token_expiry', expiryTime);
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final expiry = prefs.getInt('token_expiry');

    if (token != null &&
        expiry != null &&
        DateTime.now().millisecondsSinceEpoch < expiry) {
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

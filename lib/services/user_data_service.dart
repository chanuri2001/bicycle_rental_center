// services/user_data_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_data.dart';
import 'auth_service.dart';

class UserDataService {
  static const String _baseUrl = 'http://spinisland.devtester.xyz';
  final AuthService _authService = AuthService();

  /// Fetch user information from the API
  Future<UserData> getUserInfo() async {
    try {
      // Get the access token
      final accessToken = await _authService.getAccessToken();
      
      if (accessToken == null) {
        return UserData(
          status: false,
          statusCode: 401,
          result: null,
        );
      }

      // Make the API call to get user info
      final response = await http.get(
        Uri.parse('$_baseUrl/external-api/v1/user/info'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return UserData.fromJson(responseData);
      } else {
        // Handle error response
        return UserData(
          status: false,
          statusCode: response.statusCode,
          result: null,
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return UserData(
        status: false,
        statusCode: 500,
        result: null,
      );
    }
  }

  /// Check if user is authenticated and fetch user info
  Future<UserData?> getUserInfoIfAuthenticated() async {
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (!isLoggedIn) {
      return null;
    }
    
    return await getUserInfo();
  }

  /// Refresh user data (useful for pull-to-refresh scenarios)
  Future<UserData> refreshUserInfo() async {
    return await getUserInfo();
  }
}

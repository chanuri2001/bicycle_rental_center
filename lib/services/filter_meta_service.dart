// services/filter_meta_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filter_meta.dart';
import '../models/activity_meta.dart';
import 'auth_service.dart';

class FilterMetaService {
  static const String _baseUrl = 'http://spinisland.devtester.xyz';
  final AuthService _authService = AuthService();

  /// Fetch bicycle filter metadata from the API
  Future<FilterMeta> getFilterMeta() async {
    try {
      // Get the access token
      final accessToken = await _authService.getAccessToken();
      
      if (accessToken == null) {
        return FilterMeta(
          status: false,
          statusCode: 401,
          result: null,
        );
      }

      // Make the API call to get filter metadata
      final response = await http.get(
        Uri.parse('$_baseUrl/external-api/v1/bicycle-meta/filter-meta'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return FilterMeta.fromJson(responseData);
      } else {
        // Handle error response
        return FilterMeta(
          status: false,
          statusCode: response.statusCode,
          result: null,
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return FilterMeta(
        status: false,
        statusCode: 500,
        result: null,
      );
    }
  }

  /// Fetch activity filter metadata from the API
  Future<ActivityMeta> getActivityMeta() async {
    try {
      // Get the access token
      final accessToken = await _authService.getAccessToken();
      
      if (accessToken == null) {
        return ActivityMeta(
          status: false,
          statusCode: 401,
          result: null,
        );
      }

      // Make the API call to get activity filter metadata
      final response = await http.get(
        Uri.parse('$_baseUrl/external-api/v1/activity/meta/filter-meta'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ActivityMeta.fromJson(responseData);
      } else {
        // Handle error response
        return ActivityMeta(
          status: false,
          statusCode: response.statusCode,
          result: null,
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      return ActivityMeta(
        status: false,
        statusCode: 500,
        result: null,
      );
    }
  }

}

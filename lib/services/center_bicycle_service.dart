// services/center_bicycle_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/center_bicycle_response.dart';

class CenterBicycleService {
  static const String _baseUrl =
      'http://spinisland.devtester.xyz/external-api/v1/center-bicycle/list';

  static Future<CenterBicycleResponse?> fetchCenterBicycles({
    required String token,
    required String centerUuid, String? searchQuery, String? type, String? status, required int limit, required int page, String? staftus,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "centerUuids": [centerUuid],
          "bicycleUuids": [],
          "makeCodes": [],
          "typeCodes": [],
          "modelCodes": [],
          "conditionStatusCodes": []
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return CenterBicycleResponse.fromJson(jsonData);
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception while fetching center bicycles: $e');
      return null;
    }
  }
}
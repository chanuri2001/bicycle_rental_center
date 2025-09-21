// services/bicycle_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bicycle_meta.dart';
import 'auth_service.dart';

class BicycleService {
  static const String _baseUrl = 'http://spinisland.devtester.xyz/external-api/v1';

  final AuthService _authService;

  BicycleService(this._authService);

  Future<BicycleMeta> getBicycleMeta() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$_baseUrl/bicycle-meta/filter-meta');
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return BicycleMeta.fromJson(jsonResponse['result']);
    } else {
      throw Exception('Failed to load bicycle meta: ${response.statusCode}');
    }
  }

  deleteBicycle({required String token, required String bicycleUuid}) {}
}
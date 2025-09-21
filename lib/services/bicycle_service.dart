// services/bike_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bike_group.dart';
import '../models/token_response.dart';

class BikeService {
  final String baseUrl = "http://spinisland.devtester.xyz";
  final String endpoint = "/external-api/v1/center-activity/bicycles";

  Future<List<BikeGroup>> fetchBikes(String token, String centerUuid) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({"centerActivityUuid": centerUuid}),
    );

    print('📨 POST $url');
    print('🔐 Auth header: $token');
    print('🧾 Status code: ${response.statusCode}');
    print('📋 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list =
          (data['result']['centerActivityBicycles'] as List)
              .map((e) => BikeGroup.fromJson(e))
              .toList();
      return list;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}

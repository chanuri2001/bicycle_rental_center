import 'dart:convert';
import 'package:http/http.dart' as http;

class BicycleService {
  static const String apiUrl =
      "http://spinisland.devtester.xyz/external-api/v1/center-activity/bicycles";

  static Future<Map<String, List<dynamic>>> fetchBicycles() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "centerActivityUuid": "CA-AC784B4744", // use your actual UUID
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "available": data['available'] ?? [],
        "rented": data['rented'] ?? [],
      };
    } else {
      throw Exception("Failed to load bicycles");
    }
  }
}

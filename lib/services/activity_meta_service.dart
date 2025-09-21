import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityMeta {
  static const String _baseUrl = 'http://spinisland.devtester.xyz/external-api/v1';
  final String authToken;

ActivityMeta(this.authToken);

  Future<Map<String, dynamic>> getFilterMeta() async {
    final url = Uri.parse('$_baseUrl/activity/meta/filter-meta');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load filter meta: ${response.statusCode}');
    }
  }
}
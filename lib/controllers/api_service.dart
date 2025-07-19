import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://spinisland.devtester.xyz/external-api/v1';
  static const Map<String, String> _headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'API Error: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  Future<Map<String, dynamic>> getFilterMeta(String uuid) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/activity/meta/filter-meta'),
        headers: _headers,
        body: 'uuid=${Uri.encodeComponent(uuid)}',
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to fetch filter meta: $e');
    }
  }

  Future<List<dynamic>> getEventRegistrations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/registrations'),
        headers: _headers,
      );
      final data = await _handleResponse(response);
      return data['result'] as List;
    } catch (e) {
      throw Exception('Failed to fetch registrations: $e');
    }
  }

  Future<List<dynamic>> getEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events'),
        headers: _headers,
      );
      final data = await _handleResponse(response);
      return data['result'] as List;
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }
}
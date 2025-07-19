// api/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class AuthService {
  static const String _baseUrl =
      'http://spinisland.devtester.xyz/external-api/v1';

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/info'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer YOUR_BEARER_TOKEN', // From Postman
        },
        body: {
          'grant_type': 'password',
          'client_id': '25daa3075c07bb54f3389affd617ee53',
          'client_secret':
              '928b6288407daabee694d59ba36f9fb6102076810cf0ec4392bda168baf4887de76d338f1d5f6f908927ea2228a5fd65284899385593528b733354c54e0c60c8',
          'scope': 'centermobileadmin',
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
}

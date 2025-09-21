import 'dart:convert';
import 'package:bicycle_rental_center/models/user_info_model.dart';
import 'package:http/http.dart' as http;


class UserService {
  static const String _baseUrl =
      'http://spinisland.devtester.xyz/external-api/v1/user/info';

  static Future<User?> fetchUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          return User.fromJson(jsonData['result']);
        } else {
          print('API responded with error status: ${jsonData['statusCode']}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while fetching user info: $e');
    }
    return null;
  }
}

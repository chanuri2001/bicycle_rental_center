import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString authToken = ''.obs;
  final RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // First, authenticate with OAuth2 to get the token
      final tokenResponse = await http.post(
        Uri.parse('http://spinisland.devtester.xyz/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': '25daa3075c07bb54f3389affd617ee53',
          'client_secret':
              '928b6288407daabee694d59ba36f9fb6102076810cf0ec4392bda168baf4887de76d338f1d5f6f908927ea2228a5fd65284899385593528b733354c54e0c60c8',
          'scope': 'centermobileadmin',
          'username': username, // Using username instead of email
          'password': password,
        },
      );

      if (tokenResponse.statusCode == 200) {
        final tokenData = json.decode(tokenResponse.body);
        authToken.value = tokenData['access_token'];

        // Now fetch user info with the obtained token
        final userResponse = await http.get(
          Uri.parse(
            'http://spinisland.devtester.xyz/external-api/v1/user/info',
          ),
          headers: {
            'Authorization': 'Bearer ${authToken.value}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        );

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          if (userData['status'] == true) {
            userInfo.value = userData['result'];

            // Save token and user info to shared preferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('authToken', authToken.value);
            await prefs.setString('userInfo', json.encode(userInfo.value));

            return true;
          } else {
            errorMessage.value = 'Failed to fetch user info';
            return false;
          }
        } else {
          errorMessage.value =
              'Failed to fetch user info: ${userResponse.statusCode}';
          return false;
        }
      } else {
        final errorData = json.decode(tokenResponse.body);
        errorMessage.value = errorData['error_description'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userInfoString = prefs.getString('userInfo');

    if (token != null && userInfoString != null) {
      authToken.value = token;
      userInfo.value = json.decode(userInfoString);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userInfo');
    authToken.value = '';
    userInfo.value = {};
  }
}

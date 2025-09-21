// activity_service.dart
import 'dart:convert';
import 'package:bicycle_rental_center/models/BookingResponse.dart';
import 'package:bicycle_rental_center/models/bike_group.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class ActivityService {
  static const String _baseUrl =
      'http://spinisland.devtester.xyz/external-api/v1';

  Future<List<Event>> getCenterActivities({required DateTime date}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No access token available');
      }

      final url = Uri.parse('$_baseUrl/center-activity/list');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')} 00:00:00';

      final body = json.encode({
        "centerUuids": [],
        "activityUuids": [],
        "activityTypeCodes": [],
        "activityStatusCodes": [],
        "centerActivityStatusCodes": [],
        "objectGroupBy": null,
        "date": formattedDate,
        "dateType": "EVENT",
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return (responseData['result']['centerActivities'] as List)
              .map((activityJson) => Event.fromJson(activityJson))
              .toList();
        } else {
          throw Exception(
            'API returned false status: ${responseData['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load activities. Status code: ${response.statusCode}\n'
          'Response: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in getCenterActivities: $e');
      rethrow;
    }
  }

  Future<Event> getActivityDetails(String centerActivityUuid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No access token available');
      }

      final url = Uri.parse(
        '$_baseUrl/center-activity/$centerActivityUuid/detail',
      );
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return Event.fromDetailJson(responseData['result']);
        } else {
          throw Exception(
            'API returned false status: ${responseData['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load activity details. Status code: ${response.statusCode}\n'
          'Response: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in getActivityDetails: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getActivityDetailsRaw(
    String centerActivityUuid,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception('No access token available');

      final url = Uri.parse(
        '$_baseUrl/center-activity/$centerActivityUuid/detail',
      );
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load activity details: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error in getActivityDetailsRaw: $e');
      rethrow;
    }
  }

  Future<List<BikeGroup>> getCenterActivityBicycles(
    String centerActivityUuid,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No access token available');
      }

      final url = Uri.parse('$_baseUrl/center-activity/bicycles');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({"centerActivityUuid": centerActivityUuid});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return (responseData['result']['centerActivityBicycles'] as List)
              .map((bicycleJson) => BikeGroup.fromJson(bicycleJson))
              .toList();
        } else {
          throw Exception(
            'API returned false status: ${responseData['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load bicycles. Status code: ${response.statusCode}\n'
          'Response: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in getCenterActivityBicycles: $e');
      rethrow;
    }
  }

  Future<BookingResponse> createCenterActivityBooking({
    required String centerEventUuid,
    required String centerEventSessionUuid,
    required String rentalMode,
    required Map<String, dynamic> primaryUser,
    required List<Map<String, dynamic>> centerBicycleChoices,
    String trackPointUuid = '',
    String nfcHolderCode = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('No access token available');
      }

      final url = Uri.parse('$_baseUrl/center-activity-booking/new-booking');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        "centerEventUuid": centerEventUuid,
        "centerEventSessionUuid": centerEventSessionUuid,
        "trackPointUuid": trackPointUuid,
        "nfcHolderCode": nfcHolderCode,
        "rentalMode": rentalMode,
        "primaryUser": primaryUser,
        "centerBicycleChoices": centerBicycleChoices,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return BookingResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create booking. Status code: ${response.statusCode}\n'
          'Response: ${response.body}',
        );
      }
    } catch (e) {
      print('Error in createCenterActivityBooking: $e');
      rethrow;
    }
  }
}

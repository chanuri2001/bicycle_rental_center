import 'package:bicycle_rental_center/models/rental_request.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RentalService {
  final String _baseUrl = 'https://your-api-endpoint.com'; // Replace with your actual API endpoint
  final String _apiKey = 'your-api-key'; // Replace with your actual API key

  Future<List<RentalRequest>> getRentalRequestsForCenter(String centerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rentals?center_id=$centerId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => RentalRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rental requests: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load rental requests: $e');
    }
  }

  Future<RentalRequest> getRentalRequestById(String rentalId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rentals/$rentalId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return RentalRequest.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load rental request: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load rental request: $e');
    }
  }

  Future<RentalRequest> updateRentalStatus(
    String rentalId,
    RentalStatus status, {
    String? rejectionReason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/rentals/$rentalId/status'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status.name,
          if (rejectionReason != null) 'rejection_reason': rejectionReason,
        }),
      );

      if (response.statusCode == 200) {
        return RentalRequest.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update rental status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update rental status: $e');
    }
  }

  Future<RentalRequest> markRentalAsPickedUp(String rentalId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rentals/$rentalId/pickup'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return RentalRequest.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to mark rental as picked up: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to mark rental as picked up: $e');
    }
  }

  Future<RentalRequest> markRentalAsReturned(String rentalId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rentals/$rentalId/return'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return RentalRequest.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to mark rental as returned: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to mark rental as returned: $e');
    }
  }

  Future<List<RentalRequest>> getActiveRentalsForCenter(String centerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rentals/active?center_id=$centerId'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => RentalRequest.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load active rentals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load active rentals: $e');
    }
  }
}
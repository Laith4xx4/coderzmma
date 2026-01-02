import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/api_strings.dart';

import '../models/booking_model.dart';
import '../models/create_booking_model.dart';
import '../models/update_booking_model.dart';

class BookingApiService {
  BookingApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  /// Get token from SharedPreferences
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    return token;
  }

  Future<List<BookingModel>> getAllBookings() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.bookingsEndpoint);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body) as List;
        return data
            .map(
              (e) => BookingModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      } else {
        print('getAllBookings error: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getAllBookings exception: $e');
      print(st);
      rethrow;
    }
  }

  Future<BookingModel> getBookingById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return BookingModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load booking (${response.statusCode}): ${response.body}');
    }
  }

  Future<BookingModel> createBooking(CreateBookingModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.bookingsEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BookingModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create booking (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateBooking(int id, UpdateBookingModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update booking (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteBooking(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete booking (${response.statusCode}): ${response.body}');
    }
  }

  /// Smart Booking - يحجز الجلسة باستخدام token المستخدم الحالي
  Future<BookingModel> bookSession(int sessionId) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/book');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'sessionId': sessionId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BookingModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to book session (${response.statusCode}): ${response.body}');
    }
  }

  /// Get current user's bookings
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final token = await _getToken();
      final url = _buildUri('${ApiStrings.bookingsEndpoint}/my-bookings');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body) as List;
        return data
            .map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print('getMyBookings error: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load my bookings: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getMyBookings exception: $e');
      print(st);
      rethrow;
    }
  }

  /// Cancel a booking
  Future<void> cancelBooking(int bookingId) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/cancel/$bookingId');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to cancel booking (${response.statusCode}): ${response.body}');
    }
  }
}


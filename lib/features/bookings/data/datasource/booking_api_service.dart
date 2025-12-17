import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/booking_model.dart';
import '../models/create_booking_model.dart';
import '../models/update_booking_model.dart';

class BookingApiService {
  BookingApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  Future<List<BookingModel>> getAllBookings() async {
    final url = _buildUri(ApiStrings.bookingsEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map(
            (e) => BookingModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<BookingModel> getBookingById(int id) async {
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return BookingModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load booking');
    }
  }

  Future<BookingModel> createBooking(CreateBookingModel data) async {
    final url = _buildUri(ApiStrings.bookingsEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BookingModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create booking');
    }
  }

  Future<void> updateBooking(int id, UpdateBookingModel data) async {
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update booking');
    }
  }

  Future<void> deleteBooking(int id) async {
    final url = _buildUri('${ApiStrings.bookingsEndpoint}/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete booking');
    }
  }
}


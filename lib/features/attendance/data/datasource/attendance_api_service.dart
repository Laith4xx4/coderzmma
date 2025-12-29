import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/api_strings.dart';

import '../models/attendance_model.dart';
import '../models/create_attendance_model.dart';
import '../models/update_attendance_model.dart';

class AttendanceApiService {
  AttendanceApiService();

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

  Future<List<AttendanceModel>> getAllAttendances() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.attendancesEndpoint);

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
            .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print('getAllAttendances error: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load attendances: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getAllAttendances exception: $e');
      print(st);
      rethrow;
    }
  }

  Future<AttendanceModel> getAttendanceById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.attendancesEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return AttendanceModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load attendance (${response.statusCode}): ${response.body}');
    }
  }

  Future<AttendanceModel> createAttendance(CreateAttendanceModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.attendancesEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AttendanceModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create attendance (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateAttendance(int id, UpdateAttendanceModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.attendancesEndpoint}/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update attendance (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteAttendance(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.attendancesEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete attendance (${response.statusCode}): ${response.body}');
    }
  }
}



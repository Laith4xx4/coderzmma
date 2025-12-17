import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/attendance_model.dart';
import '../models/create_attendance_model.dart';
import '../models/update_attendance_model.dart';

class AttendanceApiService {
  AttendanceApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  Future<List<AttendanceModel>> getAllAttendances() async {
    final url = _buildUri(ApiStrings.attendancesEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load attendances');
    }
  }

  Future<AttendanceModel> getAttendanceById(int id) async {
    final url = _buildUri('${ApiStrings.attendancesEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return AttendanceModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load attendance');
    }
  }

  Future<AttendanceModel> createAttendance(CreateAttendanceModel data) async {
    final url = _buildUri(ApiStrings.attendancesEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AttendanceModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create attendance');
    }
  }

  Future<void> updateAttendance(int id, UpdateAttendanceModel data) async {
    final url = _buildUri('${ApiStrings.attendancesEndpoint}/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update attendance');
    }
  }

  Future<void> deleteAttendance(int id) async {
    final url = _buildUri('${ApiStrings.attendancesEndpoint}/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete attendance');
    }
  }
}



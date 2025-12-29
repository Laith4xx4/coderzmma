import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thesavage/core/api_strings.dart';
import '../models/coach_model.dart';
import '../models/create_coach_model.dart';
import '../models/update_coach_model.dart';

class CoachApiService {
  CoachApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  /// دالة داخلية للحصول على التوكن من SharedPreferences
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    return token;
  }

  // ===================== GET all coaches =====================
  Future<List<CoachModel>> getAllCoaches() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.coachProfilesEndpoint);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => CoachModel.fromJson(e)).toList();
      } else {
        print('getCoaches error: '
            'status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load coaches: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getCoaches exception: $e');
      print(st);
      rethrow;
    }
  }

  // ===================== GET coach by id =====================
  Future<CoachModel> getCoachById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.coachProfilesEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return CoachModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to load coach (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ===================== POST create coach =====================
  Future<CoachModel> createCoach(CreateCoachModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.coachProfilesEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CoachModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to create coach (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ===================== PUT update coach =====================
  Future<void> updateCoach(int id, UpdateCoachModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.coachProfilesEndpoint}/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to update coach (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ===================== DELETE coach =====================
  Future<void> deleteCoach(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.coachProfilesEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete coach (${response.statusCode}): ${response.body}',
      );
    }
  }
}
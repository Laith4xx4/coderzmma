import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/api_strings.dart';

import '../models/create_member_progress_model.dart';
import '../models/member_progress_model.dart';
import '../models/update_member_progress_model.dart';

class MemberProgressApiService {
  MemberProgressApiService();

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

  Future<List<MemberProgressModel>> getAllProgress() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.memberSetProgressEndpoint);

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
            .map((e) => MemberProgressModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print('getAllProgress error: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load member progress: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getAllProgress exception: $e');
      print(st);
      rethrow;
    }
  }

  Future<MemberProgressModel> getProgressById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.memberSetProgressEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return MemberProgressModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load member progress (${response.statusCode}): ${response.body}');
    }
  }

  Future<MemberProgressModel> createProgress(
      CreateMemberProgressModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.memberSetProgressEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MemberProgressModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create member progress (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateProgress(int id, UpdateMemberProgressModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.memberSetProgressEndpoint}/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update member progress (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteProgress(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.memberSetProgressEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete member progress (${response.statusCode}): ${response.body}');
    }
  }
}



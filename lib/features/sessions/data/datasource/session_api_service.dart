import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/api_strings.dart';

import '../models/create_session_model.dart';
import '../models/session_model.dart';
import '../models/update_session_model.dart';

class SessionApiService {
  SessionApiService();

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

  Future<List<SessionModel>> getAllSessions() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.sessionsEndpoint);

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
            .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print('getAllSessions error: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load sessions: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getAllSessions exception: $e');
      print(st);
      rethrow;
    }
  }

  Future<SessionModel> getSessionById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.sessionsEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return SessionModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load session (${response.statusCode}): ${response.body}');
    }
  }

  Future<SessionModel> createSession(CreateSessionModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.sessionsEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SessionModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create session (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateSession(int id, UpdateSessionModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.sessionsEndpoint}/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update session (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteSession(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.sessionsEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete session (${response.statusCode}): ${response.body}');
    }
  }
}

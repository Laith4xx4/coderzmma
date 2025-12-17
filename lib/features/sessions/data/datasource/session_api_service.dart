import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/create_session_model.dart';
import '../models/session_model.dart';
import '../models/update_session_model.dart';

class SessionApiService {
  SessionApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  Future<List<SessionModel>> getAllSessions() async {
    final url = _buildUri(ApiStrings.sessionsEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  Future<SessionModel> getSessionById(int id) async {
    final url = _buildUri('${ApiStrings.sessionsEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return SessionModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load session');
    }
  }

  Future<SessionModel> createSession(CreateSessionModel data) async {
    final url = _buildUri(ApiStrings.sessionsEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SessionModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create session');
    }
  }

  Future<void> updateSession(int id, UpdateSessionModel data) async {
    final url = _buildUri('${ApiStrings.sessionsEndpoint}/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update session');
    }
  }

  Future<void> deleteSession(int id) async {
    final url = _buildUri('${ApiStrings.sessionsEndpoint}/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete session');
    }
  }
}

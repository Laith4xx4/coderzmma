import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/coach_model.dart';
import '../models/create_coach_model.dart';
import '../models/update_coach_model.dart';

class CoachApiService {
  CoachApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  Future<List<CoachModel>> getAllCoaches() async {
    final url = _buildUri(ApiStrings.coachProfilesEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => CoachModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load coaches');
    }
  }

  Future<CoachModel> getCoachById(int id) async {
    final url = _buildUri('${ApiStrings.coachProfilesEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return CoachModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load coach');
    }
  }

  Future<CoachModel> createCoach(CreateCoachModel data) async {
    final url = _buildUri(ApiStrings.coachProfilesEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CoachModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create coach');
    }
  }

  Future<void> updateCoach(int id, UpdateCoachModel data) async {
    final url = _buildUri('${ApiStrings.coachProfilesEndpoint}/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update coach');
    }
  }

  Future<void> deleteCoach(int id) async {
    final url = _buildUri('${ApiStrings.coachProfilesEndpoint}/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete coach');
    }
  }
}



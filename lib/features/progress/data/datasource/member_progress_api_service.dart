import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/create_member_progress_model.dart';
import '../models/member_progress_model.dart';
import '../models/update_member_progress_model.dart';

class MemberProgressApiService {
  MemberProgressApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  Future<List<MemberProgressModel>> getAllProgress() async {
    final url = _buildUri(ApiStrings.memberSetProgressEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => MemberProgressModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load member progress');
    }
  }

  Future<MemberProgressModel> getProgressById(int id) async {
    final url = _buildUri('${ApiStrings.memberSetProgressEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return MemberProgressModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load member progress');
    }
  }

  Future<MemberProgressModel> createProgress(
      CreateMemberProgressModel data) async {
    final url = _buildUri(ApiStrings.memberSetProgressEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MemberProgressModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create member progress');
    }
  }

  Future<void> updateProgress(int id, UpdateMemberProgressModel data) async {
    final url = _buildUri('${ApiStrings.memberSetProgressEndpoint}/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update member progress');
    }
  }

  Future<void> deleteProgress(int id) async {
    final url = _buildUri('${ApiStrings.memberSetProgressEndpoint}/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete member progress');
    }
  }
}



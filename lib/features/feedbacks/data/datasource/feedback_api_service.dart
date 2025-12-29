import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/api_strings.dart';

import '../models/create_feedback_model.dart';
import '../models/feedback_model.dart';
import '../models/update_feedback_model.dart';

class FeedbackApiService {
  FeedbackApiService();

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

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.feedbackEndpoint);

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
            .map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print('getAllFeedbacks error: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load feedbacks: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getAllFeedbacks exception: $e');
      print(st);
      rethrow;
    }
  }

  Future<FeedbackModel> getFeedbackById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.feedbackEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return FeedbackModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load feedback (${response.statusCode}): ${response.body}');
    }
  }

  Future<FeedbackModel> createFeedback(CreateFeedbackModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.feedbackEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FeedbackModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create feedback (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateFeedback(int id, UpdateFeedbackModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.feedbackEndpoint}/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update feedback (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteFeedback(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.feedbackEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete feedback (${response.statusCode}): ${response.body}');
    }
  }
}



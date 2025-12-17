import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/create_feedback_model.dart';
import '../models/feedback_model.dart';
import '../models/update_feedback_model.dart';

class FeedbackApiService {
  FeedbackApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    final url = _buildUri(ApiStrings.feedbackEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => FeedbackModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load feedbacks');
    }
  }

  Future<FeedbackModel> getFeedbackById(int id) async {
    final url = _buildUri('${ApiStrings.feedbackEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return FeedbackModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load feedback');
    }
  }

  Future<FeedbackModel> createFeedback(CreateFeedbackModel data) async {
    final url = _buildUri(ApiStrings.feedbackEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FeedbackModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create feedback');
    }
  }

  Future<void> updateFeedback(int id, UpdateFeedbackModel data) async {
    final url = _buildUri('${ApiStrings.feedbackEndpoint}/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update feedback');
    }
  }

  Future<void> deleteFeedback(int id) async {
    final url = _buildUri('${ApiStrings.feedbackEndpoint}/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete feedback');
    }
  }
}



import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thesavage/core/api_strings.dart';

class SupportApiService {
  Future<void> sendSupportMessage({
    required String subject,
    required String message,
    String? email,
    String? userName,
    String? token, // Optional if user is logged in
  }) async {
    final baseUrl = ApiStrings.baseUrl;
    final url = Uri.parse('$baseUrl/Support');
    
    final Map<String, dynamic> body = {
      'subject': subject,
      'message': message,
      if (email != null) 'email': email,
      if (userName != null) 'userName': userName,
    };

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> fetchSupportMessages(String token) async {
    final baseUrl = ApiStrings.baseUrl;
    final url = Uri.parse('$baseUrl/Support');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteSupportMessage(int id, String token) async {
    final baseUrl = ApiStrings.baseUrl;
    final url = Uri.parse('$baseUrl/Support/$id');

    final headers = {
      'Authorization': 'Bearer $token',
    };

    final response = await http.delete(url, headers: headers);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }
}

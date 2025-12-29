import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thesavage/core/api_strings.dart';
import '../models/member_profile_model.dart';
import '../models/create_member_profile_model.dart';
import '../models/update_member_profile_model.dart';

class MemberApiService {
  MemberApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  /// دالة داخلية للحصول على التوكن من SharedPreferences
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // تأكد أنك تستخدم نفس المفتاح 'token' الذي استخدمته عند تسجيل الدخول
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    return token;
  }

  // ===================== GET all members =====================
  Future<List<MemberProfileModel>> getAllMembers() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.memberProfilesEndpoint);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => MemberProfileModel.fromJson(e)).toList();
      } else {
        print('getAllMembers error: '
            'status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getAllMembers exception: $e');
      print(st);
      rethrow;
    }
  }

  // ===================== GET member by id =====================
  Future<MemberProfileModel> getMemberById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.memberProfilesEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return MemberProfileModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to load member (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ===================== POST create member =====================
  Future<MemberProfileModel> createMember(CreateMemberProfileModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.memberProfilesEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MemberProfileModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to create member (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ===================== PUT update member =====================
  Future<void> updateMember(int id, UpdateMemberProfileModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.memberProfilesEndpoint}/$id');

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
        'Failed to update member (${response.statusCode}): ${response.body}',
      );
    }
  }

  // ===================== DELETE member =====================
  Future<void> deleteMember(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.memberProfilesEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete member (${response.statusCode}): ${response.body}',
      );
    }
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/member_profile_model.dart';
import '../models/create_member_profile_model.dart';
import '../models/update_member_profile_model.dart';


class MemberApiService {
  MemberApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }
  // ---------------- Get All Members ----------------
  Future<List<MemberProfileModel>> getAllMembers() async {
    final url =_buildUri(ApiStrings.memberProfilesEndpoint);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => MemberProfileModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load members");
    }
  }

  // ---------------- Get Member By Id ----------------
  Future<MemberProfileModel> getMemberById(int id) async {
    final url = _buildUri("${ApiStrings.memberProfilesEndpoint}/$id");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return MemberProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load member");
    }
  }

  // ---------------- Create Member ----------------
  Future<MemberProfileModel> createMember(CreateMemberProfileModel member) async {
    final url = _buildUri(ApiStrings.memberProfilesEndpoint);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(member.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MemberProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to create member");
    }
  }

  // ---------------- Update Member ----------------
  Future<void> updateMember(int id, UpdateMemberProfileModel member) async {
    final url = _buildUri("${ApiStrings.memberProfilesEndpoint}/$id");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(member.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to update member");
    }
  }

  // ---------------- Delete Member ----------------
  Future<void> deleteMember(int id) async {
    final url = _buildUri("${ApiStrings.memberProfilesEndpoint}/$id");

    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete member");
    }
  }
}

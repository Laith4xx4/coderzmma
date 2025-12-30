import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thesavage/features/users/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/api_strings.dart';


class UserApiService {
  final String baseUrl = ApiStrings.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get all users (Admin only)

  Future<List<UserEntity>> getAllUsers() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/Users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UserEntity.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Admin access required');
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  /// Change user role (Admin only)
  Future<void> changeUserRole(String userName, String roleName) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.put(
      Uri.parse('$baseUrl/Users/$userName/role'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(roleName),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Admin access required');
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to change role');
    }
  }

  /// Delete user (Admin only)
  Future<void> deleteUser(String userName) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/Users/$userName'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Admin access required');
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to delete user');
    }
  }

  /// Get users by role
  Future<List<UserEntity>> getUsersByRole(String roleName) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/Users/role/$roleName'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UserEntity.fromJson(json)).toList();
    } else if (response.statusCode == 404) {
      return []; // No users with this role
    } else {
      throw Exception('Failed to load users by role: ${response.statusCode}');
    }
  }
}

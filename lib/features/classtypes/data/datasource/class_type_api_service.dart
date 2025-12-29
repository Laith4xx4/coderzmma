import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesavage/core/api_strings.dart';

import '../models/class_type_model.dart';
import '../models/create_class_type_model.dart';
import '../models/update_class_type_model.dart';

class ClassTypeApiService {
  ClassTypeApiService();

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

  Future<List<ClassTypeModel>> getAllClassTypes() async {
    try {
      final token = await _getToken();
      final url = _buildUri(ApiStrings.classTypesEndpoint);

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
            .map((e) => ClassTypeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print('getAllClassTypes error: status=${response.statusCode}, body=${response.body}');
        throw Exception('Failed to load class types: ${response.statusCode}');
      }
    } catch (e, st) {
      print('getAllClassTypes exception: $e');
      print(st);
      rethrow;
    }
  }

  Future<ClassTypeModel> getClassTypeById(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.classTypesEndpoint}/$id');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return ClassTypeModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load class type (${response.statusCode}): ${response.body}');
    }
  }

  Future<ClassTypeModel> createClassType(CreateClassTypeModel data) async {
    final token = await _getToken();
    final url = _buildUri(ApiStrings.classTypesEndpoint);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ClassTypeModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create class type (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> updateClassType(int id, UpdateClassTypeModel data) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.classTypesEndpoint}/$id');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update class type (${response.statusCode}): ${response.body}');
    }
  }

  Future<void> deleteClassType(int id) async {
    final token = await _getToken();
    final url = _buildUri('${ApiStrings.classTypesEndpoint}/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete class type (${response.statusCode}): ${response.body}');
    }
  }
}



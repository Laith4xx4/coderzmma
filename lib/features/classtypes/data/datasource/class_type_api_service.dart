import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:maa3/core/api_strings.dart';

import '../models/class_type_model.dart';
import '../models/create_class_type_model.dart';
import '../models/update_class_type_model.dart';

class ClassTypeApiService {
  ClassTypeApiService();

  Uri _buildUri(String path) {
    return Uri.parse('${ApiStrings.baseUrl}$path');
  }

  Future<List<ClassTypeModel>> getAllClassTypes() async {
    final url = _buildUri(ApiStrings.classTypesEndpoint);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body) as List;
      return data
          .map((e) => ClassTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load class types');
    }
  }

  Future<ClassTypeModel> getClassTypeById(int id) async {
    final url = _buildUri('${ApiStrings.classTypesEndpoint}/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return ClassTypeModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load class type');
    }
  }

  Future<ClassTypeModel> createClassType(CreateClassTypeModel data) async {
    final url = _buildUri(ApiStrings.classTypesEndpoint);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ClassTypeModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to create class type');
    }
  }

  Future<void> updateClassType(int id, UpdateClassTypeModel data) async {
    final url = _buildUri('${ApiStrings.classTypesEndpoint}/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update class type');
    }
  }

  Future<void> deleteClassType(int id) async {
    final url = _buildUri('${ApiStrings.classTypesEndpoint}/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete class type');
    }
  }
}



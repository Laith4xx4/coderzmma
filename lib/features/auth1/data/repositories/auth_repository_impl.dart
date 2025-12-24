import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:maa3/features/auth1/data/models/user_model.dart';
import 'package:maa3/features/auth1/domain/entities/user.dart';
import 'package:maa3/features/auth1/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final String baseUrl;

  AuthRepositoryImpl({required this.baseUrl});

  /// دالة داخلية لحفظ التوكن من الـ JSON (بغض النظر عن اسم المفتاح)
  Future<String?> _saveTokenFromResponse(Map<String, dynamic> data) async {
    // عدل أسماء المفاتيح حسب الـ API عندك
    final rawToken =
        data['token'] ?? data['Token'] ?? data['accessToken'] ?? data['jwt'];

    if (rawToken == null) return null;

    final token = rawToken.toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return token;
  }

  // ====================== 🔐 تسجيل الدخول ======================
  @override
  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/Auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userNameOrEmail': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // حفظ التوكن في SharedPreferences
      final token = await _saveTokenFromResponse(data);

      // نضمن أن اسم الحقل في الـ JSON هو "token" ليستعمله UserModel
      final normalized = {
        ...data,
        if (token != null) 'token': token,
      };

      return UserModel.fromJson(normalized);
    } else {
      throw Exception('Login failed (${response.statusCode}): ${response.body}');
    }
  }

  // ====================== 🧾 تسجيل حساب جديد ======================
  @override
  Future<User> register({
    required String userName,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    final url = Uri.parse('$baseUrl/Auth/register');

    final requestBody = {
      'userName': userName,
      'email': email,
      'password': password,
      'role': 'Member', // الدور الافتراضي
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // بعض الـ APIs ترجع توكن بعد التسجيل
      final token = await _saveTokenFromResponse(data);

      final normalized = {
        ...data,
        if (token != null) 'token': token,
      };

      return UserModel.fromJson(normalized);
    } else {
      throw Exception(
          'Register failed (${response.statusCode}): ${response.body}');
    }
  }

  // ====================== 👤 جلب بيانات المستخدم ======================
  @override
  Future<User> getUserProfile(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('No auth token found. Please login again.');
    }

    final url = Uri.parse('$baseUrl/Users/$email');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // مهم جداً
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final normalized = {
        ...data,
        'token': token, // نضمن أن التوكن موجود في الموديل
      };

      return UserModel.fromJson(normalized);
    } else {
      throw Exception(
        'Failed to fetch profile (${response.statusCode}): ${response.body}',
      );
    }
  }
}
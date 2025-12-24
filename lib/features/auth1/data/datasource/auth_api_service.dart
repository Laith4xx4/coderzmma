import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  // // الرابط الأساسي للـ Auth
  final String _authBaseUrl = 'http://192.168.100.66:5086/api/Auth';
  // final String _authBaseUrl = 'http://192.168.68.108:5086/api/Auth';
  // الرابط الأساسي للمستخدمين
  final String _usersBaseUrl = 'http://192.168.100.66/api/Users';

  // =================== Login ===================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_authBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final roleFromApi = data['role']?.toString() ?? 'Member';

      return {
        'id': data['id']?.toString() ?? '',
        'token': data['token']?.toString() ?? '',
        'role': roleFromApi,
        'email': data['email']?.toString() ?? email,
        'firstName': data['firstName']?.toString(),
        'lastName': data['lastName']?.toString(),
        'phoneNumber': data['phoneNumber']?.toString(),
        'dateOfBirth': data['dateOfBirth']?.toString(),
      };
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message']?.toString() ?? 'Failed to login');
    }
  }

  // =================== Register ===================
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dateOfBirth,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'role': role,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    };

    final response = await http.post(
      Uri.parse('$_authBaseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final roleFromApi = data['role']?.toString() ?? role;

      return {
        'id': data['id']?.toString() ?? '',
        'email': data['email']?.toString() ?? email,
        'role': roleFromApi,
        'token': data['token']?.toString(),
        'firstName': data['firstName']?.toString(),
        'lastName': data['lastName']?.toString(),
        'phoneNumber': data['phoneNumber']?.toString(),
        'dateOfBirth': data['dateOfBirth']?.toString(),
      };
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message']?.toString() ?? 'Failed to register');
    }
  }

  // =================== Get Current User Profile (ME) ===================
  /// دالة لجلب بيانات المستخدم الحالي بناءً على التوكن فقط
  /// تستهدف الرابط: api/Users/me
  Future<Map<String, dynamic>> getCurrentUserProfile(String token) async {
    final uri = Uri.parse('$_usersBaseUrl/me');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // التوكن ضروري جداً هنا
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // التعامل مع احتمالية اختلاف حالة الأحرف (PascalCase vs camelCase) من الباك اند
      return {
        'id': data['id']?.toString() ?? data['Id']?.toString() ?? '',
        'email': data['email']?.toString() ?? data['Email']?.toString() ?? '',

        // جلب الـ Role
        'role': data['role']?.toString() ?? data['Role']?.toString() ?? 'Member',

        'token': token, // نعيد التوكن المرسل للحفاظ على بنية الموديل

        // جلب البيانات الشخصية
        'firstName': data['firstName']?.toString() ?? data['FirstName']?.toString(),
        'lastName': data['lastName']?.toString() ?? data['LastName']?.toString(),
        'phoneNumber': data['phoneNumber']?.toString() ?? data['PhoneNumber']?.toString(),
        'dateOfBirth': data['dateOfBirth']?.toString() ?? data['DateOfBirth']?.toString(),
      };
    } else {
      print('Failed to load user profile. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load user profile');
    }
  }
}
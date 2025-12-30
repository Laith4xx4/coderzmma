import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:thesavage/core/api_strings.dart';

class AuthApiService {
  final String _baseUrl = ApiStrings.baseUrl;

  // =================== Login ===================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiStrings.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

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
    } catch (e) {
      if (e is TimeoutException) throw Exception('Connection timeout. Please check your internet or server IP.');
      if (e is SocketException) throw Exception('No internet connection or server is unreachable.');
      rethrow;
    }
  }

  // =================== Google Login ===================
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiStrings.baseUrl.endsWith('/') ? '' : '/'}Auth/google-login'), // Correct endpoint construction
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // We expect a JWT token back. Structure might vary, but assuming similar to login response
      // Backend returns { "Token": "..." }
      
      final token = data['token']?.toString() ?? data['Token']?.toString() ?? '';
      
      // If we need user details immediately, we should call 'me' endpoint or decode token
      // For consistency with other methods, let's just return the token and basic info if available
      // Ideally backend should return full user object like login, but current backend code shows only Token.
      // So we will return what we have.
      return {
        'token': token,
      }; 
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message']?.toString() ?? 'Failed to login with Google');
      }
    } catch (e) {
      if (e is TimeoutException) throw Exception('Connection timeout. Please check your internet or server IP.');
      if (e is SocketException) throw Exception('No internet connection or server is unreachable.');
      rethrow;
    }
  }

  // =================== Register ===================
  Future<Map<String, dynamic>> register({
    required String userName, // Added userName
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dateOfBirth,
  }) async {
    final body = {
      'userName': userName, // Added userName
      'email': email,
      'password': password,
      'role': role,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiStrings.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      ).timeout(const Duration(seconds: 15));

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
    } catch (e) {
      if (e is TimeoutException) throw Exception('Connection timeout. Please check your internet or server IP.');
      if (e is SocketException) throw Exception('No internet connection or server is unreachable.');
      rethrow;
    }
  }

  // =================== Get Current User Profile (ME) ===================
  /// دالة لجلب بيانات المستخدم الحالي بناءً على التوكن فقط
  /// تستهدف الرابط: api/Users/me
  Future<Map<String, dynamic>> getCurrentUserProfile(String token) async {
    // Note: Assuming '/Users/me' is standard, if not defined in ApiStrings, we append it directly
    final uri = Uri.parse('$_baseUrl/Users/me');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // التوكن ضروري جداً هنا
        },
      ).timeout(const Duration(seconds: 15));

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
    } catch (e) {
      if (e is TimeoutException) throw Exception('Connection timeout. Please check your internet or server IP.');
      if (e is SocketException) throw Exception('No internet connection or server is unreachable.');
      rethrow;
    }
  }
}
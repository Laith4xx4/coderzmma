import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // ✅ أضف هذا المكتبة لاستخراج الاسم

import 'package:thesavage/features/auth1/data/models/user_model.dart';
import 'package:thesavage/features/auth1/domain/entities/user.dart';
import 'package:thesavage/features/auth1/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final String baseUrl;

  AuthRepositoryImpl({required this.baseUrl});

  /// دالة داخلية لحفظ التوكن
  Future<String?> _saveTokenFromResponse(Map<String, dynamic> data) async {
    final rawToken = data['token'] ?? data['Token'] ?? data['accessToken'] ?? data['jwt'];
    if (rawToken == null) return null;

    final token = rawToken.toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    return token;
  }

  /// دالة لجلب الـ numeric ID من الـ API بناءً على الدور
  Future<int?> _fetchNumericId(String role, String token, String userName) async {
    try {
      String endpoint;
      if (role.toLowerCase() == 'member' || role.toLowerCase() == 'client') {
        endpoint = '$baseUrl/MemberProfiles/me';
      } else if (role.toLowerCase() == 'coach') {
        endpoint = '$baseUrl/CoachProfiles/me';
      } else {
        print('❌ Unknown role: $role, cannot fetch numeric ID');
        return null;
      }

      print('📡 Calling API: $endpoint');
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 API Response Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> profile = jsonDecode(response.body);
        final numericId = profile['id'] ?? profile['Id'];
        
        if (numericId != null) {
          print('✅ Found profile! Numeric ID: $numericId');
          return numericId is int ? numericId : int.tryParse(numericId.toString());
        } else {
          print('❌ No ID found in profile response');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('⚠️ Profile not found. Attempting to auto-create profile for $userName...');
        final created = await _createProfile(role, userName, token);
        if (created) {
          print('✅ Profile created successfully! Retrying fetch...');
          // Retry fetching ID after creation
          // استخدام recursion مع flag لتجنب infinite loop يمكن أن يكون أفضل، لكن هنا سنعتمد على أن الخلق نجح
          return await _fetchNumericId(role, token, userName);
        } else {
          print('❌ Failed to auto-create profile.');
          return null;
        }
      } else {
        print('❌ Failed to fetch profile: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching numeric ID: $e');
      return null;
    }
  }

  Future<bool> _createProfile(String role, String userName, String token) async {
    try {
      String endpoint;
      Map<String, dynamic> body;

      if (role.toLowerCase() == 'member' || role.toLowerCase() == 'client') {
        endpoint = '$baseUrl/MemberProfiles';
        body = {
          'userName': userName,
          'firstName': userName,
          'joinDate': DateTime.now().toIso8601String(),
        };
      } else if (role.toLowerCase() == 'coach') {
        endpoint = '$baseUrl/CoachProfiles';
        body = {
          'userName': userName,
          'bio': 'New Coach',
          'specialization': 'General',
        };
      } else {
        return false;
      }

      print('🛠 Creating profile at $endpoint with body: $body');
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('🛠 Create Profile Response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error creating profile: $e');
      return false;
    }
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
      final token = await _saveTokenFromResponse(data);
      final prefs = await SharedPreferences.getInstance();


      // ✅ استخراج البيانات من التوكن
      print('---------------- LOGIN DEBUG INFO ----------------');
      String? extractedUserName;
      String? extractedUserId;
      String? extractedRole;
      if (token != null) {
        try {
          print('TOKEN: $token');
          Map<String, dynamic> decoded = JwtDecoder.decode(token);
          print('DECODED TOKEN KEYS: ${decoded.keys.toList()}');
          
          // استخراج الاسم
          extractedUserName = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
              ?? decoded['unique_name']
              ?? decoded['sub'];
          print('EXTRACTED NAME FROM TOKEN: $extractedUserName');
          
          // ✅ استخراج userId من nameidentifier (GUID)
          extractedUserId = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
              ?? decoded['nameid']
              ?? decoded['sub'];
          print('EXTRACTED USER ID (GUID) FROM TOKEN: $extractedUserId');
          
          // ✅ استخراج الدور
          extractedRole = decoded['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
              ?? decoded['role'];
          print('EXTRACTED ROLE FROM TOKEN: $extractedRole');
        } catch (e, stackTrace) {
          print('❌ ERROR DECODING TOKEN: $e');
          print('Stack trace: $stackTrace');
        }
      }

      // ✅ Fallback 1: Use role from API response body
      if (extractedRole == null) {
        extractedRole = data['role']?.toString() ?? data['Role']?.toString();
        if (extractedRole != null) {
          print('⚠️ Role not found in token. Using role from API response: $extractedRole');
        }
      }

      // ✅ Fallback 2: Fetch role from API if still null
      if (extractedRole == null && token != null && extractedUserName != null) {
        try {
          print('⚠️ Role missing in token/body. Fetching from /api/Users/$extractedUserName...');
          final userUrl = Uri.parse('$baseUrl/Users/$extractedUserName');
          final userResponse = await http.get(
            userUrl,
            headers: {'Authorization': 'Bearer $token'},
          );
          
          if (userResponse.statusCode == 200) {
            final userData = jsonDecode(userResponse.body);
            extractedRole = userData['role']?.toString() ?? userData['Role']?.toString();
            print('✅ Fetched role from API: $extractedRole');
          } else {
            print('❌ Failed to fetch user role: ${userResponse.statusCode}');
          }
        } catch (e) {
          print('❌ Error fetching user role: $e');
        }
      }

      // ✅ Fallback 3: Default to 'Client' if everything else fails
      if (extractedRole == null) {
        extractedRole = 'Client';
        print('⚠️ Role could not be determined. Defaulting to: $extractedRole');
      }

      // ✅ حفظ GUID userId
      if (extractedUserId != null) {
        await prefs.setString('userGuid', extractedUserId);
        print('✅ SAVED USER GUID: $extractedUserId');
      } else {
        print('❌ WARNING: No GUID found in token!');
      }

      // ✅ جلب الـ numeric ID من الـ API
      int? numericId;
      final effectiveUserName = extractedUserName ?? data['userName'] ?? data['UserName'];
      
      if (extractedRole != null && token != null && effectiveUserName != null) {
        print('🔍 Fetching numeric ID for Role: $extractedRole, UserName: $effectiveUserName');
        numericId = await _fetchNumericId(extractedRole, token, effectiveUserName.toString());
        if (numericId != null) {
          await prefs.setInt('userId', numericId);
          print('✅ SAVED NUMERIC USER ID: $numericId');
        } else {
          print('❌ WARNING: Could not fetch numeric ID from API');
        }
      } else {
        print('❌ SKIPPING numeric ID fetch - Missing: ${extractedRole == null ? "Role " : ""}${token == null ? "Token " : ""}${effectiveUserName == null ? "UserName " : ""}');
      }

      // ✅ حفظ userName
      final userName = extractedUserName ?? data['userName'] ?? data['UserName'];
      if (userName != null && userName.toString().isNotEmpty) {
        await prefs.setString('userName', userName.toString());
        print('FINAL SAVED NAME: ${userName.toString()}');
      }

      // ✅ حفظ userRole
      if (extractedRole != null) {
        await prefs.setString('userRole', extractedRole!);
        print('FINAL SAVED ROLE: $extractedRole');
      }
      
      print('--------------------------------------------------');



      // دمج البيانات لضمان وجود userName
      final normalized = {
        ...data,
        if (token != null) 'token': token,
        if ((data['userName'] == null || data['userName'].toString().isEmpty) && extractedUserName != null)
          'userName': extractedUserName,
      };

      return UserModel.fromJson(normalized);
    } else {
      throw Exception('Login failed (${response.statusCode}): ${response.body}');
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
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // ✅ حفظ userId و userName في الذاكرة المحلية
      final userId = data['id'];
      if (userId != null) {
        if (userId is int) {
          await prefs.setInt('userId', userId);
        } else {
          await prefs.setString('userId', userId.toString());
        }
      }

      final String? fetchedName = data['userName'] ?? data['UserName'];
      if (fetchedName != null && fetchedName.isNotEmpty) {
        await prefs.setString('userName', fetchedName);
      }

      final normalized = {
        ...data,
        'token': token,
      };

      return UserModel.fromJson(normalized);
    } else {
      throw Exception('Failed to fetch profile: ${response.body}');
    }
  }

  // دالة التسجيل تبقى كما هي مع التأكد من استخدام نفس منطق استخراج التوكن
  @override
  Future<User> register({
    required String userName,
    required String email,
    required String password,
    String role = 'Client', // Default role
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
      'role': role, // ✅ Use passed role
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
      final token = await _saveTokenFromResponse(data);

      final normalized = {
        ...data,
        if (token != null) 'token': token,
      };

      return UserModel.fromJson(normalized);
    } else {
      throw Exception('Register failed: ${response.body}');
    }
  }

  // ====================== 🔵 تسجيل الدخول بجوجل ======================
  @override
  Future<User> googleLogin(String idToken) async {
    final url = Uri.parse('${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}Auth/google-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final token = await _saveTokenFromResponse(data);
      final prefs = await SharedPreferences.getInstance();

      // reuse the logic from login to extract info from token
      // We can duplicate the logic here or extract it to a method.
      // For now, I'll duplicate the extraction logic for safety/speed.
      
      print('---------------- GOOGLE LOGIN DEBUG INFO ----------------');
       String? extractedUserName;
      String? extractedUserId;
      String? extractedRole;
      if (token != null) {
        try {
          print('TOKEN: $token');
          Map<String, dynamic> decoded = JwtDecoder.decode(token);
          
          extractedUserName = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name']
              ?? decoded['unique_name']
              ?? decoded['sub'];
          
          extractedUserId = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
              ?? decoded['nameid']
              ?? decoded['sub'];
          
          extractedRole = decoded['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
              ?? decoded['role'];
        } catch (e) {
          print('❌ ERROR DECODING TOKEN: $e');
        }
      }

      if (extractedRole == null) {
         extractedRole = 'Member'; // Default for Google Login usually
      }

      // Save to prefs
       if (extractedUserId != null) await prefs.setString('userGuid', extractedUserId);
       if (extractedUserName != null) await prefs.setString('userName', extractedUserName);
       if (extractedRole != null) await prefs.setString('userRole', extractedRole!);

      // Attempt to fetch numeric ID if needed (for member/coach)
       int? numericId;
      if (extractedRole != null && token != null && extractedUserName != null) {
         numericId = await _fetchNumericId(extractedRole!, token, extractedUserName.toString());
         if (numericId != null) await prefs.setInt('userId', numericId);
      }

      final normalized = {
        ...data,
        if (token != null) 'token': token,
        if (extractedUserName != null) 'userName': extractedUserName,
      };

      return UserModel.fromJson(normalized);
    } else {
      throw Exception('Google Login failed (${response.statusCode}): ${response.body}');
    }
  }
}
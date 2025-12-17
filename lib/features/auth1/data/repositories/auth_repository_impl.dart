import 'package:shared_preferences/shared_preferences.dart'; // 1. إضافة هذا الاستيراد
import 'package:maa3/features/auth1/data/datasource/auth_api_service.dart';
import 'package:maa3/features/auth1/domain/entities/user.dart';
import 'package:maa3/features/auth1/domain/repositories/auth_repository.dart';
import 'package:maa3/features/auth1/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    final Map<String, dynamic> responseData = await remoteDataSource.login(
      email,
      password,
    );

    final roleFromApi = responseData['role']?.toString() ?? 'Member';

    return UserModel(
      id: responseData['id']?.toString() ?? '',
      email: responseData['email']?.toString() ?? email,
      role: roleFromApi,
      token: responseData['token']?.toString(),
      firstName: responseData['firstName']?.toString(),
      lastName: responseData['lastName']?.toString(),
      phoneNumber: responseData['phoneNumber']?.toString(),
      dateOfBirth: responseData['dateOfBirth'] != null
          ? DateTime.tryParse(responseData['dateOfBirth'].toString())
          : null,
    );
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    final Map<String, dynamic> responseData = await remoteDataSource.register(
      email: email,
      password: password,
      role: role,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth?.toIso8601String(),
    );

    final roleFromApi = responseData['role']?.toString() ?? role;

    return UserModel(
      id: responseData['id']?.toString() ?? '',
      email: responseData['email']?.toString() ?? email,
      role: roleFromApi,
      token: responseData['token']?.toString(),
      firstName: responseData['firstName']?.toString(),
      lastName: responseData['lastName']?.toString(),
      phoneNumber: responseData['phoneNumber']?.toString(),
      dateOfBirth: responseData['dateOfBirth'] != null
          ? DateTime.tryParse(responseData['dateOfBirth'].toString())
          : null,
    );
  }

  // ==================== الدالة الجديدة التي كانت مفقودة ====================
  @override
  Future<User> getUserProfile(String email) async {
    // 1. نحتاج التوكن لإرساله للسيرفر
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      throw Exception("User is not authenticated (No Token found)");
    }

    // 2. استدعاء الـ API الذي يجلب البيانات بناءً على التوكن
    // لاحظ أننا نستخدم الدالة الجديدة التي أضفناها في AuthApiService
    final Map<String, dynamic> responseData = await remoteDataSource.getCurrentUserProfile(token);

    // 3. تحويل البيانات إلى موديل
    return UserModel(
      id: responseData['id']?.toString() ?? '',
      email: responseData['email']?.toString() ?? '',
      role: responseData['role']?.toString() ?? 'Member',
      token: responseData['token']?.toString() ?? token, // نستخدم التوكن القديم إذا لم يرسله السيرفر
      firstName: responseData['firstName']?.toString(),
      lastName: responseData['lastName']?.toString(),
      phoneNumber: responseData['phoneNumber']?.toString(),
      dateOfBirth: responseData['dateOfBirth'] != null
          ? DateTime.tryParse(responseData['dateOfBirth'].toString())
          : null,
    );
  }
}
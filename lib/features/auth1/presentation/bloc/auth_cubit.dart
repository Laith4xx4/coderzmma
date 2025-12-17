import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maa3/features/auth1/presentation/bloc/auth_state.dart';
import 'package:maa3/features/auth1/domain/use_cases/login_user.dart';
import 'package:maa3/features/auth1/domain/use_cases/register_user.dart';
import 'package:maa3/features/auth1/domain/repositories/auth_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final AuthRepository _authRepository;

  AuthCubit(
      this._loginUser,
      this._registerUser,
      this._authRepository,
      ) : super(AuthInitial());

  // ====================== 🔐 تسجيل الدخول ======================
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure(error: 'البريد وكلمة المرور لا يمكن أن تكون فارغة.'));
      return;
    }

    emit(AuthLoading());

    try {
      // 1. تسجيل الدخول المبدئي (يجلب التوكن فقط)
      final user = await _loginUser(email, password);

      // 2. إصدار حالة النجاح لكي ينتقل التطبيق للصفحة التالية
      emit(AuthSuccess(token: user.token ?? '', user: user));

      print("🚀 Login successful! Token received. Now fetching full profile...");

      // 3. استدعاء دالة جلب البيانات الكاملة وتحديث الذاكرة
      await fetchUserProfile();

    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // ====================== 🧾 تسجيل حساب جديد ======================
  Future<void> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    emit(AuthLoading());

    try {
      final user = await _registerUser(
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
      );

      emit(AuthSuccess(token: user.token ?? '', user: user));
      // يمكن أيضاً استدعاء fetchUserProfile هنا إذا كان التسجيل يعيد توكن فقط

    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  // ====================== 👤 جلب بيانات المستخدم (Profile) ======================
  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token == null || token.isEmpty) return;

      // الاتصال بـ API: api/Users/me
      final user = await _authRepository.getUserProfile("");

      // حفظ البيانات الكاملة
      await prefs.setString("firstName", user.firstName ?? "");
      await prefs.setString("lastName", user.lastName ?? "");
      await prefs.setString("userRole", user.role);
      await prefs.setString("userEmail", user.email);

      // تحديث الحالة
      emit(AuthSuccess(token: token, user: user));

      print("✅✅✅ PROFILE UPDATED: ${user.firstName} ${user.lastName} - Role: ${user.role}");

    } catch (e) {
      print("❌❌❌ Failed to fetch profile: $e");
    }
  }

  // ====================== 🚪 تسجيل الخروج ======================
  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthInitial());
  }
}
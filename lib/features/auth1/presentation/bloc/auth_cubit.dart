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

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const AuthFailure(error: 'البريد وكلمة المرور لا يمكن أن تكون فارغة.'));
      return;
    }

    emit(AuthLoading());

    try {
      final user = await _loginUser(email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", user.token ?? "");
      await prefs.setString("userEmail", user.email);

      emit(AuthSuccess(token: user.token ?? '', user: user));

      await fetchUserProfile();

    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String role, // ← أضف هذا السطر
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    emit(AuthLoading());

    try {
      final user = await _registerUser(
        userName: email, // أو استخدم userName إذا كان موجود
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
      );

      emit(AuthSuccess(token: user.token ?? '', user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }


  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      final email = prefs.getString("userEmail");

      if (token == null || token.isEmpty || email == null || email.isEmpty) return;

      final user = await _authRepository.getUserProfile(email);

      await prefs.setString("firstName", user.firstName ?? "");
      await prefs.setString("lastName", user.lastName ?? "");
      await prefs.setString("userRole", user.role);
      await prefs.setString("userEmail", user.email);

      emit(AuthSuccess(token: token, user: user));
    } catch (e) {
      print("Failed to fetch profile: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthInitial());
  }
}

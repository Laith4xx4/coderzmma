import 'package:thesavage/features/auth1/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> googleLogin(String idToken);
  Future<User> register({
    required String userName,
    required String email,
    required String password,
    String role = 'Client', // Default role added
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  });

  Future<User> getUserProfile(String email);
}

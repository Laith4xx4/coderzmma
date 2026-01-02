import 'package:thesavage/features/auth1/domain/entities/user.dart';
import 'package:thesavage/features/auth1/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<User> call({
    required String userName,
    required String email,
    required String password,
    String role = 'Client', // Added
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    return repository.register(
      userName: userName,
      email: email,
      password: password,
      role: role, // Passed
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
    );
  }

}
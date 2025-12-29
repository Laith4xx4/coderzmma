import 'package:thesavage/features/auth1/domain/entities/user.dart';
import 'package:thesavage/features/auth1/domain/repositories/auth_repository.dart';

class GoogleLoginUser {
  final AuthRepository repository;

  GoogleLoginUser(this.repository);

  Future<User> call(String idToken) async {
    return await repository.googleLogin(idToken);
  }
}

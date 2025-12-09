import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Login use case
class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.login(email, password);
  }
}

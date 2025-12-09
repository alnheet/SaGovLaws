import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Register use case
class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<AppUser> call(String email, String password, String? displayName) {
    return repository.register(email, password, displayName);
  }
}

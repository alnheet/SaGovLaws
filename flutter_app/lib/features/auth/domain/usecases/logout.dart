import '../repositories/auth_repository.dart';

/// Logout use case
class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<void> call() {
    return repository.logout();
  }
}

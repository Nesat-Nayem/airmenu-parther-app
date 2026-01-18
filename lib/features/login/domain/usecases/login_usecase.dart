import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repo;

  LoginUsecase(this.repo);

  Future<Either<String, bool>> call(LoginParams params) {
    return repo.login(params.email, params.password);
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<String, bool>> login(String email, String password);
}

part of 'login_bloc.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String role;
  final bool isKycApproved;
  LoginSuccess({required this.role, required this.isKycApproved});
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

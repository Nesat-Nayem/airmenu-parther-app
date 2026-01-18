import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUsecase;

  LoginBloc({required this.loginUsecase}) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      final result = await loginUsecase(
        LoginParams(email: event.email, password: event.password),
      );

      result.fold(
        (failure) => emit(LoginError("Login failed")),
        (success) => emit(LoginSuccess()),
      );
    });
  }
}

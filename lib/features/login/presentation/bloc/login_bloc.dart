import 'package:airmenuai_partner_app/features/my_kyc/data/vendor_kyc_repository.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUsecase;
  final UserService _userService = locator<UserService>();
  final VendorKycRepository _vendorKycRepo = locator<VendorKycRepository>();

  LoginBloc({required this.loginUsecase}) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      final result = await loginUsecase(
        LoginParams(email: event.email, password: event.password),
      );

      await result.fold(
        (failure) async => emit(LoginError(failure)),
        (success) async {
          final user = await _userService.getCurrentUser();
          final role = user?.role ?? 'vendor';
          final isVendor = role.toLowerCase() == 'vendor';
          bool isKycApproved = true;
          if (isVendor) {
            try {
              final kyc = await _vendorKycRepo.getMyKyc();
              isKycApproved = kyc.status == 'approved';
            } catch (_) {
              // No KYC found means not approved
              isKycApproved = false;
            }
          }
          emit(LoginSuccess(role: role, isKycApproved: isKycApproved));
        },
      );
    });
  }
}

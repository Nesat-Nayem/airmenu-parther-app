import 'package:airmenuai_partner_app/features/my_kyc/data/vendor_kyc_repository.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class VendorKycEvent {}

class LoadMyKyc extends VendorKycEvent {}

// States
abstract class VendorKycState {}

class VendorKycInitial extends VendorKycState {}

class VendorKycLoading extends VendorKycState {}

class VendorKycLoaded extends VendorKycState {
  final KycSubmission kyc;
  VendorKycLoaded(this.kyc);
}

class VendorKycError extends VendorKycState {
  final String message;
  VendorKycError(this.message);
}

// BLoC
class VendorKycBloc extends Bloc<VendorKycEvent, VendorKycState> {
  final VendorKycRepository _repository;

  VendorKycBloc(this._repository) : super(VendorKycInitial()) {
    on<LoadMyKyc>(_onLoadMyKyc);
  }

  Future<void> _onLoadMyKyc(
    LoadMyKyc event,
    Emitter<VendorKycState> emit,
  ) async {
    emit(VendorKycLoading());
    try {
      final kyc = await _repository.getMyKyc();
      emit(VendorKycLoaded(kyc));
    } catch (e) {
      emit(VendorKycError(e.toString()));
    }
  }
}

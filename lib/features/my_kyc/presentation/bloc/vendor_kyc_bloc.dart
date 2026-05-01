import 'package:airmenuai_partner_app/features/my_kyc/data/vendor_kyc_repository.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class VendorKycEvent {}

class LoadMyKyc extends VendorKycEvent {}

/// Resubmit KYC after rejection. [updates] contains only the fields the vendor
/// edited (bank / aadhaar / gst / fssai / address / restaurant etc.).
class ResubmitMyKyc extends VendorKycEvent {
  final Map<String, dynamic> updates;
  ResubmitMyKyc(this.updates);
}

// States
abstract class VendorKycState {}

class VendorKycInitial extends VendorKycState {}

class VendorKycLoading extends VendorKycState {}

class VendorKycLoaded extends VendorKycState {
  final KycSubmission kyc;
  /// True while the resubmission request is in-flight.
  final bool isSubmitting;
  VendorKycLoaded(this.kyc, {this.isSubmitting = false});
}

class VendorKycError extends VendorKycState {
  final String message;
  VendorKycError(this.message);
}

/// Emitted once after a successful resubmission so the UI can show a toast.
class VendorKycResubmitted extends VendorKycState {
  final KycSubmission kyc;
  VendorKycResubmitted(this.kyc);
}

// BLoC
class VendorKycBloc extends Bloc<VendorKycEvent, VendorKycState> {
  final VendorKycRepository _repository;

  VendorKycBloc(this._repository) : super(VendorKycInitial()) {
    on<LoadMyKyc>(_onLoadMyKyc);
    on<ResubmitMyKyc>(_onResubmitMyKyc);
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

  Future<void> _onResubmitMyKyc(
    ResubmitMyKyc event,
    Emitter<VendorKycState> emit,
  ) async {
    // Show spinner on top of the existing loaded state if possible so the
    // vendor still sees their form during the request.
    final current = state;
    if (current is VendorKycLoaded) {
      emit(VendorKycLoaded(current.kyc, isSubmitting: true));
    } else {
      emit(VendorKycLoading());
    }

    try {
      final updated = await _repository.updateMyKyc(event.updates);
      emit(VendorKycResubmitted(updated));
      emit(VendorKycLoaded(updated));
    } catch (e) {
      // Revert to the previous loaded state if we had one, then surface error.
      if (current is VendorKycLoaded) {
        emit(VendorKycLoaded(current.kyc));
      }
      emit(VendorKycError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

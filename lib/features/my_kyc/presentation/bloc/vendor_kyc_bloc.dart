import 'package:airmenuai_partner_app/core/network/auth_service.dart';
import 'package:airmenuai_partner_app/features/my_kyc/data/vendor_kyc_repository.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class VendorKycEvent {}

class LoadMyKyc extends VendorKycEvent {}

/// Re-check KYC status (e.g. after admin approval) without tearing down the
/// current screen with a full-page loader. Triggered by the manual "Reload"
/// button on the My KYC page.
class RefreshMyKyc extends VendorKycEvent {}

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
  /// True while a background status re-check (Reload) is in-flight.
  final bool isRefreshing;
  VendorKycLoaded(
    this.kyc, {
    this.isSubmitting = false,
    this.isRefreshing = false,
  });
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

/// Emitted when the KYC is detected as approved. By this point the cached user
/// profile has been refreshed (status/hotelId persisted), so the UI can safely
/// redirect the vendor to their dashboard.
class VendorKycApproved extends VendorKycState {
  final KycSubmission kyc;
  VendorKycApproved(this.kyc);
}

// BLoC
class VendorKycBloc extends Bloc<VendorKycEvent, VendorKycState> {
  final VendorKycRepository _repository;
  final AuthService _authService = locator<AuthService>();

  VendorKycBloc(this._repository) : super(VendorKycInitial()) {
    on<LoadMyKyc>(_onLoadMyKyc);
    on<RefreshMyKyc>(_onRefreshMyKyc);
    on<ResubmitMyKyc>(_onResubmitMyKyc);
  }

  Future<void> _onLoadMyKyc(
    LoadMyKyc event,
    Emitter<VendorKycState> emit,
  ) async {
    emit(VendorKycLoading());
    try {
      final kyc = await _repository.getMyKyc();
      if (kyc.status == 'approved') {
        // Hydrate the local profile (status + hotelId) before letting the UI
        // move the vendor into the main panel.
        await _authService.refreshUserProfile();
        emit(VendorKycApproved(kyc));
        return;
      }
      emit(VendorKycLoaded(kyc));
    } catch (e) {
      emit(VendorKycError(e.toString()));
    }
  }

  /// Manual reload: keep showing the current screen but re-check the status.
  Future<void> _onRefreshMyKyc(
    RefreshMyKyc event,
    Emitter<VendorKycState> emit,
  ) async {
    final current = state;
    if (current is VendorKycLoaded) {
      emit(VendorKycLoaded(current.kyc, isRefreshing: true));
    }
    try {
      final kyc = await _repository.getMyKyc();
      if (kyc.status == 'approved') {
        await _authService.refreshUserProfile();
        emit(VendorKycApproved(kyc));
        return;
      }
      emit(VendorKycLoaded(kyc));
    } catch (e) {
      if (current is VendorKycLoaded) {
        emit(VendorKycLoaded(current.kyc));
      }
      emit(VendorKycError(e.toString().replaceFirst('Exception: ', '')));
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

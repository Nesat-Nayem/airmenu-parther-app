import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/domain/repositories/i_kyc_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_state.dart';

/// BLoC for managing the onboarding pipeline state
class OnboardingPipelineBloc
    extends Bloc<OnboardingPipelineEvent, OnboardingPipelineState> {
  final IKycRepository _repository;

  OnboardingPipelineBloc(this._repository) : super(const PipelineInitial()) {
    on<LoadKycBoard>(_onLoadKycBoard);
    on<ReviewKyc>(_onReviewKyc);
  }

  /// Handle loading kyc board data
  Future<void> _onLoadKycBoard(
    LoadKycBoard event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    emit(const PipelineLoading());

    try {
      final submissions = await _repository.getAllKycSubmissions();
      final grouped = _groupSubmissions(submissions);
      emit(PipelineLoaded(kycByStatus: grouped));
    } catch (e) {
      emit(PipelineError(message: 'Failed to load KYC data: $e'));
    }
  }

  /// Handle reviewing (approve/reject)
  Future<void> _onReviewKyc(
    ReviewKyc event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    // Keep showing current state or show loading?
    // Ideally optimistic update or show loading. For simplicity, reload after action.
    try {
      await _repository.reviewKyc(
        event.id,
        event.status,
        comments: event.comments,
      );
      // Reload data
      add(const LoadKycBoard());
    } catch (e) {
      emit(PipelineError(message: 'Failed to update KYC status: $e'));
    }
  }

  Map<String, List<KycSubmission>> _groupSubmissions(List<KycSubmission> list) {
    final map = <String, List<KycSubmission>>{
      'pending': [],
      'approved': [],
      'rejected': [],
    };
    for (var sub in list) {
      final status = sub.status.toLowerCase();
      if (map.containsKey(status)) {
        map[status]!.add(sub);
      } else {
        // Fallback or ignore
        map.putIfAbsent(status, () => []).add(sub);
      }
    }
    return map;
  }
}

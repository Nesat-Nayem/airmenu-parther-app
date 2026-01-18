import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';

/// Base class for all onboarding pipeline states
abstract class OnboardingPipelineState extends Equatable {
  const OnboardingPipelineState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PipelineInitial extends OnboardingPipelineState {
  const PipelineInitial();
}

/// Loading state while fetching data
class PipelineLoading extends OnboardingPipelineState {
  const PipelineLoading();
}

/// Loaded state with pipeline data
class PipelineLoaded extends OnboardingPipelineState {
  final Map<String, List<KycSubmission>> kycByStatus;

  const PipelineLoaded({required this.kycByStatus});

  @override
  List<Object?> get props => [kycByStatus];
}

/// Error state when data loading fails
class PipelineError extends OnboardingPipelineState {
  final String message;

  const PipelineError({required this.message});

  @override
  List<Object?> get props => [message];
}

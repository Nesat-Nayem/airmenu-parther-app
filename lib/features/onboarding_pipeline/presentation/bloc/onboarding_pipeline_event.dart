import 'package:equatable/equatable.dart';

/// Base class for all onboardimport 'package:equatable/equatable.dart';

abstract class OnboardingPipelineEvent extends Equatable {
  const OnboardingPipelineEvent();

  @override
  List<Object?> get props => [];
}

class LoadKycBoard extends OnboardingPipelineEvent {
  const LoadKycBoard();
}

class ReviewKyc extends OnboardingPipelineEvent {
  final String id;
  final String status; // 'approved' or 'rejected'
  final String? comments;

  const ReviewKyc({required this.id, required this.status, this.comments});

  @override
  List<Object?> get props => [id, status, comments];
}

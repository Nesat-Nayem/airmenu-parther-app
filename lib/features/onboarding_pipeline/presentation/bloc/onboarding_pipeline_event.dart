import 'package:equatable/equatable.dart';

abstract class OnboardingPipelineEvent extends Equatable {
  const OnboardingPipelineEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial data for all statuses (first page each) and stats
class LoadKycBoard extends OnboardingPipelineEvent {
  final String? restaurantType;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadKycBoard({this.restaurantType, this.startDate, this.endDate});

  @override
  List<Object?> get props => [restaurantType, startDate, endDate];
}

/// Apply filters and reload data
class ApplyFilters extends OnboardingPipelineEvent {
  final String? restaurantType;
  final DateTime? startDate;
  final DateTime? endDate;

  const ApplyFilters({this.restaurantType, this.startDate, this.endDate});

  @override
  List<Object?> get props => [restaurantType, startDate, endDate];
}

/// Clear all filters
class ClearFilters extends OnboardingPipelineEvent {
  const ClearFilters();
}

/// Load more items for a specific status (pagination)
class LoadMoreKycByStatus extends OnboardingPipelineEvent {
  final String status; // 'pending', 'approved', 'rejected'

  const LoadMoreKycByStatus({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Refresh a specific status column
class RefreshKycByStatus extends OnboardingPipelineEvent {
  final String status;

  const RefreshKycByStatus({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Review (approve/reject) a KYC submission
class ReviewKyc extends OnboardingPipelineEvent {
  final String id;
  final String status; // 'approved' or 'rejected'
  final String? comments;

  const ReviewKyc({required this.id, required this.status, this.comments});

  @override
  List<Object?> get props => [id, status, comments];
}

/// Fetch admin Adobe signing URL for a KYC submission
class FetchAdminSigningUrl extends OnboardingPipelineEvent {
  final String kycId;

  const FetchAdminSigningUrl({required this.kycId});

  @override
  List<Object?> get props => [kycId];
}

/// Sync Adobe agreement status after admin signs
class SyncAdobeStatus extends OnboardingPipelineEvent {
  final String kycId;

  const SyncAdobeStatus({required this.kycId});

  @override
  List<Object?> get props => [kycId];
}

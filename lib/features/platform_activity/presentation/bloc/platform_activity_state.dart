part of 'platform_activity_bloc.dart';

abstract class PlatformActivityState {}

class PlatformActivityInitial extends PlatformActivityState {}

class PlatformActivityLoading extends PlatformActivityState {}

class PlatformActivityLoaded extends PlatformActivityState {
  final List<ActivityModel> activities;
  final ActivitySummary summary;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final String? actorRole;
  final String? action;
  final String? entityType;

  PlatformActivityLoaded({
    required this.activities,
    required this.summary,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    this.actorRole,
    this.action,
    this.entityType,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  bool get hasFilters =>
      actorRole != null || action != null || entityType != null;
}

class PlatformActivityError extends PlatformActivityState {
  final String message;

  PlatformActivityError(this.message);
}

class PlatformActivityEmpty extends PlatformActivityState {
  final String message;

  PlatformActivityEmpty(this.message);
}

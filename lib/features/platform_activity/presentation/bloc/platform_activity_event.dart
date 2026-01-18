part of 'platform_activity_bloc.dart';

abstract class PlatformActivityEvent {}

class LoadPlatformActivities extends PlatformActivityEvent {
  final int page;
  final int limit;
  final String? actorRole;
  final String? action;
  final String? entityType;

  LoadPlatformActivities({
    this.page = 1,
    this.limit = 20,
    this.actorRole,
    this.action,
    this.entityType,
  });
}

class RefreshPlatformActivities extends PlatformActivityEvent {}

class LoadMoreActivities extends PlatformActivityEvent {}

class ApplyFilters extends PlatformActivityEvent {
  final String? actorRole;
  final String? action;
  final String? entityType;
  final int limit;

  ApplyFilters({this.actorRole, this.action, this.entityType, this.limit = 20});
}

class ClearFilters extends PlatformActivityEvent {}

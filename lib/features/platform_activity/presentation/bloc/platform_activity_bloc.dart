import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/features/platform_activity/data/models/activity_model.dart';
import 'package:airmenuai_partner_app/features/platform_activity/domain/usecases/get_platform_activities_usecase.dart';

part 'platform_activity_event.dart';
part 'platform_activity_state.dart';

class PlatformActivityBloc
    extends Bloc<PlatformActivityEvent, PlatformActivityState> {
  final GetPlatformActivitiesUsecase getPlatformActivitiesUsecase;

  PlatformActivityBloc({required this.getPlatformActivitiesUsecase})
    : super(PlatformActivityInitial()) {
    on<LoadPlatformActivities>(_onLoadPlatformActivities);
    on<RefreshPlatformActivities>(_onRefreshPlatformActivities);
    on<LoadMoreActivities>(_onLoadMoreActivities);
    on<ApplyFilters>(_onApplyFilters);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadPlatformActivities(
    LoadPlatformActivities event,
    Emitter<PlatformActivityState> emit,
  ) async {
    emit(PlatformActivityLoading());
    await _fetchActivities(
      emit,
      page: event.page,
      limit: event.limit,
      actorRole: event.actorRole,
      action: event.action,
      entityType: event.entityType,
    );
  }

  Future<void> _onRefreshPlatformActivities(
    RefreshPlatformActivities event,
    Emitter<PlatformActivityState> emit,
  ) async {
    final currentState = state;
    if (currentState is PlatformActivityLoaded) {
      await _fetchActivities(
        emit,
        page: 1,
        limit: currentState.limit,
        actorRole: currentState.actorRole,
        action: currentState.action,
        entityType: currentState.entityType,
      );
    } else {
      await _fetchActivities(emit, page: 1, limit: 20);
    }
  }

  Future<void> _onLoadMoreActivities(
    LoadMoreActivities event,
    Emitter<PlatformActivityState> emit,
  ) async {
    if (state is PlatformActivityLoaded) {
      final currentState = state as PlatformActivityLoaded;

      // Don't load more if we're on the last page
      if (currentState.page >= currentState.totalPages) {
        return;
      }

      final nextPage = currentState.page + 1;

      final result = await getPlatformActivitiesUsecase.invoke(
        GetPlatformActivitiesParams(
          page: nextPage,
          limit: currentState.limit,
          actorRole: currentState.actorRole,
          action: currentState.action,
          entityType: currentState.entityType,
        ),
      );

      if (result.isLeft) {
        // Keep current state on error
        return;
      }

      final newResponse = result.right;

      // Merge activities
      final mergedActivities = [
        ...currentState.activities,
        ...newResponse.activities,
      ];

      emit(
        PlatformActivityLoaded(
          activities: mergedActivities,
          summary: newResponse.summary,
          total: newResponse.total,
          page: newResponse.page,
          limit: newResponse.limit,
          totalPages: newResponse.totalPages,
          actorRole: currentState.actorRole,
          action: currentState.action,
          entityType: currentState.entityType,
        ),
      );
    }
  }

  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<PlatformActivityState> emit,
  ) async {
    emit(PlatformActivityLoading());
    await _fetchActivities(
      emit,
      page: 1,
      limit: event.limit,
      actorRole: event.actorRole,
      action: event.action,
      entityType: event.entityType,
    );
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<PlatformActivityState> emit,
  ) async {
    emit(PlatformActivityLoading());
    await _fetchActivities(emit, page: 1, limit: 20);
  }

  Future<void> _fetchActivities(
    Emitter<PlatformActivityState> emit, {
    required int page,
    required int limit,
    String? actorRole,
    String? action,
    String? entityType,
  }) async {
    try {
      final result = await getPlatformActivitiesUsecase.invoke(
        GetPlatformActivitiesParams(
          page: page,
          limit: limit,
          actorRole: actorRole,
          action: action,
          entityType: entityType,
        ),
      );

      if (result.isLeft) {
        final failure = result.left;
        String errorMessage = 'Failed to load platform activities';

        if (failure is ServerFailure) {
          errorMessage = failure.message;
        }

        emit(PlatformActivityError(errorMessage));
        return;
      }

      final response = result.right;

      if (response.activities.isEmpty && page == 1) {
        emit(PlatformActivityEmpty('No activities found'));
        return;
      }

      emit(
        PlatformActivityLoaded(
          activities: response.activities,
          summary: response.summary,
          total: response.total,
          page: response.page,
          limit: response.limit,
          totalPages: response.totalPages,
          actorRole: actorRole,
          action: action,
          entityType: entityType,
        ),
      );
    } catch (e) {
      emit(PlatformActivityError(e.toString()));
    }
  }
}
